/**
 * Entitlements Ledger Service
 * 
 * Purpose: Manage de-identified transaction ledger for fraud prevention
 * and accounting compliance (Apple 5.1.1(v))
 * 
 * This service maintains a PII-free ledger of subscription transactions
 * that persists even after account deletion. Used to:
 * - Prevent trial abuse (detect prior trial usage by Apple ID)
 * - Financial compliance and auditing
 * - Business analytics (aggregate, anonymized)
 */

const { Pool } = require('pg');
const { txidHash } = require('../lib/txidHash');

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

/**
 * Upsert a record in the entitlements ledger
 * 
 * @param {Object} input - Ledger upsert input
 * @param {string} input.originalTransactionId - Apple's original_transaction_id (plain)
 * @param {string} input.productId - Product ID (e.g., "com.homeworkhelper.monthly")
 * @param {string} input.subscriptionGroupId - Subscription group ID
 * @param {'active'|'expired'|'canceled'} input.status - Current subscription status
 * @param {boolean} [input.everTrial] - Whether this transaction used a trial/intro offer
 * @returns {Promise<{original_transaction_id_hash: string}>}
 */
async function upsertLedgerRecord(input) {
    const {
        originalTransactionId,
        productId,
        subscriptionGroupId,
        status,
        everTrial = false
    } = input;
    
    // Validate inputs
    if (!originalTransactionId) {
        throw new Error('originalTransactionId is required for ledger upsert');
    }
    if (!productId) {
        throw new Error('productId is required for ledger upsert');
    }
    if (!subscriptionGroupId) {
        throw new Error('subscriptionGroupId is required for ledger upsert');
    }
    if (!['active', 'expired', 'canceled'].includes(status)) {
        throw new Error('status must be one of: active, expired, canceled');
    }
    
    // Hash the transaction ID (de-identification)
    const hash = txidHash(originalTransactionId, process.env.LEDGER_SALT);
    const now = new Date();
    
    try {
        // Try to find existing record by hash
        const existingResult = await pool.query(
            'SELECT * FROM entitlements_ledger WHERE original_transaction_id_hash = $1',
            [hash]
        );
        
        if (existingResult.rows.length > 0) {
            // Update existing record
            const existing = existingResult.rows[0];
            
            await pool.query(`
                UPDATE entitlements_ledger
                SET product_id = $1,
                    subscription_group_id = $2,
                    status = $3,
                    ever_trial = $4,
                    last_seen_at = $5
                WHERE original_transaction_id_hash = $6
            `, [
                productId,
                subscriptionGroupId,
                status,
                everTrial ? true : existing.ever_trial, // Once true, always true
                now,
                hash
            ]);
            
            console.log(`📝 Updated ledger record: hash=${hash.substring(0, 16)}..., status=${status}, ever_trial=${everTrial || existing.ever_trial}`);
        } else {
            // Insert new record
            await pool.query(`
                INSERT INTO entitlements_ledger (
                    original_transaction_id_hash,
                    product_id,
                    subscription_group_id,
                    status,
                    ever_trial,
                    first_seen_at,
                    last_seen_at
                ) VALUES ($1, $2, $3, $4, $5, $6, $7)
            `, [
                hash,
                productId,
                subscriptionGroupId,
                status,
                everTrial,
                now,
                now
            ]);
            
            console.log(`📝 Created ledger record: hash=${hash.substring(0, 16)}..., status=${status}, ever_trial=${everTrial}`);
        }
        
        return { original_transaction_id_hash: hash };
        
    } catch (error) {
        console.error('❌ Error upserting ledger record:', error);
        throw error;
    }
}

/**
 * Check if a transaction ID has ever used a trial
 * (Useful for detecting trial abuse attempts)
 * 
 * @param {string} originalTransactionId - Apple's original_transaction_id
 * @returns {Promise<boolean>} True if this transaction ever used a trial
 */
async function hasEverUsedTrial(originalTransactionId) {
    if (!originalTransactionId) {
        return false;
    }
    
    try {
        const hash = txidHash(originalTransactionId, process.env.LEDGER_SALT);
        
        const result = await pool.query(
            'SELECT ever_trial FROM entitlements_ledger WHERE original_transaction_id_hash = $1',
            [hash]
        );
        
        if (result.rows.length > 0) {
            return result.rows[0].ever_trial === true;
        }
        
        return false;
    } catch (error) {
        console.error('❌ Error checking trial status:', error);
        return false; // Fail open - don't block on errors
    }
}

/**
 * Prune old ledger records based on retention policy
 * (Should be called periodically via cron/scheduler)
 * 
 * @param {number} retentionMonths - Number of months to retain (default 24)
 * @returns {Promise<number>} Number of records pruned
 */
async function pruneLedger(retentionMonths = 24) {
    try {
        const cutoffDate = new Date();
        cutoffDate.setMonth(cutoffDate.getMonth() - retentionMonths);
        
        const result = await pool.query(
            'DELETE FROM entitlements_ledger WHERE last_seen_at < $1',
            [cutoffDate]
        );
        
        const count = result.rowCount || 0;
        console.log(`🗑️ Pruned ${count} ledger records older than ${retentionMonths} months`);
        
        return count;
    } catch (error) {
        console.error('❌ Error pruning ledger:', error);
        throw error;
    }
}

/**
 * Get ledger statistics (for admin/analytics)
 * 
 * @returns {Promise<Object>} Aggregated ledger stats
 */
async function getLedgerStats() {
    try {
        const result = await pool.query(`
            SELECT 
                COUNT(*) as total_records,
                COUNT(*) FILTER (WHERE ever_trial = true) as ever_trial_count,
                COUNT(*) FILTER (WHERE status = 'active') as active_count,
                COUNT(*) FILTER (WHERE status = 'expired') as expired_count,
                COUNT(*) FILTER (WHERE status = 'canceled') as canceled_count,
                MIN(first_seen_at) as oldest_record,
                MAX(last_seen_at) as newest_record
            FROM entitlements_ledger
        `);
        
        return result.rows[0];
    } catch (error) {
        console.error('❌ Error getting ledger stats:', error);
        throw error;
    }
}

module.exports = {
    upsertLedgerRecord,
    hasEverUsedTrial,
    pruneLedger,
    getLedgerStats
};

