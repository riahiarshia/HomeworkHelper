-- Migration: Add Monthly Usage Reset and Cost Tracking
-- Purpose: Track monthly costs per user and enable usage reset on subscription renewal

-- Create monthly usage summary table
CREATE TABLE IF NOT EXISTS monthly_usage_summary (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL, -- 1-12
    total_tokens BIGINT DEFAULT 0,
    total_cost_usd DECIMAL(10,6) DEFAULT 0.00,
    api_calls_count INTEGER DEFAULT 0,
    subscription_renewals_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure one record per user per month
    UNIQUE(user_id, year, month)
);

-- Create index for efficient queries
CREATE INDEX IF NOT EXISTS idx_monthly_usage_user_month ON monthly_usage_summary(user_id, year, month);
CREATE INDEX IF NOT EXISTS idx_monthly_usage_month ON monthly_usage_summary(year, month);

-- Add comments for documentation
COMMENT ON TABLE monthly_usage_summary IS 'Monthly usage and cost summary for each user';
COMMENT ON COLUMN monthly_usage_summary.year IS 'Year (e.g., 2024)';
COMMENT ON COLUMN monthly_usage_summary.month IS 'Month (1-12)';
COMMENT ON COLUMN monthly_usage_summary.total_tokens IS 'Total tokens used in the month';
COMMENT ON COLUMN monthly_usage_summary.total_cost_usd IS 'Total cost in USD for the month';
COMMENT ON COLUMN monthly_usage_summary.api_calls_count IS 'Number of API calls made in the month';
COMMENT ON COLUMN monthly_usage_summary.subscription_renewals_count IS 'Number of subscription renewals in the month';

-- Function to update monthly usage summary
CREATE OR REPLACE FUNCTION update_monthly_usage_summary(
    p_user_id UUID,
    p_tokens BIGINT,
    p_cost_usd DECIMAL(10,6),
    p_api_calls INTEGER DEFAULT 1
) RETURNS VOID AS $$
BEGIN
    INSERT INTO monthly_usage_summary (user_id, year, month, total_tokens, total_cost_usd, api_calls_count)
    VALUES (
        p_user_id,
        EXTRACT(YEAR FROM CURRENT_DATE),
        EXTRACT(MONTH FROM CURRENT_DATE),
        p_tokens,
        p_cost_usd,
        p_api_calls
    )
    ON CONFLICT (user_id, year, month)
    DO UPDATE SET
        total_tokens = monthly_usage_summary.total_tokens + p_tokens,
        total_cost_usd = monthly_usage_summary.total_cost_usd + p_cost_usd,
        api_calls_count = monthly_usage_summary.api_calls_count + p_api_calls,
        updated_at = CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Function to reset monthly usage on subscription renewal
CREATE OR REPLACE FUNCTION reset_monthly_usage_on_renewal(p_user_id UUID) RETURNS VOID AS $$
BEGIN
    -- Log the renewal in monthly summary
    INSERT INTO monthly_usage_summary (user_id, year, month, subscription_renewals_count)
    VALUES (
        p_user_id,
        EXTRACT(YEAR FROM CURRENT_DATE),
        EXTRACT(MONTH FROM CURRENT_DATE),
        1
    )
    ON CONFLICT (user_id, year, month)
    DO UPDATE SET
        subscription_renewals_count = monthly_usage_summary.subscription_renewals_count + 1,
        updated_at = CURRENT_TIMESTAMP;
    
    -- Note: We keep historical data in user_api_usage for analytics
    -- The "reset" is conceptual - we start tracking new monthly costs from this point
    RAISE NOTICE 'Monthly usage tracking reset for user % in %-%', 
        p_user_id, 
        EXTRACT(YEAR FROM CURRENT_DATE), 
        EXTRACT(MONTH FROM CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

-- Create view for easy monthly cost queries
CREATE OR REPLACE VIEW monthly_costs_summary AS
SELECT 
    u.user_id,
    u.email,
    u.username,
    mus.year,
    mus.month,
    mus.total_tokens,
    mus.total_cost_usd,
    mus.api_calls_count,
    mus.subscription_renewals_count,
    mus.created_at as month_start,
    mus.updated_at as last_updated
FROM monthly_usage_summary mus
JOIN users u ON mus.user_id = u.user_id
ORDER BY mus.year DESC, mus.month DESC, mus.total_cost_usd DESC;

COMMENT ON VIEW monthly_costs_summary IS 'Easy view to see monthly costs per user for admin portal';

-- Insert migration record
INSERT INTO migrations (migration_name, applied_at) 
VALUES ('monthly_usage_reset_and_cost_tracking', CURRENT_TIMESTAMP)
ON CONFLICT (migration_name) DO NOTHING;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Monthly usage reset and cost tracking system created successfully!';
    RAISE NOTICE '📊 Monthly costs can now be tracked per user';
    RAISE NOTICE '🔄 Usage reset functionality ready for subscription renewals';
    RAISE NOTICE '📈 Admin portal can show monthly costs using monthly_costs_summary view';
END $$;


