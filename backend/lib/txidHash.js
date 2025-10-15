/**
 * Transaction ID Hashing Utility
 * 
 * Purpose: Create de-identified hashes of Apple original_transaction_ids
 * for fraud prevention and accounting compliance (Apple 5.1.1(v))
 * 
 * The hash is stable (same txid = same hash) but not reversible.
 * No PII is included in the hash or stored in the ledger.
 */

const crypto = require('crypto');

/**
 * Hash an Apple original_transaction_id with a server-side salt
 * @param {string} originalTxId - Apple's original_transaction_id
 * @param {string} salt - Server-side salt (from LEDGER_SALT env var)
 * @returns {string} SHA-256 hex hash
 * @throws {Error} If salt is not provided
 */
function txidHash(originalTxId, salt) {
    if (!salt) {
        throw new Error('LEDGER_SALT environment variable is required for txidHash');
    }
    
    if (!originalTxId) {
        throw new Error('originalTxId is required for hashing');
    }
    
    // SHA-256 hash of (salt + originalTxId)
    // Salt prevents rainbow table attacks
    return crypto
        .createHash('sha256')
        .update(salt + originalTxId)
        .digest('hex');
}

module.exports = {
    txidHash
};

