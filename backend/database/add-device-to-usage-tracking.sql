-- Add device_id column to user_api_usage table
ALTER TABLE user_api_usage ADD COLUMN IF NOT EXISTS device_id VARCHAR(255);

-- Add index for device_id for performance
CREATE INDEX IF NOT EXISTS idx_user_api_usage_device_id ON user_api_usage(device_id);

-- Create view for device usage summary
CREATE OR REPLACE VIEW device_usage_summary AS
SELECT 
    uau.device_id,
    COUNT(uau.id) AS total_api_calls,
    COUNT(DISTINCT uau.user_id) AS unique_users,
    SUM(uau.prompt_tokens) AS total_prompt_tokens,
    SUM(uau.completion_tokens) AS total_completion_tokens,
    SUM(uau.total_tokens) AS total_tokens,
    SUM(uau.cost_usd) AS total_cost_usd,
    MAX(uau.created_at) AS last_api_call,
    MIN(uau.created_at) AS first_api_call
FROM user_api_usage uau
WHERE uau.device_id IS NOT NULL
GROUP BY uau.device_id
ORDER BY total_cost_usd DESC;

COMMENT ON VIEW device_usage_summary IS 'Aggregated API usage per device';

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Device tracking added to user_api_usage table!';
    RAISE NOTICE '📊 View created: device_usage_summary';
    RAISE NOTICE '🔍 Ready to track usage by device';
END $$;

