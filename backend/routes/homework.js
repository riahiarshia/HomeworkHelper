const express = require('express');
const router = express.Router();
const authenticateUser = require('../middleware/auth');
const { requireAdmin } = require('../middleware/adminAuth');
const {
    trackHomeworkSubmission,
    updateHomeworkCompletion,
    getUserHomeworkStats,
    getAllHomeworkSubmissions
} = require('../services/homeworkTrackingService');

/**
 * POST /api/homework/submit
 * Track a new homework submission
 */
router.post('/submit', authenticateUser, async (req, res) => {
    try {
        const userId = req.user.userId;
        const homeworkData = req.body;
        
        console.log(`📝 Homework submission request from user: ${userId}`);
        
        // Validate required fields
        if (!homeworkData.problemId) {
            return res.status(400).json({ error: 'Problem ID is required' });
        }
        
        const result = await trackHomeworkSubmission(userId, homeworkData);
        
        res.json({
            success: true,
            submissionId: result.submissionId,
            submittedAt: result.submittedAt,
            totalSubmissions: result.totalSubmissions,
            message: 'Homework submission tracked successfully'
        });
        
    } catch (error) {
        console.error('❌ Error in homework submit endpoint:', error);
        res.status(500).json({ error: 'Failed to track homework submission' });
    }
});

/**
 * PUT /api/homework/complete/:problemId
 * Update homework completion status
 */
router.put('/complete/:problemId', authenticateUser, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { problemId } = req.params;
        const completionData = req.body;
        
        console.log(`✅ Homework completion request from user: ${userId}, problem: ${problemId}`);
        
        const submissionId = await updateHomeworkCompletion(userId, problemId, completionData);
        
        if (submissionId) {
            res.json({
                success: true,
                submissionId,
                message: 'Homework completion updated successfully'
            });
        } else {
            res.status(404).json({ error: 'No active submission found for this problem' });
        }
        
    } catch (error) {
        console.error('❌ Error in homework complete endpoint:', error);
        res.status(500).json({ error: 'Failed to update homework completion' });
    }
});

/**
 * GET /api/homework/stats
 * Get user's homework submission statistics
 */
router.get('/stats', authenticateUser, async (req, res) => {
    try {
        const userId = req.user.userId;
        
        console.log(`📊 Homework stats request from user: ${userId}`);
        
        const stats = await getUserHomeworkStats(userId);
        
        res.json({
            success: true,
            stats
        });
        
    } catch (error) {
        console.error('❌ Error in homework stats endpoint:', error);
        res.status(500).json({ error: 'Failed to fetch homework statistics' });
    }
});

/**
 * GET /api/homework/admin/submissions
 * Get all homework submissions (admin only)
 */
router.get('/admin/submissions', requireAdmin, async (req, res) => {
    try {
        const {
            userId,
            subject,
            status,
            startDate,
            endDate,
            limit,
            offset
        } = req.query;
        
        console.log(`📊 Admin homework submissions request`);
        
        const filters = {
            userId,
            subject,
            status,
            startDate,
            endDate,
            limit: limit ? parseInt(limit) : 100,
            offset: offset ? parseInt(offset) : 0
        };
        
        const result = await getAllHomeworkSubmissions(filters);
        
        res.json({
            success: true,
            ...result
        });
        
    } catch (error) {
        console.error('❌ Error in admin homework submissions endpoint:', error);
        res.status(500).json({ error: 'Failed to fetch homework submissions' });
    }
});

/**
 * GET /api/homework/admin/stats/:userId
 * Get specific user's homework stats (admin only)
 */
router.get('/admin/stats/:userId', requireAdmin, async (req, res) => {
    try {
        const { userId } = req.params;
        
        console.log(`📊 Admin requesting homework stats for user: ${userId}`);
        
        const stats = await getUserHomeworkStats(userId);
        
        res.json({
            success: true,
            userId,
            stats
        });
        
    } catch (error) {
        console.error('❌ Error in admin homework stats endpoint:', error);
        res.status(500).json({ error: 'Failed to fetch user homework statistics' });
    }
});

module.exports = router;

