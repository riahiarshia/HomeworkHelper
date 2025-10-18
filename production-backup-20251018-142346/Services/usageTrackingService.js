const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

/**
 * OpenAI API Pricing (as of 2024)
 * GPT-4o: $2.50 per 1M input tokens, $10.00 per 1M output tokens
 * GPT-4o-mini: $0.150 per 1M input tokens, $0.600 per 1M output tokens
 */
const PRICING = {
  'gpt-4o': {
    input: 2.50 / 1000000,   // $2.50 per 1M tokens
    output: 10.00 / 1000000  // $10.00 per 1M tokens
  },
  'gpt-4o-mini': {
    input: 0.150 / 1000000,  // $0.150 per 1M tokens
    output: 0.600 / 1000000  // $0.600 per 1M tokens
  },
  'gpt-4-turbo': {
    input: 10.00 / 1000000,
    output: 30.00 / 1000000
  },
  'gpt-4': {
    input: 30.00 / 1000000,
    output: 60.00 / 1000000
  }
};

class UsageTrackingService {
  /**
   * Calculate cost based on model and token usage
   */
  calculateCost(model, promptTokens, completionTokens) {
    const pricing = PRICING[model] || PRICING['gpt-4o']; // Default to gpt-4o if model not found
    const inputCost = promptTokens * pricing.input;
    const outputCost = completionTokens * pricing.output;
    return inputCost + outputCost;
  }

  /**
   * Track API usage in database
   * @param {number} userId - User ID
   * @param {string} endpoint - API endpoint name
   * @param {string} model - OpenAI model used
   * @param {object} usage - Usage data from OpenAI response
   * @param {object} metadata - Additional metadata (optional)
   * @returns {Promise<object>} - Inserted usage record
   */
  async trackUsage({ userId, endpoint, model, usage, deviceId = null, metadata = {} }) {
    try {
      const promptTokens = usage.prompt_tokens || 0;
      const completionTokens = usage.completion_tokens || 0;
      const totalTokens = usage.total_tokens || (promptTokens + completionTokens);
      const costUsd = this.calculateCost(model, promptTokens, completionTokens);

      const result = await pool.query(
        `INSERT INTO user_api_usage 
        (user_id, device_id, endpoint, model, prompt_tokens, completion_tokens, total_tokens, cost_usd, problem_id, session_id, metadata)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        RETURNING *`,
        [
          userId,
          deviceId,
          endpoint,
          model,
          promptTokens,
          completionTokens,
          totalTokens,
          costUsd,
          metadata.problemId || null,
          metadata.sessionId || null,
          JSON.stringify(metadata)
        ]
      );

      console.log(`📊 Usage tracked: User ${userId}, Device ${deviceId || 'unknown'}, Endpoint ${endpoint}, Tokens ${totalTokens}, Cost $${costUsd.toFixed(6)}`);
      return result.rows[0];
    } catch (error) {
      console.error('❌ Error tracking usage:', error);
      // Don't throw error - tracking failure shouldn't break the API call
      return null;
    }
  }

  /**
   * Get user's total usage
   */
  async getUserUsage(userId) {
    try {
      const result = await pool.query(
        `SELECT 
          COUNT(*) as total_calls,
          SUM(prompt_tokens) as total_prompt_tokens,
          SUM(completion_tokens) as total_completion_tokens,
          SUM(total_tokens) as total_tokens,
          SUM(cost_usd) as total_cost,
          MAX(created_at) as last_call
        FROM user_api_usage
        WHERE user_id = $1`,
        [userId]
      );
      return result.rows[0];
    } catch (error) {
      console.error('❌ Error getting user usage:', error);
      throw error;
    }
  }

  /**
   * Get user's monthly usage
   */
  async getUserMonthlyUsage(userId) {
    try {
      const result = await pool.query(
        `SELECT 
          COUNT(*) as monthly_calls,
          SUM(prompt_tokens) as monthly_prompt_tokens,
          SUM(completion_tokens) as monthly_completion_tokens,
          SUM(total_tokens) as monthly_tokens,
          SUM(cost_usd) as monthly_cost
        FROM user_api_usage
        WHERE user_id = $1 
        AND created_at >= DATE_TRUNC('month', NOW())`,
        [userId]
      );
      return result.rows[0];
    } catch (error) {
      console.error('❌ Error getting user monthly usage:', error);
      throw error;
    }
  }

  /**
   * Get all users' usage summary (for admin)
   */
  async getAllUsageSummary({ limit = 100, offset = 0, sortBy = 'total_cost', order = 'DESC' }) {
    try {
      const validSortFields = ['total_cost', 'total_tokens', 'total_calls', 'username', 'last_call', 'device_id', 'user_id', 'email', 'cycle_cost', 'cycle_tokens', 'cycle_calls'];
      const sortField = validSortFields.includes(sortBy) ? sortBy : 'cycle_cost';
      const sortOrder = order.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';

      const result = await pool.query(
        `SELECT 
          u.user_id,
          u.username,
          u.email,
          u.subscription_status,
          u.subscription_start_date,
          u.subscription_end_date,
          uau.device_id,
          COUNT(uau.id) as total_calls,
          SUM(uau.prompt_tokens) as total_prompt_tokens,
          SUM(uau.completion_tokens) as total_completion_tokens,
          SUM(uau.total_tokens) as total_tokens,
          SUM(uau.cost_usd) as total_cost,
          -- Current cycle stats (usage between subscription_start_date and subscription_end_date)
          COUNT(CASE WHEN uau.created_at >= u.subscription_start_date 
                      AND uau.created_at < u.subscription_end_date 
                      THEN 1 END) as cycle_calls,
          SUM(CASE WHEN uau.created_at >= u.subscription_start_date 
                   AND uau.created_at < u.subscription_end_date 
                   THEN uau.total_tokens ELSE 0 END) as cycle_tokens,
          SUM(CASE WHEN uau.created_at >= u.subscription_start_date 
                   AND uau.created_at < u.subscription_end_date 
                   THEN uau.cost_usd ELSE 0 END) as cycle_cost,
          MAX(uau.created_at) as last_call,
          MIN(uau.created_at) as first_call
        FROM users u
        LEFT JOIN user_api_usage uau ON u.user_id::text = uau.user_id
        GROUP BY u.user_id, u.username, u.email, u.subscription_status, u.subscription_start_date, u.subscription_end_date, uau.device_id
        HAVING COUNT(uau.id) > 0
        ORDER BY ${sortField} ${sortOrder} NULLS LAST
        LIMIT $1 OFFSET $2`,
        [limit, offset]
      );

      // Get total count
      const countResult = await pool.query('SELECT COUNT(DISTINCT user_id) as total FROM users');
      
      return {
        users: result.rows,
        total: parseInt(countResult.rows[0].total),
        limit,
        offset
      };
    } catch (error) {
      console.error('❌ Error getting all usage summary:', error);
      throw error;
    }
  }

  /**
   * Get usage by endpoint
   */
  async getEndpointUsage() {
    try {
      const result = await pool.query(
        `SELECT 
          endpoint,
          model,
          COUNT(*) as api_calls,
          SUM(prompt_tokens) as prompt_tokens,
          SUM(completion_tokens) as completion_tokens,
          SUM(total_tokens) as total_tokens,
          SUM(cost_usd) as cost_usd,
          AVG(total_tokens) as avg_tokens_per_call,
          AVG(cost_usd) as avg_cost_per_call
        FROM user_api_usage
        GROUP BY endpoint, model
        ORDER BY cost_usd DESC`
      );
      return result.rows;
    } catch (error) {
      console.error('❌ Error getting endpoint usage:', error);
      throw error;
    }
  }

  /**
   * Get daily usage for last N days
   */
  async getDailyUsage(days = 30) {
    try {
      const result = await pool.query(
        `SELECT 
          DATE(created_at) as date,
          COUNT(*) as api_calls,
          COUNT(DISTINCT user_id) as unique_users,
          SUM(prompt_tokens) as prompt_tokens,
          SUM(completion_tokens) as completion_tokens,
          SUM(total_tokens) as total_tokens,
          SUM(cost_usd) as cost_usd
        FROM user_api_usage
        WHERE created_at >= CURRENT_DATE - INTERVAL '${days} days'
        GROUP BY DATE(created_at)
        ORDER BY date DESC`
      );
      return result.rows;
    } catch (error) {
      console.error('❌ Error getting daily usage:', error);
      throw error;
    }
  }

  /**
   * Get detailed usage records for export
   */
  async getDetailedUsageForExport({ startDate, endDate, userId, limit = 10000 }) {
    try {
      let query = `
        SELECT 
          uau.id,
          uau.user_id,
          u.username,
          u.email,
          uau.endpoint,
          uau.model,
          uau.prompt_tokens,
          uau.completion_tokens,
          uau.total_tokens,
          uau.cost_usd,
          uau.problem_id,
          uau.session_id,
          uau.created_at
        FROM user_api_usage uau
        JOIN users u ON uau.user_id = u.user_id
        WHERE 1=1
      `;
      
      const params = [];
      let paramCount = 1;

      if (startDate) {
        query += ` AND uau.created_at >= $${paramCount}`;
        params.push(startDate);
        paramCount++;
      }

      if (endDate) {
        query += ` AND uau.created_at <= $${paramCount}`;
        params.push(endDate);
        paramCount++;
      }

      if (userId) {
        query += ` AND uau.user_id = $${paramCount}`;
        params.push(userId);
        paramCount++;
      }

      query += ` ORDER BY uau.created_at DESC LIMIT $${paramCount}`;
      params.push(limit);

      const result = await pool.query(query, params);
      return result.rows;
    } catch (error) {
      console.error('❌ Error getting detailed usage for export:', error);
      throw error;
    }
  }

  /**
   * Check if user has exceeded usage limits
   * @param {number} userId - User ID
   * @param {object} limits - Usage limits
   * @returns {Promise<object>} - Limit status
   */
  async checkUsageLimits(userId, limits = {}) {
    try {
      const monthlyUsage = await this.getUserMonthlyUsage(userId);
      
      const status = {
        exceeded: false,
        monthlyTokens: parseInt(monthlyUsage.monthly_tokens) || 0,
        monthlyCost: parseFloat(monthlyUsage.monthly_cost) || 0,
        monthlyCalls: parseInt(monthlyUsage.monthly_calls) || 0,
        limits: limits
      };

      // Check token limit
      if (limits.maxMonthlyTokens && status.monthlyTokens >= limits.maxMonthlyTokens) {
        status.exceeded = true;
        status.reason = 'monthly_token_limit';
      }

      // Check cost limit
      if (limits.maxMonthlyCost && status.monthlyCost >= limits.maxMonthlyCost) {
        status.exceeded = true;
        status.reason = 'monthly_cost_limit';
      }

      // Check call limit
      if (limits.maxMonthlyCalls && status.monthlyCalls >= limits.maxMonthlyCalls) {
        status.exceeded = true;
        status.reason = 'monthly_call_limit';
      }

      return status;
    } catch (error) {
      console.error('❌ Error checking usage limits:', error);
      throw error;
    }
  }
}

module.exports = new UsageTrackingService();

