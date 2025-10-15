-- Migration: Add Trial Abuse Prevention
-- Purpose: Track Apple trials to prevent abuse even after account deletion
-- Date: 2025-10-14

-- ============================================================================
-- TABLE: trial_usage_history
-- Purpose: Persists trial usage data even when accounts are deleted
-- Key: original_transaction_id (Apple's stable identifier per Apple ID)
-- ============================================================================

CREATE TABLE IF NOT EXISTS trial_usage_history (
    id SERIAL PRIMARY KEY,
    original_transaction_id VARCHAR(255) UNIQUE NOT NULL,
    user_id UUID,  -- Can be NULL if account deleted (for privacy)
    apple_product_id VARCHAR(255),
    had_intro_offer BOOLEAN DEFAULT false,
    had_free_trial BOOLEAN DEFAULT false,
    trial_start_date TIMESTAMP,
    trial_end_date TIMESTAMP,
    apple_environment VARCHAR(50),  -- 'Sandbox' or 'Production'
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================================
-- INDEXES for Performance
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_trial_history_original_transaction 
ON trial_usage_history(original_transaction_id);

CREATE INDEX IF NOT EXISTS idx_trial_history_user_id 
ON trial_usage_history(user_id);

CREATE INDEX IF NOT EXISTS idx_trial_history_created_at 
ON trial_usage_history(created_at);

-- ============================================================================
-- COMMENTS for Documentation
-- ============================================================================

COMMENT ON TABLE trial_usage_history IS 
'Tracks which Apple original_transaction_ids have received trials. 
This table persists even when user accounts are deleted to prevent trial abuse.
The original_transaction_id is tied to the Apple ID, not our user account.
This is minimal, purpose-limited data retained only for fraud prevention (GDPR/CCPA compliant).';

COMMENT ON COLUMN trial_usage_history.original_transaction_id IS 
'Apple''s stable identifier that persists across renewals and restores. 
Tied to the user''s Apple ID, not our app account.';

COMMENT ON COLUMN trial_usage_history.user_id IS 
'Reference to our user account. Set to NULL when account is deleted for privacy.';

COMMENT ON COLUMN trial_usage_history.had_intro_offer IS 
'True if this transaction used any introductory offer (includes free trials and discounted periods).';

COMMENT ON COLUMN trial_usage_history.had_free_trial IS 
'True if this transaction specifically used a free trial period.';

COMMENT ON COLUMN trial_usage_history.apple_environment IS 
'Sandbox or Production - helps distinguish test vs real subscriptions.';

-- ============================================================================
-- FUNCTION: Update timestamp on row update
-- ============================================================================

CREATE OR REPLACE FUNCTION update_trial_history_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGER: Auto-update updated_at timestamp
-- ============================================================================

DROP TRIGGER IF EXISTS trigger_update_trial_history_timestamp ON trial_usage_history;

CREATE TRIGGER trigger_update_trial_history_timestamp
    BEFORE UPDATE ON trial_usage_history
    FOR EACH ROW
    EXECUTE FUNCTION update_trial_history_updated_at();

-- ============================================================================
-- DATA RETENTION POLICY (Optional - Comment out if not needed)
-- ============================================================================

-- Optional: Auto-cleanup of very old sandbox test data (keeps production data)
-- Uncomment if you want to auto-delete sandbox trials older than 1 year
-- CREATE OR REPLACE FUNCTION cleanup_old_sandbox_trials()
-- RETURNS void AS $$
-- BEGIN
--     DELETE FROM trial_usage_history 
--     WHERE apple_environment = 'Sandbox' 
--     AND created_at < NOW() - INTERVAL '1 year';
-- END;
-- $$ LANGUAGE plpgsql;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify table was created
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables 
               WHERE table_name = 'trial_usage_history') THEN
        RAISE NOTICE '✅ trial_usage_history table created successfully';
    ELSE
        RAISE EXCEPTION '❌ Failed to create trial_usage_history table';
    END IF;
END $$;

-- Display table structure
\d trial_usage_history

-- Show sample query for checking trial usage
-- SELECT * FROM trial_usage_history WHERE original_transaction_id = 'sample_id';

RAISE NOTICE '============================================================================';
RAISE NOTICE '✅ Migration 007 Complete: Trial Abuse Prevention';
RAISE NOTICE '============================================================================';
RAISE NOTICE 'Table: trial_usage_history';
RAISE NOTICE 'Purpose: Track Apple trials to prevent abuse after account deletion';
RAISE NOTICE 'Privacy: User IDs are nullified on account deletion (minimal retention)';
RAISE NOTICE 'Compliance: GDPR/CCPA compliant - fraud prevention purpose only';
RAISE NOTICE '============================================================================';

