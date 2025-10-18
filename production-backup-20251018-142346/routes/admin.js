const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const { requireAdmin } = require('../middleware/adminAuth');
const { calculateSubscriptionStatus } = require('../services/subscriptionService');

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// MARK: - Admin User Management

/**
 * GET /api/admin/users
 * Get all users with pagination
 */
router.get('/users', requireAdmin, async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 50;
        const offset = (page - 1) * limit;
        const search = req.query.search || '';
        const status = req.query.status || '';
        
        let query = `
            SELECT 
                u.user_id, u.email, u.username, u.auth_provider,
                u.subscription_status, u.subscription_start_date, u.subscription_end_date,
                u.promo_code_used, u.is_active, u.is_banned, u.banned_reason,
                u.created_at, u.last_active_at,
                CASE 
                    WHEN u.subscription_end_date > NOW() THEN 
                        CEIL(EXTRACT(EPOCH FROM (u.subscription_end_date - NOW())) / 86400)
                    ELSE 0 
                END as days_remaining,
                COALESCE((SELECT COUNT(*) FROM device_logins WHERE user_id = u.user_id), 0) as total_logins,
                COALESCE((SELECT COUNT(*) FROM device_logins WHERE user_id = u.user_id AND login_time > NOW() - INTERVAL '7 days'), 0) as logins_last_7_days,
                COALESCE((SELECT COUNT(DISTINCT device_id) FROM device_logins WHERE user_id = u.user_id), 0) as unique_devices
            FROM users u
            WHERE 1=1
        `;
        
        const params = [];
        let paramCount = 1;
        
        if (search) {
            query += ` AND (email ILIKE $${paramCount} OR username ILIKE $${paramCount} OR user_id ILIKE $${paramCount})`;
            params.push(`%${search}%`);
            paramCount++;
        }
        
        if (status) {
            query += ` AND subscription_status = $${paramCount}`;
            params.push(status);
            paramCount++;
        }
        
        query += ` ORDER BY created_at DESC LIMIT $${paramCount} OFFSET $${paramCount + 1}`;
        params.push(limit, offset);
        
        const result = await pool.query(query, params);
        
        // Get total count
        let countQuery = 'SELECT COUNT(*) FROM users WHERE 1=1';
        const countParams = [];
        
        if (search) {
            countQuery += ` AND (email ILIKE $1 OR username ILIKE $1 OR user_id ILIKE $1)`;
            countParams.push(`%${search}%`);
        }
        
        const countResult = await pool.query(countQuery, countParams);
        const totalUsers = parseInt(countResult.rows[0].count);
        
        res.json({
            users: result.rows,
            pagination: {
                page,
                limit,
                total: totalUsers,
                totalPages: Math.ceil(totalUsers / limit)
            }
        });
        
    } catch (error) {
        console.error('Error fetching users:', error);
        res.status(500).json({ error: 'Failed to fetch users' });
    }
});

/**
 * GET /api/admin/users/:userId
 * Get detailed information about a specific user
 */
router.get('/users/:userId', requireAdmin, async (req, res) => {
    try {
        const { userId } = req.params;
        
        // Get user details
        const userResult = await pool.query(
            'SELECT * FROM users WHERE user_id = $1',
            [userId]
        );
        
        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        // Get subscription history
        const historyResult = await pool.query(
            'SELECT * FROM subscription_history WHERE user_id = $1 ORDER BY created_at DESC LIMIT 20',
            [userId]
        );
        
        // Get promo code usage
        const promoResult = await pool.query(`
            SELECT pcu.*, pc.code, pc.duration_days 
            FROM promo_code_usage pcu
            JOIN promo_codes pc ON pcu.promo_code_id = pc.id
            WHERE pcu.user_id = $1
        `, [userId]);
        
        res.json({
            user: userResult.rows[0],
            subscription_history: historyResult.rows,
            promo_codes_used: promoResult.rows
        });
        
    } catch (error) {
        console.error('Error fetching user details:', error);
        res.status(500).json({ error: 'Failed to fetch user details' });
    }
});

/**
 * POST /api/admin/users/:userId/toggle-access
 * Activate or deactivate a user
 */
router.post('/users/:userId/toggle-access', requireAdmin, async (req, res) => {
    try {
        const { userId } = req.params;
        const { is_active } = req.body;
        
        await pool.query(
            'UPDATE users SET is_active = $1, updated_at = NOW() WHERE user_id = $2',
            [is_active, userId]
        );
        
        // Log the action
        await pool.query(`
            INSERT INTO subscription_history (user_id, event_type, metadata)
            VALUES ($1, $2, $3)
        `, [userId, 'access_toggled', JSON.stringify({ is_active, admin: req.admin.username })]);
        
        res.json({ 
            success: true, 
            message: `User ${is_active ? 'activated' : 'deactivated'}` 
        });
        
    } catch (error) {
        console.error('Error toggling user access:', error);
        res.status(500).json({ error: 'Failed to toggle user access' });
    }
});

/**
 * POST /api/admin/users/:userId/ban
 * Ban or unban a user
 */
router.post('/users/:userId/ban', requireAdmin, async (req, res) => {
    try {
        const { userId } = req.params;
        const { is_banned, reason } = req.body;
        
        await pool.query(
            'UPDATE users SET is_banned = $1, banned_reason = $2, updated_at = NOW() WHERE user_id = $3',
            [is_banned, reason || null, userId]
        );
        
        // Log the action
        await pool.query(`
            INSERT INTO subscription_history (user_id, event_type, metadata)
            VALUES ($1, $2, $3)
        `, [userId, is_banned ? 'user_banned' : 'user_unbanned', JSON.stringify({ reason, admin: req.admin.username })]);
        
        res.json({ 
            success: true, 
            message: `User ${is_banned ? 'banned' : 'unbanned'}` 
        });
        
    } catch (error) {
        console.error('Error banning user:', error);
        res.status(500).json({ error: 'Failed to ban user' });
    }
});

/**
 * POST /api/admin/users/:userId/extend
 * Extend a user's subscription
 */
router.post('/users/:userId/extend', requireAdmin, async (req, res) => {
    try {
        const { userId } = req.params;
        const { days } = req.body;
        
        if (!days || days <= 0) {
            return res.status(400).json({ error: 'Invalid number of days' });
        }
        
        const result = await pool.query(`
            UPDATE users 
            SET subscription_end_date = COALESCE(subscription_end_date, NOW()) + INTERVAL '${days} days',
                subscription_status = CASE 
                    WHEN subscription_status = 'expired' THEN 'active'
                    ELSE subscription_status
                END,
                updated_at = NOW()
            WHERE user_id = $1
            RETURNING subscription_end_date
        `, [userId]);
        
        // Log the action
        await pool.query(`
            INSERT INTO subscription_history (user_id, event_type, metadata)
            VALUES ($1, 'subscription_extended', $2)
        `, [userId, JSON.stringify({ days_added: days, admin: req.admin.username })]);
        
        res.json({ 
            success: true, 
            message: `Extended subscription by ${days} days`,
            new_end_date: result.rows[0].subscription_end_date
        });
        
    } catch (error) {
        console.error('Error extending subscription:', error);
        res.status(500).json({ error: 'Failed to extend subscription' });
    }
});

/**
 * POST /api/admin/users
 * Create a new user
 */
router.post('/users', requireAdmin, async (req, res) => {
    try {
        const { email, username, password, subscription_status, subscription_days } = req.body;
        
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }
        
        // Check if user already exists
        const existingUser = await pool.query(
            'SELECT * FROM users WHERE email = $1',
            [email.toLowerCase()]
        );
        
        if (existingUser.rows.length > 0) {
            return res.status(400).json({ error: 'User with this email already exists' });
        }
        
        // Hash password
        const bcrypt = require('bcrypt');
        const password_hash = await bcrypt.hash(password, 10);
        
        // Generate user ID
        const { v4: uuidv4 } = require('uuid');
        const user_id = uuidv4();
        
        // Calculate subscription dates
        const subscription_start_date = new Date();
        const subscription_end_date = new Date();
        subscription_end_date.setDate(subscription_end_date.getDate() + (subscription_days || 7));
        
        // Create user (username always set to email)
        const result = await pool.query(`
            INSERT INTO users (
                user_id, email, username, password_hash, auth_provider,
                subscription_status, subscription_start_date, subscription_end_date,
                is_active, is_banned, created_at, updated_at
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, true, false, NOW(), NOW())
            RETURNING *
        `, [
            user_id,
            email.toLowerCase(),
            email.toLowerCase(), // username = email (ignore username parameter)
            password_hash,
            'email',
            subscription_status || 'trial',
            subscription_start_date,
            subscription_end_date
        ]);
        
        // Log the action
        await pool.query(`
            INSERT INTO subscription_history (user_id, event_type, metadata)
            VALUES ($1, 'user_created_by_admin', $2)
        `, [user_id, JSON.stringify({ admin: req.admin.username })]);
        
        res.json({ 
            success: true, 
            message: 'User created successfully',
            user: result.rows[0]
        });
        
    } catch (error) {
        console.error('Error creating user:', error);
        res.status(500).json({ error: 'Failed to create user' });
    }
});

/**
 * DELETE /api/admin/users/:userId
 * Delete a user
 */
router.delete('/users/:userId', requireAdmin, async (req, res) => {
    try {
        const { userId } = req.params;
        
        // Check if user exists
        const userCheck = await pool.query('SELECT * FROM users WHERE user_id = $1', [userId]);
        
        if (userCheck.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        // Delete user and related data
        await pool.query('DELETE FROM subscription_history WHERE user_id = $1', [userId]);
        await pool.query('DELETE FROM promo_code_usage WHERE user_id = $1', [userId]);
        await pool.query('DELETE FROM users WHERE user_id = $1', [userId]);
        
        res.json({ 
            success: true, 
            message: 'User deleted successfully'
        });
        
    } catch (error) {
        console.error('Error deleting user:', error);
        res.status(500).json({ error: 'Failed to delete user' });
    }
});

/**
 * PUT /api/admin/users/:userId/password
 * Change user password
 */
router.put('/users/:userId/password', requireAdmin, async (req, res) => {
    try {
        const { userId } = req.params;
        const { new_password } = req.body;
        
        if (!new_password || new_password.length < 6) {
            return res.status(400).json({ error: 'Password must be at least 6 characters' });
        }
        
        // Hash password
        const bcrypt = require('bcrypt');
        const password_hash = await bcrypt.hash(new_password, 10);
        
        await pool.query(
            'UPDATE users SET password_hash = $1, updated_at = NOW() WHERE user_id = $2',
            [password_hash, userId]
        );
        
        // Log the action
        await pool.query(`
            INSERT INTO subscription_history (user_id, event_type, metadata)
            VALUES ($1, 'password_changed_by_admin', $2)
        `, [userId, JSON.stringify({ admin: req.admin.username })]);
        
        res.json({ 
            success: true, 
            message: 'Password updated successfully'
        });
        
    } catch (error) {
        console.error('Error updating password:', error);
        res.status(500).json({ error: 'Failed to update password' });
    }
});

/**
 * PUT /api/admin/users/:userId/membership
 * Update user membership details
 */
router.put('/users/:userId/membership', requireAdmin, async (req, res) => {
    try {
        const { userId } = req.params;
        const { subscription_status, subscription_end_date, subscription_start_date } = req.body;
        
        const updates = [];
        const params = [userId];
        let paramCount = 2;
        
        if (subscription_status) {
            updates.push(`subscription_status = $${paramCount}`);
            params.push(subscription_status);
            paramCount++;
        }
        
        if (subscription_end_date) {
            updates.push(`subscription_end_date = $${paramCount}`);
            params.push(subscription_end_date);
            paramCount++;
        }
        
        if (subscription_start_date) {
            updates.push(`subscription_start_date = $${paramCount}`);
            params.push(subscription_start_date);
            paramCount++;
        }
        
        if (updates.length === 0) {
            return res.status(400).json({ error: 'No updates provided' });
        }
        
        updates.push('updated_at = NOW()');
        
        await pool.query(`
            UPDATE users 
            SET ${updates.join(', ')}
            WHERE user_id = $1
        `, params);
        
        // Log the action
        await pool.query(`
            INSERT INTO subscription_history (user_id, event_type, metadata)
            VALUES ($1, 'membership_updated_by_admin', $2)
        `, [userId, JSON.stringify({ 
            updates: req.body, 
            admin: req.admin.username 
        })]);
        
        res.json({ 
            success: true, 
            message: 'Membership updated successfully'
        });
        
    } catch (error) {
        console.error('Error updating membership:', error);
        res.status(500).json({ error: 'Failed to update membership' });
    }
});

// MARK: - Promo Code Management

/**
 * GET /api/admin/promo-codes
 * Get all promo codes
 */
router.get('/promo-codes', requireAdmin, async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT 
                pc.*,
                COUNT(pcu.id) as total_uses
            FROM promo_codes pc
            LEFT JOIN promo_code_usage pcu ON pc.id = pcu.promo_code_id
            GROUP BY pc.id
            ORDER BY pc.created_at DESC
        `);
        
        res.json({ promo_codes: result.rows });
        
    } catch (error) {
        console.error('Error fetching promo codes:', error);
        res.status(500).json({ error: 'Failed to fetch promo codes' });
    }
});

/**
 * POST /api/admin/promo-codes
 * Create a new promo code
 */
router.post('/promo-codes', requireAdmin, async (req, res) => {
    try {
        const { code, duration_days, uses_total, description, expires_at } = req.body;
        
        if (!code || !duration_days) {
            return res.status(400).json({ error: 'Code and duration are required' });
        }
        
        // Check if code already exists
        const existing = await pool.query(
            'SELECT * FROM promo_codes WHERE code = $1',
            [code.toUpperCase()]
        );
        
        if (existing.rows.length > 0) {
            return res.status(400).json({ error: 'Promo code already exists' });
        }
        
        const result = await pool.query(`
            INSERT INTO promo_codes 
            (code, duration_days, uses_total, uses_remaining, description, expires_at, created_by)
            VALUES ($1, $2, $3, $3, $4, $5, $6)
            RETURNING *
        `, [
            code.toUpperCase(), 
            duration_days, 
            uses_total || -1, 
            description || null,
            expires_at || null,
            req.admin.username
        ]);
        
        res.json({ 
            success: true, 
            promo_code: result.rows[0],
            message: 'Promo code created successfully'
        });
        
    } catch (error) {
        console.error('Error creating promo code:', error);
        res.status(500).json({ error: 'Failed to create promo code' });
    }
});

/**
 * PUT /api/admin/promo-codes/:codeId
 * Update a promo code
 */
router.put('/promo-codes/:codeId', requireAdmin, async (req, res) => {
    try {
        const { codeId } = req.params;
        const { active, uses_total, expires_at } = req.body;
        
        const updates = [];
        const params = [];
        let paramCount = 1;
        
        if (typeof active !== 'undefined') {
            updates.push(`active = $${paramCount}`);
            params.push(active);
            paramCount++;
        }
        
        if (typeof uses_total !== 'undefined') {
            updates.push(`uses_total = $${paramCount}`);
            params.push(uses_total);
            paramCount++;
        }
        
        if (expires_at !== undefined) {
            updates.push(`expires_at = $${paramCount}`);
            params.push(expires_at);
            paramCount++;
        }
        
        if (updates.length === 0) {
            return res.status(400).json({ error: 'No updates provided' });
        }
        
        params.push(codeId);
        
        await pool.query(`
            UPDATE promo_codes 
            SET ${updates.join(', ')}
            WHERE id = $${paramCount}
        `, params);
        
        res.json({ success: true, message: 'Promo code updated' });
        
    } catch (error) {
        console.error('Error updating promo code:', error);
        res.status(500).json({ error: 'Failed to update promo code' });
    }
});

/**
 * DELETE /api/admin/promo-codes/:codeId
 * Delete a promo code
 */
router.delete('/promo-codes/:codeId', requireAdmin, async (req, res) => {
    try {
        const { codeId } = req.params;
        
        await pool.query('DELETE FROM promo_codes WHERE id = $1', [codeId]);
        
        res.json({ success: true, message: 'Promo code deleted' });
        
    } catch (error) {
        console.error('Error deleting promo code:', error);
        res.status(500).json({ error: 'Failed to delete promo code' });
    }
});

// MARK: - Analytics

/**
 * GET /api/admin/stats
 * Get dashboard statistics
 */
router.get('/stats', requireAdmin, async (req, res) => {
    try {
        // Total users
        const totalUsersResult = await pool.query('SELECT COUNT(*) FROM users');
        
        // Active subscriptions
        const activeSubsResult = await pool.query(`
            SELECT COUNT(*) FROM users 
            WHERE subscription_end_date > NOW() AND is_active = true
        `);
        
        // Trial users
        const trialUsersResult = await pool.query(`
            SELECT COUNT(*) FROM users 
            WHERE subscription_status = 'trial'
        `);
        
        // Expired subscriptions
        const expiredResult = await pool.query(`
            SELECT COUNT(*) FROM users 
            WHERE subscription_end_date < NOW()
        `);
        
        // Revenue (would come from payment provider)
        // This is a placeholder
        const revenue = 0;
        
        // Recent signups (last 30 days)
        const recentSignupsResult = await pool.query(`
            SELECT COUNT(*) FROM users 
            WHERE created_at > NOW() - INTERVAL '30 days'
        `);
        
        res.json({
            total_users: parseInt(totalUsersResult.rows[0].count),
            active_subscriptions: parseInt(activeSubsResult.rows[0].count),
            trial_users: parseInt(trialUsersResult.rows[0].count),
            expired_subscriptions: parseInt(expiredResult.rows[0].count),
            recent_signups_30d: parseInt(recentSignupsResult.rows[0].count),
            total_revenue: revenue
        });
        
    } catch (error) {
        console.error('Error fetching stats:', error);
        res.status(500).json({ error: 'Failed to fetch statistics' });
    }
});

/**
 * POST /api/admin/migrate-usage-tracking
 * Apply usage tracking database migration (admin only)
 */
router.post('/migrate-usage-tracking', requireAdmin, async (req, res) => {
    try {
        console.log('🚀 Starting Usage Tracking Migration...');

        const fs = require('fs');
        const path = require('path');
        
        // Read the migration SQL file
        const migrationPath = path.join(__dirname, '..', 'database', 'usage-tracking-migration.sql');
        const migrationSQL = fs.readFileSync(migrationPath, 'utf8');

        console.log('📄 Migration file loaded successfully');

        // Execute the migration
        await pool.query(migrationSQL);

        console.log('✅ Migration applied successfully!');

        // Verify tables were created
        const checkResult = await pool.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'user_api_usage';
        `);

        const tableExists = checkResult.rows.length > 0;

        res.json({
            success: true,
            message: 'Usage tracking migration applied successfully',
            details: {
                tableCreated: tableExists,
                tables: ['user_api_usage'],
                views: [
                    'user_usage_summary',
                    'monthly_usage_summary', 
                    'endpoint_usage_summary',
                    'daily_usage_summary'
                ]
            }
        });

    } catch (error) {
        console.error('❌ Migration failed:', error);
        res.status(500).json({
            success: false,
            error: 'Migration failed',
            details: error.message
        });
    }
});

module.exports = router;

