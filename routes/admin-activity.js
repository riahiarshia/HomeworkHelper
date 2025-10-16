const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const { requireAdmin } = require('../middleware/adminAuth');

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

/**
 * GET /api/admin/activity/user/:userId
 * Get detailed activity metrics for a specific user
 */
router.get('/user/:userId', requireAdmin, async (req, res) => {
    try {
        const { userId } = req.params;
        
        // Get user activity metrics
        const activityQuery = await pool.query(`
            SELECT 
                u.user_id,
                u.email,
                u.username,
                u.auth_provider,
                u.subscription_status,
                u.created_at,
                u.last_active_at,
                
                -- Login metrics
                (SELECT COUNT(*) FROM device_logins WHERE user_id = u.user_id) as total_logins,
                (SELECT COUNT(*) FROM device_logins WHERE user_id = u.user_id AND login_time > NOW() - INTERVAL '7 days') as logins_last_7_days,
                (SELECT COUNT(*) FROM device_logins WHERE user_id = u.user_id AND login_time > NOW() - INTERVAL '30 days') as logins_last_30_days,
                (SELECT MAX(login_time) FROM device_logins WHERE user_id = u.user_id) as last_login,
                
                -- Device count
                (SELECT COUNT(DISTINCT device_id) FROM device_logins WHERE user_id = u.user_id) as unique_devices_used,
                
                -- Calculate days since signup
                EXTRACT(DAY FROM (NOW() - u.created_at)) as days_since_signup,
                
                -- Calculate average logins per day
                CASE 
                    WHEN EXTRACT(DAY FROM (NOW() - u.created_at)) > 0 
                    THEN (SELECT COUNT(*) FROM device_logins WHERE user_id = u.user_id)::float / EXTRACT(DAY FROM (NOW() - u.created_at))
                    ELSE 0
                END as avg_logins_per_day
                
            FROM users u
            WHERE u.user_id = $1
        `, [userId]);
        
        if (activityQuery.rows.length === 0) {
            return res.status(404).json({
                success: false,
                error: 'User not found'
            });
        }
        
        const userData = activityQuery.rows[0];
        
        // Get recent login history
        const recentLoginsQuery = await pool.query(`
            SELECT 
                login_time,
                device_id,
                ip_address,
                device_info
            FROM device_logins
            WHERE user_id = $1
            ORDER BY login_time DESC
            LIMIT 20
        `, [userId]);
        
        res.json({
            success: true,
            data: {
                user: userData,
                recentLogins: recentLoginsQuery.rows
            }
        });
        
    } catch (error) {
        console.error('Error fetching user activity:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch user activity',
            message: error.message
        });
    }
});

/**
 * GET /api/admin/activity/overview
 * Get activity overview for all users
 */
router.get('/overview', requireAdmin, async (req, res) => {
    try {
        const limit = parseInt(req.query.limit) || 100;
        const sortBy = req.query.sortBy || 'total_logins'; // total_logins, last_active, avg_logins_per_day
        
        const query = await pool.query(`
            SELECT 
                u.user_id,
                u.email,
                u.username,
                u.auth_provider,
                u.subscription_status,
                u.is_active,
                u.created_at,
                u.last_active_at,
                
                -- Login metrics
                COALESCE((SELECT COUNT(*) FROM device_logins WHERE user_id = u.user_id), 0) as total_logins,
                COALESCE((SELECT COUNT(*) FROM device_logins WHERE user_id = u.user_id AND login_time > NOW() - INTERVAL '7 days'), 0) as logins_last_7_days,
                COALESCE((SELECT COUNT(*) FROM device_logins WHERE user_id = u.user_id AND login_time > NOW() - INTERVAL '30 days'), 0) as logins_last_30_days,
                (SELECT MAX(login_time) FROM device_logins WHERE user_id = u.user_id) as last_login,
                
                -- Device count
                COALESCE((SELECT COUNT(DISTINCT device_id) FROM device_logins WHERE user_id = u.user_id), 0) as unique_devices_used,
                
                -- Calculate days since signup
                EXTRACT(DAY FROM (NOW() - u.created_at)) as days_since_signup,
                
                -- Calculate average logins per day
                CASE 
                    WHEN EXTRACT(DAY FROM (NOW() - u.created_at)) > 0 
                    THEN COALESCE((SELECT COUNT(*) FROM device_logins WHERE user_id = u.user_id)::float / EXTRACT(DAY FROM (NOW() - u.created_at)), 0)
                    ELSE 0
                END as avg_logins_per_day
                
            FROM users u
            ORDER BY 
                CASE 
                    WHEN $1 = 'total_logins' THEN COALESCE((SELECT COUNT(*) FROM device_logins WHERE user_id = u.user_id), 0)
                    WHEN $1 = 'avg_logins_per_day' THEN 
                        CASE 
                            WHEN EXTRACT(DAY FROM (NOW() - u.created_at)) > 0 
                            THEN COALESCE((SELECT COUNT(*) FROM device_logins WHERE user_id = u.user_id)::float / EXTRACT(DAY FROM (NOW() - u.created_at)), 0)
                            ELSE 0
                        END
                    ELSE 0
                END DESC,
                u.last_active_at DESC NULLS LAST
            LIMIT $2
        `, [sortBy, limit]);
        
        res.json({
            success: true,
            data: query.rows,
            total: query.rows.length,
            sortBy
        });
        
    } catch (error) {
        console.error('Error fetching activity overview:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch activity overview',
            message: error.message
        });
    }
});

/**
 * GET /api/admin/activity/stats
 * Get overall activity statistics
 */
router.get('/stats', requireAdmin, async (req, res) => {
    try {
        const statsQuery = await pool.query(`
            SELECT 
                COUNT(DISTINCT u.user_id) as total_users,
                COUNT(DISTINCT CASE WHEN u.last_active_at > NOW() - INTERVAL '7 days' THEN u.user_id END) as active_users_7_days,
                COUNT(DISTINCT CASE WHEN u.last_active_at > NOW() - INTERVAL '30 days' THEN u.user_id END) as active_users_30_days,
                COALESCE((SELECT COUNT(*) FROM device_logins), 0) as total_logins,
                COALESCE((SELECT COUNT(*) FROM device_logins WHERE login_time > NOW() - INTERVAL '7 days'), 0) as logins_last_7_days,
                COALESCE((SELECT COUNT(*) FROM device_logins WHERE login_time > NOW() - INTERVAL '30 days'), 0) as logins_last_30_days,
                COALESCE((SELECT COUNT(DISTINCT device_id) FROM device_logins), 0) as unique_devices,
                COALESCE(AVG((SELECT COUNT(*) FROM device_logins dl WHERE dl.user_id = u.user_id)), 0) as avg_logins_per_user
            FROM users u
        `);
        
        res.json({
            success: true,
            data: statsQuery.rows[0]
        });
        
    } catch (error) {
        console.error('Error fetching activity stats:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch activity stats',
            message: error.message
        });
    }
});

module.exports = router;
