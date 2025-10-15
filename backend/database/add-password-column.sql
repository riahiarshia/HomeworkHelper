-- Migration: Add password_hash column to users table
-- This allows admin-created users to login with email/password

-- Add password_hash column (nullable because existing users don't have passwords)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);

-- Add index for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_password_hash ON users(password_hash);

-- Display success message
SELECT 'Password column added successfully!' as message;

