-- Basic Monthly Usage Reset Migration
-- Create only the essential table and functions

-- Create monthly usage summary table (if not exists)
CREATE TABLE IF NOT EXISTS monthly_usage_summary (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    total_tokens BIGINT DEFAULT 0,
    total_cost_usd DECIMAL(10,6) DEFAULT 0.00,
    api_calls_count INTEGER DEFAULT 0,
    subscription_renewals_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add unique constraint (if not exists)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'monthly_usage_summary_user_year_month_key'
    ) THEN
        ALTER TABLE monthly_usage_summary 
        ADD CONSTRAINT monthly_usage_summary_user_year_month_key 
        UNIQUE(user_id, year, month);
    END IF;
END $$;

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
    
    RAISE NOTICE 'Monthly usage tracking reset for user % in %-%', 
        p_user_id, 
        EXTRACT(YEAR FROM CURRENT_DATE), 
        EXTRACT(MONTH FROM CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Basic monthly usage reset system created successfully!';
END $$;


