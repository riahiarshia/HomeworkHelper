-- =====================================================
-- USER API USAGE TRACKING MIGRATION
-- =====================================================
-- Purpose: Track OpenAI API usage per user for cost management
-- Date: 2025-10-11
-- =====================================================

-- Create user_api_usage table
CREATE TABLE IF NOT EXISTS user_api_usage (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    endpoint VARCHAR(100) NOT NULL,  -- 'analyze_homework', 'generate_hint', 'verify_answer', 'chat_response', 'validate_image'
    model VARCHAR(50) NOT NULL,      -- 'gpt-4o', 'gpt-4o-mini', etc.
    prompt_tokens INTEGER NOT NULL DEFAULT 0,
    completion_tokens INTEGER NOT NULL DEFAULT 0,
    total_tokens INTEGER NOT NULL DEFAULT 0,
    cost_usd DECIMAL(10,6) NOT NULL DEFAULT 0.000000,  -- Cost in USD with 6 decimal precision
    problem_id VARCHAR(255),         -- Optional: link to homework problem
    session_id VARCHAR(255),         -- Optional: group related API calls
    metadata JSONB,                  -- Additional metadata (user grade, subject, etc.)
    created_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_api_usage_user_id ON user_api_usage(user_id);
CREATE INDEX IF NOT EXISTS idx_user_api_usage_created_at ON user_api_usage(created_at);
CREATE INDEX IF NOT EXISTS idx_user_api_usage_endpoint ON user_api_usage(endpoint);
CREATE INDEX IF NOT EXISTS idx_user_api_usage_user_date ON user_api_usage(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_user_api_usage_model ON user_api_usage(model);

-- Add comments for documentation
COMMENT ON TABLE user_api_usage IS 'Tracks OpenAI API usage per user for cost management and analytics';
COMMENT ON COLUMN user_api_usage.id IS 'Primary key';
COMMENT ON COLUMN user_api_usage.user_id IS 'Foreign key to users table';
COMMENT ON COLUMN user_api_usage.endpoint IS 'API endpoint used (analyze_homework, generate_hint, etc.)';
COMMENT ON COLUMN user_api_usage.model IS 'OpenAI model used (gpt-4o, gpt-4o-mini, etc.)';
COMMENT ON COLUMN user_api_usage.prompt_tokens IS 'Number of tokens in the prompt';
COMMENT ON COLUMN user_api_usage.completion_tokens IS 'Number of tokens in the completion';
COMMENT ON COLUMN user_api_usage.total_tokens IS 'Total tokens used (prompt + completion)';
COMMENT ON COLUMN user_api_usage.cost_usd IS 'Cost in USD based on OpenAI pricing';
COMMENT ON COLUMN user_api_usage.problem_id IS 'Optional: Reference to homework problem';
COMMENT ON COLUMN user_api_usage.session_id IS 'Optional: Group related API calls';
COMMENT ON COLUMN user_api_usage.metadata IS 'Additional metadata (JSON)';
COMMENT ON COLUMN user_api_usage.created_at IS 'Timestamp of API call';

-- Create aggregate view for easy reporting
CREATE OR REPLACE VIEW user_usage_summary AS
SELECT 
    u.user_id,
    u.username,
    u.email,
    COUNT(uau.id) AS total_api_calls,
    SUM(uau.prompt_tokens) AS total_prompt_tokens,
    SUM(uau.completion_tokens) AS total_completion_tokens,
    SUM(uau.total_tokens) AS total_tokens,
    SUM(uau.cost_usd) AS total_cost_usd,
    MAX(uau.created_at) AS last_api_call,
    MIN(uau.created_at) AS first_api_call
FROM users u
LEFT JOIN user_api_usage uau ON u.user_id = uau.user_id
GROUP BY u.user_id, u.username, u.email
ORDER BY total_cost_usd DESC NULLS LAST;

COMMENT ON VIEW user_usage_summary IS 'Aggregated view of API usage per user';

-- Create monthly usage view
CREATE OR REPLACE VIEW monthly_usage_summary AS
SELECT 
    u.user_id,
    u.username,
    u.email,
    DATE_TRUNC('month', uau.created_at) AS month,
    COUNT(uau.id) AS api_calls,
    SUM(uau.prompt_tokens) AS prompt_tokens,
    SUM(uau.completion_tokens) AS completion_tokens,
    SUM(uau.total_tokens) AS total_tokens,
    SUM(uau.cost_usd) AS cost_usd
FROM users u
LEFT JOIN user_api_usage uau ON u.user_id = uau.user_id
WHERE uau.created_at >= DATE_TRUNC('month', NOW() - INTERVAL '12 months')
GROUP BY u.user_id, u.username, u.email, DATE_TRUNC('month', uau.created_at)
ORDER BY month DESC, cost_usd DESC NULLS LAST;

COMMENT ON VIEW monthly_usage_summary IS 'Monthly aggregated usage per user (last 12 months)';

-- Create endpoint usage view
CREATE OR REPLACE VIEW endpoint_usage_summary AS
SELECT 
    uau.endpoint,
    uau.model,
    COUNT(uau.id) AS api_calls,
    SUM(uau.prompt_tokens) AS prompt_tokens,
    SUM(uau.completion_tokens) AS completion_tokens,
    SUM(uau.total_tokens) AS total_tokens,
    SUM(uau.cost_usd) AS cost_usd,
    AVG(uau.total_tokens) AS avg_tokens_per_call,
    AVG(uau.cost_usd) AS avg_cost_per_call
FROM user_api_usage uau
GROUP BY uau.endpoint, uau.model
ORDER BY cost_usd DESC;

COMMENT ON VIEW endpoint_usage_summary IS 'Usage statistics by endpoint and model';

-- Create daily usage view for tracking trends
CREATE OR REPLACE VIEW daily_usage_summary AS
SELECT 
    DATE(uau.created_at) AS date,
    COUNT(uau.id) AS api_calls,
    COUNT(DISTINCT uau.user_id) AS unique_users,
    SUM(uau.prompt_tokens) AS prompt_tokens,
    SUM(uau.completion_tokens) AS completion_tokens,
    SUM(uau.total_tokens) AS total_tokens,
    SUM(uau.cost_usd) AS cost_usd
FROM user_api_usage uau
WHERE uau.created_at >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY DATE(uau.created_at)
ORDER BY date DESC;

COMMENT ON VIEW daily_usage_summary IS 'Daily usage statistics (last 90 days)';

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ User API Usage Tracking tables and views created successfully!';
    RAISE NOTICE '📊 Views created: user_usage_summary, monthly_usage_summary, endpoint_usage_summary, daily_usage_summary';
    RAISE NOTICE '🔍 Ready to track OpenAI API usage and costs per user';
END $$;

