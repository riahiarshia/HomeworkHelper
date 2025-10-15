-- Migration: Add Entitlements Ledger (PII-free)
-- Purpose: Minimal transaction ledger for trial abuse prevention & accounting
-- Apple 5.1.1(v) compliant - retains de-identified records after account deletion
-- Date: 2025-10-15

-- ============================================================================
-- TABLE: entitlements_ledger (PII-free, persists after deletion)
-- Purpose: De-identified ledger of subscription facts for fraud prevention
-- ============================================================================

CREATE TABLE IF NOT EXISTS entitlements_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id TEXT NOT NULL,
    subscription_group_id TEXT NOT NULL,
    original_transaction_id_hash TEXT NOT NULL,
    ever_trial BOOLEAN NOT NULL DEFAULT FALSE,
    status TEXT NOT NULL CHECK (status IN ('active','expired','canceled')),
    first_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Unique index on hashed transaction ID (prevents duplicates)
CREATE UNIQUE INDEX IF NOT EXISTS ent_ledger_txid_hash_idx
    ON entitlements_ledger(original_transaction_id_hash);

-- Index for status queries
CREATE INDEX IF NOT EXISTS ent_ledger_status_idx
    ON entitlements_ledger(status);

-- Index for time-based queries and pruning
CREATE INDEX IF NOT EXISTS ent_ledger_last_seen_idx
    ON entitlements_ledger(last_seen_at);

-- ============================================================================
-- TABLE: user_entitlements (linked to user; OK to keep PII while user exists)
-- Purpose: User-linked entitlements with both plain and hashed transaction IDs
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_entitlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    product_id TEXT NOT NULL,
    subscription_group_id TEXT NOT NULL,
    original_transaction_id TEXT, -- nullable; plain ID kept only while user exists
    original_transaction_id_hash TEXT, -- hashed version for ledger linkage
    is_trial BOOLEAN NOT NULL DEFAULT FALSE,
    status TEXT NOT NULL CHECK (status IN ('active','expired','canceled')),
    purchase_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for user_entitlements
CREATE INDEX IF NOT EXISTS user_entitlements_user_idx
    ON user_entitlements(user_id);

CREATE INDEX IF NOT EXISTS user_entitlements_txid_hash_idx
    ON user_entitlements(original_transaction_id_hash);

CREATE INDEX IF NOT EXISTS user_entitlements_status_idx
    ON user_entitlements(status);

-- ============================================================================
-- TRIGGER: Auto-update updated_at timestamp
-- ============================================================================

CREATE OR REPLACE FUNCTION update_user_entitlements_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_user_entitlements_timestamp ON user_entitlements;

CREATE TRIGGER trigger_update_user_entitlements_timestamp
    BEFORE UPDATE ON user_entitlements
    FOR EACH ROW
    EXECUTE FUNCTION update_user_entitlements_updated_at();

-- ============================================================================
-- COMMENTS for Documentation
-- ============================================================================

COMMENT ON TABLE entitlements_ledger IS 
'PII-free ledger of subscription transactions. Persists after account deletion 
for fraud prevention and accounting (Apple 5.1.1(v) compliance). Only stores 
hashed transaction IDs, product info, trial flag, and timestamps.';

COMMENT ON COLUMN entitlements_ledger.original_transaction_id_hash IS 
'SHA-256 hash of (LEDGER_SALT + original_transaction_id). Stable per Apple ID 
but not personally identifiable. Used to prevent trial abuse.';

COMMENT ON COLUMN entitlements_ledger.ever_trial IS 
'True if this transaction ever used an introductory offer or free trial. 
Once set to true, never reverts to false.';

COMMENT ON TABLE user_entitlements IS 
'User-linked subscription entitlements. Contains PII and plain transaction IDs 
while user account exists. Deleted on account deletion (data mirrored to 
entitlements_ledger first).';

COMMENT ON COLUMN user_entitlements.original_transaction_id IS 
'Plain Apple original_transaction_id. Kept only while user exists. Deleted on 
account deletion after mirroring hash to entitlements_ledger.';

COMMENT ON COLUMN user_entitlements.original_transaction_id_hash IS 
'Hashed version of original_transaction_id. Used to link to entitlements_ledger 
and for de-identified lookups after account deletion.';

-- ============================================================================
-- VERIFICATION
-- ============================================================================

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables 
               WHERE table_name = 'entitlements_ledger') THEN
        RAISE NOTICE '✅ entitlements_ledger table created successfully';
    ELSE
        RAISE EXCEPTION '❌ Failed to create entitlements_ledger table';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables 
               WHERE table_name = 'user_entitlements') THEN
        RAISE NOTICE '✅ user_entitlements table created successfully';
    ELSE
        RAISE EXCEPTION '❌ Failed to create user_entitlements table';
    END IF;
END $$;

RAISE NOTICE '============================================================================';
RAISE NOTICE '✅ Migration 008 Complete: Entitlements Ledger';
RAISE NOTICE '============================================================================';
RAISE NOTICE 'Tables:';
RAISE NOTICE '  - entitlements_ledger (PII-free, persists after deletion)';
RAISE NOTICE '  - user_entitlements (user-linked, deleted with account)';
RAISE NOTICE 'Purpose: Minimal transaction ledger for fraud prevention & accounting';
RAISE NOTICE 'Compliance: Apple 5.1.1(v) - de-identified retention for business purposes';
RAISE NOTICE '============================================================================';

