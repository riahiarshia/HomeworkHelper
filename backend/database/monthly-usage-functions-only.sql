-- Monthly Usage Functions Only Migration
-- Just create the essential functions for monthly usage tracking

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
    RAISE NOTICE '✅ Monthly usage functions created successfully!';
END $$;


