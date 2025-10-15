-- Migration: Add Apple Subscription Tracking
-- Date: 2024-01-XX
-- Description: Add columns to track Apple In-App Purchase subscriptions

-- Add Apple-specific subscription tracking columns
ALTER TABLE users ADD COLUMN IF NOT EXISTS apple_original_transaction_id VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS apple_product_id VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS apple_environment VARCHAR(50) DEFAULT 'Production';

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_apple_original_transaction_id ON users(apple_original_transaction_id);
CREATE INDEX IF NOT EXISTS idx_apple_product_id ON users(apple_product_id);

-- Add comments for documentation
COMMENT ON COLUMN users.apple_original_transaction_id IS 'Apple original transaction ID for subscription tracking';
COMMENT ON COLUMN users.apple_product_id IS 'Apple product ID (e.g., com.homeworkhelper.monthly)';
COMMENT ON COLUMN users.apple_environment IS 'Apple environment: Production or Sandbox';

-- Update subscription_history table to handle Apple events
ALTER TABLE subscription_history ADD COLUMN IF NOT EXISTS apple_transaction_id VARCHAR(255);
ALTER TABLE subscription_history ADD COLUMN IF NOT EXISTS apple_original_transaction_id VARCHAR(255);

-- Create index for Apple transaction lookups
CREATE INDEX IF NOT EXISTS idx_subscription_history_apple_original_transaction ON subscription_history(apple_original_transaction_id);

-- Add comment
COMMENT ON COLUMN subscription_history.apple_transaction_id IS 'Individual Apple transaction ID';
COMMENT ON COLUMN subscription_history.apple_original_transaction_id IS 'Apple original transaction ID for subscription grouping';
