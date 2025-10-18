const { Pool } = require('pg');

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

/**
 * Centralized subscription status calculation
 * Single source of truth for all subscription data
 * @param {string} userId - User ID to check
 * @returns {Object} Subscription status with days remaining
 */
async function calculateSubscriptionStatus(userId) {
    try {
        const result = await pool.query(`
            SELECT 
                subscription_status,
                subscription_end_date,
                CASE 
                    WHEN subscription_end_date > NOW() THEN 
                        CEIL(EXTRACT(EPOCH FROM (subscription_end_date - NOW())) / 86400)
                    ELSE 0 
                END as days_remaining,
                subscription_start_date,
                created_at,
                last_active_at
            FROM users 
            WHERE user_id = $1
        `, [userId]);

        if (result.rows.length === 0) {
            throw new Error('User not found');
        }

        const user = result.rows[0];
        
        // Determine current status based on database values
        let currentStatus = user.subscription_status;
        const daysRemaining = parseInt(user.days_remaining) || 0;
        
        // Auto-update status if expired but not marked as expired
        if (user.subscription_end_date && daysRemaining <= 0 && currentStatus !== 'expired') {
            currentStatus = 'expired';
            // Update database to reflect current status
            await pool.query(
                'UPDATE users SET subscription_status = $1 WHERE user_id = $2',
                ['expired', userId]
            );
            console.log(`🔄 Auto-updated subscription status to expired for user: ${userId}`);
        }

        return {
            status: currentStatus,
            daysRemaining: daysRemaining,
            endDate: user.subscription_end_date,
            startDate: user.subscription_start_date,
            createdAt: user.created_at,
            lastActiveAt: user.last_active_at
        };

    } catch (error) {
        console.error('Error calculating subscription status:', error);
        throw error;
    }
}

/**
 * Update subscription end date and recalculate status
 * @param {string} userId - User ID
 * @param {number} days - Days to add/subtract (positive to extend, negative to reduce)
 * @returns {Object} Updated subscription status
 */
async function updateSubscriptionPeriod(userId, days) {
    try {
        // Get current subscription data
        const currentResult = await pool.query(`
            SELECT subscription_end_date, subscription_status
            FROM users 
            WHERE user_id = $1
        `, [userId]);

        if (currentResult.rows.length === 0) {
            throw new Error('User not found');
        }

        const currentUser = currentResult.rows[0];
        let newEndDate;

        if (currentUser.subscription_end_date && new Date(currentUser.subscription_end_date) > new Date()) {
            // Extend from current end date
            newEndDate = new Date(currentUser.subscription_end_date);
            newEndDate.setDate(newEndDate.getDate() + parseInt(days));
        } else {
            // Start from now
            newEndDate = new Date();
            newEndDate.setDate(newEndDate.getDate() + parseInt(days));
        }

        // Convert to PostgreSQL timestamp with timezone format
        newEndDate = newEndDate.toISOString();

        // Update subscription in database
        const updateResult = await pool.query(`
            UPDATE users 
            SET subscription_end_date = $1,
                subscription_status = CASE 
                    WHEN $1::timestamp > NOW() THEN 'trial'
                    ELSE 'expired'
                END,
                last_active_at = NOW()
            WHERE user_id = $2
            RETURNING subscription_status, subscription_end_date
        `, [newEndDate, userId]);

        console.log(`✅ Subscription period updated for user ${userId}: ${days > 0 ? 'extended' : 'reduced'} by ${Math.abs(days)} days`);

        // Return updated status using centralized calculation
        return await calculateSubscriptionStatus(userId);

    } catch (error) {
        console.error('Error updating subscription period:', error);
        throw error;
    }
}

module.exports = {
    calculateSubscriptionStatus,
    updateSubscriptionPeriod
};
