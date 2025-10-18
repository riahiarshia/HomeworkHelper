const express = require('express');
const router = express.Router();
const { requireAdmin } = require('../middleware/adminAuth');
const usageTrackingService = require('../services/usageTrackingService');
const { Parser } = require('json2csv');
const { Pool } = require('pg');

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

/**
 * GET /api/usage/summary
 * Get all users' usage summary (admin only)
 */
router.get('/summary', requireAdmin, async (req, res) => {
    try {
        const { limit = 100, offset = 0, sortBy = 'total_cost', order = 'DESC' } = req.query;
        
        const result = await usageTrackingService.getAllUsageSummary({
            limit: parseInt(limit),
            offset: parseInt(offset),
            sortBy,
            order
        });
        
        res.json({
            success: true,
            data: result
        });
    } catch (error) {
        console.error('❌ Error getting usage summary:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to retrieve usage summary'
        });
    }
});

/**
 * GET /api/usage/user/:userId
 * Get specific user's usage details (admin only)
 */
router.get('/user/:userId', requireAdmin, async (req, res) => {
    try {
        const { userId } = req.params;
        
        const totalUsage = await usageTrackingService.getUserUsage(userId);
        const monthlyUsage = await usageTrackingService.getUserMonthlyUsage(userId);
        
        res.json({
            success: true,
            data: {
                userId: parseInt(userId),
                total: totalUsage,
                monthly: monthlyUsage
            }
        });
    } catch (error) {
        console.error('❌ Error getting user usage:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to retrieve user usage'
        });
    }
});

/**
 * GET /api/usage/user/:userId/cycle-stats
 * Get detailed billing cycle statistics for a specific user (admin only)
 */
router.get('/user/:userId/cycle-stats', requireAdmin, async (req, res) => {
    try {
        const { userId } = req.params;
        
        console.log(`📊 Fetching billing cycle stats for user: ${userId}`);
        
        // Get user's subscription info
        const userResult = await pool.query(`
            SELECT 
                user_id,
                username,
                email,
                subscription_status,
                subscription_start_date,
                subscription_end_date,
                created_at
            FROM users
            WHERE user_id::text = $1
        `, [userId]);
        
        if (userResult.rows.length === 0) {
            return res.status(404).json({
                success: false,
                error: 'User not found'
            });
        }
        
        const user = userResult.rows[0];
        const currentCycleStart = user.subscription_start_date;
        const currentCycleEnd = user.subscription_end_date;
        
        // Calculate revenue based on subscription status
        let revenue = 0;
        if (user.subscription_status === 'active' || user.subscription_status === 'promo_active') {
            revenue = 9.99; // Monthly subscription price
        } else if (user.subscription_status === 'trial') {
            revenue = 0; // Trial is free
        }
        
        // Get current cycle usage
        const currentCycleResult = await pool.query(`
            SELECT 
                COUNT(*) as total_calls,
                SUM(prompt_tokens) as total_prompt_tokens,
                SUM(completion_tokens) as total_completion_tokens,
                SUM(total_tokens) as total_tokens,
                SUM(cost_usd) as total_cost,
                MAX(created_at) as last_call,
                MIN(created_at) as first_call
            FROM user_api_usage
            WHERE user_id = $1
            AND created_at >= $2
            AND created_at < $3
        `, [userId, currentCycleStart, currentCycleEnd]);
        
        // Get current cycle breakdown by endpoint
        const endpointBreakdownResult = await pool.query(`
            SELECT 
                endpoint,
                model,
                COUNT(*) as calls,
                SUM(total_tokens) as tokens,
                SUM(cost_usd) as cost
            FROM user_api_usage
            WHERE user_id = $1
            AND created_at >= $2
            AND created_at < $3
            GROUP BY endpoint, model
            ORDER BY cost DESC
        `, [userId, currentCycleStart, currentCycleEnd]);
        
        // Get current cycle breakdown by device
        const deviceBreakdownResult = await pool.query(`
            SELECT 
                device_id,
                COUNT(*) as calls,
                SUM(total_tokens) as tokens,
                SUM(cost_usd) as cost,
                MAX(created_at) as last_used
            FROM user_api_usage
            WHERE user_id = $1
            AND created_at >= $2
            AND created_at < $3
            AND device_id IS NOT NULL
            GROUP BY device_id
            ORDER BY cost DESC
        `, [userId, currentCycleStart, currentCycleEnd]);
        
        // Get historical cycles (last 6 months of subscription periods)
        // This is a simplified version - you may want to query subscription_history table if you have it
        const historicalCyclesResult = await pool.query(`
            SELECT 
                DATE_TRUNC('month', created_at) as period_start,
                COUNT(*) as calls,
                SUM(total_tokens) as tokens,
                SUM(cost_usd) as cost
            FROM user_api_usage
            WHERE user_id = $1
            AND created_at < $2
            GROUP BY DATE_TRUNC('month', created_at)
            ORDER BY period_start DESC
            LIMIT 6
        `, [userId, currentCycleStart]);
        
        // Get all-time totals
        const allTimeResult = await pool.query(`
            SELECT 
                COUNT(*) as total_calls,
                SUM(total_tokens) as total_tokens,
                SUM(cost_usd) as total_cost,
                MAX(created_at) as last_call,
                MIN(created_at) as first_call
            FROM user_api_usage
            WHERE user_id = $1
        `, [userId]);
        
        const currentCycle = currentCycleResult.rows[0];
        const cycleCost = parseFloat(currentCycle.total_cost) || 0;
        const profit = revenue - cycleCost;
        const profitMargin = revenue > 0 ? (profit / revenue) * 100 : 0;
        
        // Calculate days remaining in cycle
        const now = new Date();
        const endDate = new Date(currentCycleEnd);
        const daysRemaining = Math.max(0, Math.ceil((endDate - now) / (1000 * 60 * 60 * 24)));
        
        res.json({
            success: true,
            data: {
                user: {
                    user_id: user.user_id,
                    username: user.username,
                    email: user.email,
                    subscription_status: user.subscription_status,
                    member_since: user.created_at
                },
                currentCycle: {
                    start_date: currentCycleStart,
                    end_date: currentCycleEnd,
                    days_remaining: daysRemaining,
                    revenue: revenue,
                    calls: parseInt(currentCycle.total_calls) || 0,
                    tokens: parseInt(currentCycle.total_tokens) || 0,
                    cost: cycleCost,
                    profit: profit,
                    profit_margin: profitMargin,
                    first_call: currentCycle.first_call,
                    last_call: currentCycle.last_call
                },
                endpointBreakdown: endpointBreakdownResult.rows,
                deviceBreakdown: deviceBreakdownResult.rows,
                historicalCycles: historicalCyclesResult.rows,
                allTime: allTimeResult.rows[0]
            }
        });
        
    } catch (error) {
        console.error('❌ Error getting billing cycle stats:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to retrieve billing cycle statistics',
            details: error.message
        });
    }
});

/**
 * GET /api/usage/endpoint
 * Get usage statistics by endpoint (admin only)
 */
router.get('/endpoint', requireAdmin, async (req, res) => {
    try {
        const result = await usageTrackingService.getEndpointUsage();
        
        res.json({
            success: true,
            data: result
        });
    } catch (error) {
        console.error('❌ Error getting endpoint usage:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to retrieve endpoint usage'
        });
    }
});

/**
 * GET /api/usage/daily
 * Get daily usage statistics (admin only)
 */
router.get('/daily', requireAdmin, async (req, res) => {
    try {
        const { days = 30 } = req.query;
        
        const result = await usageTrackingService.getDailyUsage(parseInt(days));
        
        res.json({
            success: true,
            data: result
        });
    } catch (error) {
        console.error('❌ Error getting daily usage:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to retrieve daily usage'
        });
    }
});

/**
 * GET /api/usage/export
 * Export usage data to CSV (admin only)
 */
router.get('/export', requireAdmin, async (req, res) => {
    try {
        const { startDate, endDate, userId, format = 'csv' } = req.query;
        
        // Get detailed usage data
        const records = await usageTrackingService.getDetailedUsageForExport({
            startDate,
            endDate,
            userId: userId ? parseInt(userId) : null,
            limit: 50000 // Max 50k records per export
        });
        
        if (records.length === 0) {
            return res.status(404).json({
                success: false,
                error: 'No usage data found for the specified criteria'
            });
        }
        
        // Define CSV fields
        const fields = [
            { label: 'ID', value: 'id' },
            { label: 'User ID', value: 'user_id' },
            { label: 'Username', value: 'username' },
            { label: 'Email', value: 'email' },
            { label: 'Endpoint', value: 'endpoint' },
            { label: 'Model', value: 'model' },
            { label: 'Prompt Tokens', value: 'prompt_tokens' },
            { label: 'Completion Tokens', value: 'completion_tokens' },
            { label: 'Total Tokens', value: 'total_tokens' },
            { label: 'Cost (USD)', value: 'cost_usd' },
            { label: 'Problem ID', value: 'problem_id' },
            { label: 'Session ID', value: 'session_id' },
            { label: 'Timestamp', value: 'created_at' }
        ];
        
        // Convert to CSV
        const json2csvParser = new Parser({ fields });
        const csv = json2csvParser.parse(records);
        
        // Set response headers for file download
        const filename = `usage_export_${new Date().toISOString().split('T')[0]}.csv`;
        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
        
        res.send(csv);
    } catch (error) {
        console.error('❌ Error exporting usage data:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to export usage data'
        });
    }
});

/**
 * GET /api/usage/export/summary
 * Export user summary data to CSV (admin only)
 */
router.get('/export/summary', requireAdmin, async (req, res) => {
    try {
        // Get all users' summary
        const result = await usageTrackingService.getAllUsageSummary({
            limit: 10000,
            offset: 0,
            sortBy: 'total_cost',
            order: 'DESC'
        });
        
        if (result.users.length === 0) {
            return res.status(404).json({
                success: false,
                error: 'No usage data found'
            });
        }
        
        // Define CSV fields
        const fields = [
            { label: 'User ID', value: 'user_id' },
            { label: 'Username', value: 'username' },
            { label: 'Email', value: 'email' },
            { label: 'Total API Calls', value: 'total_calls' },
            { label: 'Total Prompt Tokens', value: 'total_prompt_tokens' },
            { label: 'Total Completion Tokens', value: 'total_completion_tokens' },
            { label: 'Total Tokens', value: 'total_tokens' },
            { label: 'Total Cost (USD)', value: 'total_cost' },
            { label: 'First API Call', value: 'first_call' },
            { label: 'Last API Call', value: 'last_call' }
        ];
        
        // Convert to CSV
        const json2csvParser = new Parser({ fields });
        const csv = json2csvParser.parse(result.users);
        
        // Set response headers for file download
        const filename = `usage_summary_${new Date().toISOString().split('T')[0]}.csv`;
        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
        
        res.send(csv);
    } catch (error) {
        console.error('❌ Error exporting summary data:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to export summary data'
        });
    }
});

/**
 * GET /api/usage/stats
 * Get overall platform statistics (admin only)
 */
router.get('/stats', requireAdmin, async (req, res) => {
    try {
        // Get overall statistics
        const statsResult = await pool.query(`
            SELECT 
                COUNT(*) as total_api_calls,
                COUNT(DISTINCT user_id) as total_users,
                SUM(prompt_tokens) as total_prompt_tokens,
                SUM(completion_tokens) as total_completion_tokens,
                SUM(total_tokens) as total_tokens,
                SUM(cost_usd) as total_cost,
                AVG(cost_usd) as avg_cost_per_call,
                MAX(created_at) as last_api_call
            FROM user_api_usage
        `);
        
        // Get monthly statistics
        const monthlyStatsResult = await pool.query(`
            SELECT 
                COUNT(*) as monthly_api_calls,
                COUNT(DISTINCT user_id) as monthly_users,
                SUM(total_tokens) as monthly_tokens,
                SUM(cost_usd) as monthly_cost
            FROM user_api_usage
            WHERE created_at >= DATE_TRUNC('month', NOW())
        `);
        
        // Get today's statistics
        const dailyStatsResult = await pool.query(`
            SELECT 
                COUNT(*) as daily_api_calls,
                COUNT(DISTINCT user_id) as daily_users,
                SUM(total_tokens) as daily_tokens,
                SUM(cost_usd) as daily_cost
            FROM user_api_usage
            WHERE created_at >= CURRENT_DATE
        `);
        
        res.json({
            success: true,
            data: {
                overall: statsResult.rows[0],
                monthly: monthlyStatsResult.rows[0],
                daily: dailyStatsResult.rows[0]
            }
        });
    } catch (error) {
        console.error('❌ Error getting platform stats:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to retrieve platform statistics'
        });
    }
});

module.exports = router;

