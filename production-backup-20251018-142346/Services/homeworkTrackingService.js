const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

/**
 * Track a homework submission
 * This creates a permanent record even if user deletes the problem from their app
 */
async function trackHomeworkSubmission(userId, homeworkData) {
    try {
        console.log(`📝 Tracking homework submission for user: ${userId}`);
        
        const {
            problemId,
            subject,
            problemText,
            imageFilename,
            totalSteps = 0,
            completedSteps = 0,
            skippedSteps = 0,
            status = 'submitted',
            timeSpentSeconds = 0,
            hintsUsed = 0
        } = homeworkData;
        
        // Insert homework submission record
        const submissionResult = await pool.query(`
            INSERT INTO homework_submissions (
                user_id, problem_id, subject, problem_text, image_filename,
                total_steps, completed_steps, skipped_steps, status,
                time_spent_seconds, hints_used, submitted_at
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, NOW())
            RETURNING submission_id, submitted_at
        `, [
            userId,
            problemId,
            subject,
            problemText,
            imageFilename,
            totalSteps,
            completedSteps,
            skippedSteps,
            status,
            timeSpentSeconds,
            hintsUsed
        ]);
        
        // Increment user's total submission counter
        await pool.query(`
            UPDATE users 
            SET total_homework_submissions = total_homework_submissions + 1
            WHERE user_id = $1
        `, [userId]);
        
        // Get updated count
        const countResult = await pool.query(`
            SELECT total_homework_submissions FROM users WHERE user_id = $1
        `, [userId]);
        
        const totalSubmissions = countResult.rows[0]?.total_homework_submissions || 0;
        
        console.log(`✅ Homework submission tracked successfully`);
        console.log(`   Submission ID: ${submissionResult.rows[0].submission_id}`);
        console.log(`   User total submissions: ${totalSubmissions}`);
        
        return {
            submissionId: submissionResult.rows[0].submission_id,
            submittedAt: submissionResult.rows[0].submitted_at,
            totalSubmissions: totalSubmissions
        };
        
    } catch (error) {
        console.error('❌ Error tracking homework submission:', error);
        throw error;
    }
}

/**
 * Update homework submission when completed
 */
async function updateHomeworkCompletion(userId, problemId, completionData) {
    try {
        console.log(`✅ Updating homework completion for user: ${userId}, problem: ${problemId}`);
        
        const {
            completedSteps = 0,
            skippedSteps = 0,
            status = 'completed',
            timeSpentSeconds = 0,
            hintsUsed = 0
        } = completionData;
        
        // Update the most recent submission for this problem
        const result = await pool.query(`
            UPDATE homework_submissions 
            SET 
                completed_steps = $1,
                skipped_steps = $2,
                status = $3,
                time_spent_seconds = $4,
                hints_used = $5,
                completed_at = NOW()
            WHERE user_id = $6 
            AND problem_id = $7
            AND completed_at IS NULL
            ORDER BY submitted_at DESC
            LIMIT 1
            RETURNING submission_id
        `, [
            completedSteps,
            skippedSteps,
            status,
            timeSpentSeconds,
            hintsUsed,
            userId,
            problemId
        ]);
        
        if (result.rows.length > 0) {
            console.log(`✅ Homework completion updated: ${result.rows[0].submission_id}`);
            return result.rows[0].submission_id;
        } else {
            console.log(`⚠️ No active submission found for problem: ${problemId}`);
            return null;
        }
        
    } catch (error) {
        console.error('❌ Error updating homework completion:', error);
        throw error;
    }
}

/**
 * Get user's homework submission statistics
 */
async function getUserHomeworkStats(userId) {
    try {
        console.log(`📊 Fetching homework stats for user: ${userId}`);
        
        // Get overall stats
        const statsResult = await pool.query(`
            SELECT 
                total_homework_submissions,
                (SELECT COUNT(*) FROM homework_submissions WHERE user_id = $1) as detailed_submission_count,
                (SELECT COUNT(*) FROM homework_submissions WHERE user_id = $1 AND status = 'completed') as completed_count,
                (SELECT COUNT(*) FROM homework_submissions WHERE user_id = $1 AND status = 'in_progress') as in_progress_count,
                (SELECT AVG(time_spent_seconds) FROM homework_submissions WHERE user_id = $1 AND status = 'completed') as avg_time_seconds,
                (SELECT AVG(hints_used) FROM homework_submissions WHERE user_id = $1) as avg_hints_used
            FROM users 
            WHERE user_id = $1
        `, [userId]);
        
        // Get submissions by subject
        const subjectResult = await pool.query(`
            SELECT 
                subject,
                COUNT(*) as count,
                AVG(completed_steps) as avg_completed_steps,
                AVG(time_spent_seconds) as avg_time_seconds
            FROM homework_submissions 
            WHERE user_id = $1
            GROUP BY subject
            ORDER BY count DESC
        `, [userId]);
        
        // Get recent submissions
        const recentResult = await pool.query(`
            SELECT 
                submission_id,
                problem_id,
                subject,
                status,
                total_steps,
                completed_steps,
                submitted_at,
                completed_at
            FROM homework_submissions 
            WHERE user_id = $1
            ORDER BY submitted_at DESC
            LIMIT 10
        `, [userId]);
        
        const stats = statsResult.rows[0] || {};
        
        return {
            totalSubmissions: stats.total_homework_submissions || 0,
            detailedSubmissionCount: stats.detailed_submission_count || 0,
            completedCount: stats.completed_count || 0,
            inProgressCount: stats.in_progress_count || 0,
            avgTimeSeconds: Math.round(stats.avg_time_seconds || 0),
            avgHintsUsed: Math.round(stats.avg_hints_used || 0),
            bySubject: subjectResult.rows,
            recentSubmissions: recentResult.rows
        };
        
    } catch (error) {
        console.error('❌ Error fetching homework stats:', error);
        throw error;
    }
}

/**
 * Get all homework submissions (for admin)
 */
async function getAllHomeworkSubmissions(filters = {}) {
    try {
        const { userId, subject, status, startDate, endDate, limit = 100, offset = 0 } = filters;
        
        let query = `
            SELECT 
                hs.submission_id,
                hs.user_id,
                u.username,
                u.email,
                hs.problem_id,
                hs.subject,
                hs.status,
                hs.total_steps,
                hs.completed_steps,
                hs.skipped_steps,
                hs.submitted_at,
                hs.completed_at,
                hs.time_spent_seconds,
                hs.hints_used
            FROM homework_submissions hs
            JOIN users u ON hs.user_id = u.user_id
            WHERE 1=1
        `;
        
        const params = [];
        let paramCount = 1;
        
        if (userId) {
            query += ` AND hs.user_id = $${paramCount}`;
            params.push(userId);
            paramCount++;
        }
        
        if (subject) {
            query += ` AND hs.subject = $${paramCount}`;
            params.push(subject);
            paramCount++;
        }
        
        if (status) {
            query += ` AND hs.status = $${paramCount}`;
            params.push(status);
            paramCount++;
        }
        
        if (startDate) {
            query += ` AND hs.submitted_at >= $${paramCount}`;
            params.push(startDate);
            paramCount++;
        }
        
        if (endDate) {
            query += ` AND hs.submitted_at <= $${paramCount}`;
            params.push(endDate);
            paramCount++;
        }
        
        query += ` ORDER BY hs.submitted_at DESC LIMIT $${paramCount} OFFSET $${paramCount + 1}`;
        params.push(limit, offset);
        
        const result = await pool.query(query, params);
        
        // Get total count
        let countQuery = `
            SELECT COUNT(*) as total
            FROM homework_submissions hs
            WHERE 1=1
        `;
        
        const countParams = [];
        paramCount = 1;
        
        if (userId) {
            countQuery += ` AND hs.user_id = $${paramCount}`;
            countParams.push(userId);
            paramCount++;
        }
        
        if (subject) {
            countQuery += ` AND hs.subject = $${paramCount}`;
            countParams.push(subject);
            paramCount++;
        }
        
        if (status) {
            countQuery += ` AND hs.status = $${paramCount}`;
            countParams.push(status);
            paramCount++;
        }
        
        if (startDate) {
            countQuery += ` AND hs.submitted_at >= $${paramCount}`;
            countParams.push(startDate);
            paramCount++;
        }
        
        if (endDate) {
            countQuery += ` AND hs.submitted_at <= $${paramCount}`;
            countParams.push(endDate);
            paramCount++;
        }
        
        const countResult = await pool.query(countQuery, countParams);
        const totalCount = parseInt(countResult.rows[0].total);
        
        return {
            submissions: result.rows,
            total: totalCount,
            limit,
            offset
        };
        
    } catch (error) {
        console.error('❌ Error fetching all homework submissions:', error);
        throw error;
    }
}

module.exports = {
    trackHomeworkSubmission,
    updateHomeworkCompletion,
    getUserHomeworkStats,
    getAllHomeworkSubmissions
};

