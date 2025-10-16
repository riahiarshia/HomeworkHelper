/**
 * Debug Routes for Development
 * These endpoints help debug issues without authentication
 */

const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

/**
 * GET /api/debug/device-data
 * Check device tracking data for specific users
 */
router.get('/device-data', async (req, res) => {
    try {
        const { userId } = req.query;
        
        let query = `
            SELECT 
                dl.user_id,
                dl.device_id,
                dl.login_time,
                dl.ip_address,
                dl.user_agent,
                dl.device_info
            FROM device_logins dl
        `;
        
        const params = [];
        if (userId) {
            query += ` WHERE dl.user_id = $1`;
            params.push(userId);
        }
        
        query += ` ORDER BY dl.login_time DESC LIMIT 50`;
        
        const result = await pool.query(query, params);
        
        res.json({
            success: true,
            data: result.rows,
            total: result.rows.length,
            userId: userId || 'all'
        });
        
    } catch (error) {
        console.error('Error fetching device data:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * GET /api/debug/shared-devices
 * Check for devices shared between specific users
 */
router.get('/shared-devices', async (req, res) => {
    try {
        const { userId1, userId2 } = req.query;
        
        if (!userId1 || !userId2) {
            return res.status(400).json({
                success: false,
                error: 'Both userId1 and userId2 are required'
            });
        }
        
        // Find devices shared between the two users
        const result = await pool.query(`
            SELECT 
                device_id,
                COUNT(DISTINCT user_id) as user_count,
                STRING_AGG(DISTINCT user_id, ', ') as users,
                MIN(login_time) as first_shared,
                MAX(login_time) as last_shared,
                COUNT(*) as total_logins
            FROM device_logins 
            WHERE user_id IN ($1, $2)
            GROUP BY device_id
            HAVING COUNT(DISTINCT user_id) > 1
            ORDER BY last_shared DESC
        `, [userId1, userId2]);
        
        res.json({
            success: true,
            data: result.rows,
            total: result.rows.length,
            userId1,
            userId2
        });
        
    } catch (error) {
        console.error('Error checking shared devices:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * GET /api/debug/user-devices
 * Check user_devices table for specific users
 */
router.get('/user-devices', async (req, res) => {
    try {
        const { userId } = req.query;
        
        let query = `
            SELECT 
                ud.user_id,
                ud.device_id,
                ud.device_name,
                ud.is_trusted,
                ud.first_seen,
                ud.last_seen,
                ud.login_count
            FROM user_devices ud
        `;
        
        const params = [];
        if (userId) {
            query += ` WHERE ud.user_id = $1`;
            params.push(userId);
        }
        
        query += ` ORDER BY ud.last_seen DESC LIMIT 50`;
        
        const result = await pool.query(query, params);
        
        res.json({
            success: true,
            data: result.rows,
            total: result.rows.length,
            userId: userId || 'all'
        });
        
    } catch (error) {
        console.error('Error fetching user devices:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

module.exports = router;