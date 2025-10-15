-- ===================================================================
-- ADD APPLE SIGN-IN SUPPORT TO DATABASE
-- ===================================================================
-- Run this SQL in Azure Portal > PostgreSQL > Query Editor
-- This is safe - it only adds a new column, doesn't modify existing data
-- ===================================================================

-- Step 1: Add the apple_user_id column (if it doesn't exist)
ALTER TABLE users ADD COLUMN IF NOT EXISTS apple_user_id VARCHAR(255);

-- Step 2: Add an index for fast lookups
CREATE INDEX IF NOT EXISTS idx_users_apple_user_id ON users(apple_user_id);

-- Step 3: Verify the column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name = 'apple_user_id';

-- Expected output:
-- column_name    | data_type          | is_nullable
-- ---------------+--------------------+-------------
-- apple_user_id  | character varying  | YES

-- ===================================================================
-- DONE! Apple Sign-In will now work in the iOS app
-- ===================================================================

