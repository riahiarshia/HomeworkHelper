const express = require('express');
const router = express.Router();
const { requireAdmin } = require('../middleware/adminAuth');
const { getDeviceAnalytics, getFraudFlags } = require('../services/deviceTrackingService');

/**
 * GET /api/admin/devices/analytics
 * Get device analytics for admin dashboard
 */
router.get('/analytics', requireAdmin, async (req, res) => {
    try {
        const limit = parseInt(req.query.limit) || 50;
        const analytics = await getDeviceAnalytics(limit);
        
        res.json({
            success: true,
            data: analytics,
            total: analytics.length
        });
        
    } catch (error) {
        console.error('Error fetching device analytics:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch device analytics'
        });
    }
});

/**
 * GET /api/admin/devices/fraud-flags
 * Get fraud flags for admin review
 */
router.get('/fraud-flags', requireAdmin, async (req, res) => {
    try {
        const unresolvedOnly = req.query.unresolved !== 'false';
        const flags = await getFraudFlags(unresolvedOnly);
        
        res.json({
            success: true,
            data: flags,
            total: flags.length,
            unresolvedOnly
        });
        
    } catch (error) {
        console.error('Error fetching fraud flags:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch fraud flags'
        });
    }
});

/**
 * GET /api/admin/devices/shared-details
 * Get detailed information about which users share which devices
 */
router.get('/shared-details', requireAdmin, async (req, res) => {
    try {
        const { Pool } = require('pg');
        const pool = new Pool({
            connectionString: process.env.DATABASE_URL,
            ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
        });
        
        // Get devices with multiple users and show which users share them
        const result = await pool.query(`
            SELECT 
                ud.device_id,
                ud.device_name,
                COUNT(DISTINCT ud.user_id) as user_count,
                MIN(ud.first_seen) as first_seen,
                MAX(ud.last_seen) as last_seen,
                SUM(ud.login_count) as total_logins,
                json_agg(
                    json_build_object(
                        'user_id', u.user_id,
                        'email', u.email,
                        'username', u.username,
                        'auth_provider', u.auth_provider,
                        'subscription_status', u.subscription_status,
                        'is_active', u.is_active,
                        'login_count', ud.login_count,
                        'last_login', ud.last_seen
                    ) ORDER BY ud.last_seen DESC
                ) as users
            FROM user_devices ud
            JOIN users u ON ud.user_id = u.user_id
            GROUP BY ud.device_id, ud.device_name
            HAVING COUNT(DISTINCT ud.user_id) > 1
            ORDER BY COUNT(DISTINCT ud.user_id) DESC, MAX(ud.last_seen) DESC
            LIMIT 100
        `);
        
        res.json({
            success: true,
            data: result.rows,
            total: result.rows.length
        });
        
    } catch (error) {
        console.error('Error fetching shared device details:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch shared device details',
            message: error.message
        });
    }
});

module.exports = router;
