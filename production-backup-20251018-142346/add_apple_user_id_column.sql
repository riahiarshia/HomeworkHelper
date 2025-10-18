-- Add Apple user ID column to support Apple Sign-In
-- This migration adds the apple_user_id column to the users table

-- Check if column already exists before adding
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'users' 
        AND column_name = 'apple_user_id'
    ) THEN
        ALTER TABLE users ADD COLUMN apple_user_id VARCHAR(255);
        CREATE INDEX idx_users_apple_user_id ON users(apple_user_id);
        COMMENT ON COLUMN users.apple_user_id IS 'Apple Sign-In user identifier';
        RAISE NOTICE 'Added apple_user_id column to users table';
    ELSE
        RAISE NOTICE 'apple_user_id column already exists';
    END IF;
END $$;
