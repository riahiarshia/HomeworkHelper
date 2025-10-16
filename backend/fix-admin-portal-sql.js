#!/usr/bin/env node

/**
 * SQL-Only Fix for Admin Portal Data Issues
 * This version uses direct SQL commands without requiring the pg module
 */

console.log('🚀 Fixing Admin Portal Data Issues');
console.log('==================================\n');

console.log('📋 SQL Commands to Run in Azure Database:');
console.log('');

console.log('-- 1. Create missing tables');
console.log(`
CREATE TABLE IF NOT EXISTS users (
  user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255),
  auth_provider VARCHAR(50) DEFAULT 'email',
  subscription_status VARCHAR(50) DEFAULT 'trial',
  subscription_start_date TIMESTAMP,
  subscription_end_date TIMESTAMP,
  promo_code_used VARCHAR(100),
  is_active BOOLEAN DEFAULT true,
  is_banned BOOLEAN DEFAULT false,
  banned_reason TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_active_at TIMESTAMP DEFAULT NOW()
);
`);

console.log('-- 2. Create admin_users table');
console.log(`
CREATE TABLE IF NOT EXISTS admin_users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'admin',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP,
  updated_at TIMESTAMP DEFAULT NOW()
);
`);

console.log('-- 3. Create subscription_history table');
console.log(`
CREATE TABLE IF NOT EXISTS subscription_history (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  event_type VARCHAR(100) NOT NULL,
  metadata JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);
`);

console.log('-- 4. Create promo_codes table');
console.log(`
CREATE TABLE IF NOT EXISTS promo_codes (
  id SERIAL PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,
  duration_days INTEGER NOT NULL,
  uses_total INTEGER DEFAULT -1,
  uses_remaining INTEGER DEFAULT -1,
  active BOOLEAN DEFAULT true,
  description TEXT,
  expires_at TIMESTAMP,
  created_by VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);
`);

console.log('-- 5. Create device_logins table');
console.log(`
CREATE TABLE IF NOT EXISTS device_logins (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  device_id VARCHAR(255) NOT NULL,
  device_type VARCHAR(50),
  login_time TIMESTAMP DEFAULT NOW(),
  ip_address INET,
  user_agent TEXT
);
`);

console.log('-- 6. Create user_api_usage table');
console.log(`
CREATE TABLE IF NOT EXISTS user_api_usage (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  endpoint VARCHAR(255) NOT NULL,
  tokens_used INTEGER DEFAULT 0,
  cost_usd DECIMAL(10,4) DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);
`);

console.log('-- 7. Create monthly_usage_summary table');
console.log(`
CREATE TABLE IF NOT EXISTS monthly_usage_summary (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  year INTEGER NOT NULL,
  month INTEGER NOT NULL,
  total_tokens INTEGER DEFAULT 0,
  total_cost_usd DECIMAL(10,4) DEFAULT 0,
  api_calls_count INTEGER DEFAULT 0,
  subscription_renewals_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, year, month)
);
`);

console.log('-- 8. Create entitlements_ledger table');
console.log(`
CREATE TABLE IF NOT EXISTS entitlements_ledger (
  id SERIAL PRIMARY KEY,
  product_id VARCHAR(255) NOT NULL,
  subscription_group_id VARCHAR(255),
  original_transaction_id_hash VARCHAR(255) UNIQUE NOT NULL,
  ever_trial BOOLEAN DEFAULT false,
  status VARCHAR(50) DEFAULT 'active',
  first_seen_at TIMESTAMP DEFAULT NOW(),
  last_seen_at TIMESTAMP DEFAULT NOW()
);
`);

console.log('-- 9. Create user_entitlements table');
console.log(`
CREATE TABLE IF NOT EXISTS user_entitlements (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  product_id VARCHAR(255) NOT NULL,
  subscription_group_id VARCHAR(255),
  original_transaction_id_hash VARCHAR(255) NOT NULL,
  is_trial BOOLEAN DEFAULT false,
  status VARCHAR(50) DEFAULT 'active',
  purchase_at TIMESTAMP,
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);
`);

console.log('-- 10. Create admin_audit_log table');
console.log(`
CREATE TABLE IF NOT EXISTS admin_audit_log (
  id SERIAL PRIMARY KEY,
  admin_user_id INTEGER REFERENCES admin_users(id) ON DELETE SET NULL,
  admin_username VARCHAR(100),
  admin_email VARCHAR(100),
  action VARCHAR(100) NOT NULL,
  target_type VARCHAR(100),
  target_id VARCHAR(255),
  target_email VARCHAR(255),
  target_username VARCHAR(255),
  details JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
`);

console.log('-- 11. Insert sample users');
console.log(`
INSERT INTO users (user_id, email, username, auth_provider, subscription_status, subscription_start_date, subscription_end_date, is_active)
VALUES 
  (gen_random_uuid(), 'demo@example.com', 'demo_user', 'email', 'active', NOW(), NOW() + INTERVAL '30 days', true),
  (gen_random_uuid(), 'trial@example.com', 'trial_user', 'email', 'trial', NOW(), NOW() + INTERVAL '7 days', true),
  (gen_random_uuid(), 'expired@example.com', 'expired_user', 'email', 'expired', NOW() - INTERVAL '30 days', NOW() - INTERVAL '1 day', true)
ON CONFLICT (email) DO NOTHING;
`);

console.log('-- 12. Insert sample API usage data');
console.log(`
INSERT INTO user_api_usage (user_id, endpoint, tokens_used, cost_usd)
SELECT 
  u.user_id,
  '/api/homework/analyze',
  150,
  0.003
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM user_api_usage uau WHERE uau.user_id = u.user_id)
LIMIT 3;

INSERT INTO user_api_usage (user_id, endpoint, tokens_used, cost_usd)
SELECT 
  u.user_id,
  '/api/homework/validate',
  75,
  0.0015
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM user_api_usage uau WHERE uau.user_id = u.user_id)
LIMIT 3;

INSERT INTO user_api_usage (user_id, endpoint, tokens_used, cost_usd)
SELECT 
  u.user_id,
  '/api/subscription/check',
  25,
  0.0005
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM user_api_usage uau WHERE uau.user_id = u.user_id)
LIMIT 3;
`);

console.log('-- 13. Insert sample device logins');
console.log(`
INSERT INTO device_logins (user_id, device_id, device_type, login_time, ip_address)
SELECT 
  u.user_id,
  'device-123',
  'iPhone',
  NOW() - INTERVAL '1 day',
  '192.168.1.100'
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM device_logins dl WHERE dl.user_id = u.user_id)
LIMIT 3;

INSERT INTO device_logins (user_id, device_id, device_type, login_time, ip_address)
SELECT 
  u.user_id,
  'device-456',
  'iPad',
  NOW() - INTERVAL '2 days',
  '192.168.1.101'
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM device_logins dl WHERE dl.user_id = u.user_id)
LIMIT 3;
`);

console.log('-- 14. Insert sample promo codes');
console.log(`
INSERT INTO promo_codes (code, duration_days, uses_total, uses_remaining, description, created_by)
VALUES 
  ('WELCOME2024', 7, 100, 100, 'Welcome promo', 'admin'),
  ('STUDENT50', 14, 50, 50, 'Student discount', 'admin')
ON CONFLICT (code) DO NOTHING;
`);

console.log('-- 15. Create database views');
console.log(`
CREATE OR REPLACE VIEW user_usage_summary AS
SELECT 
  u.user_id,
  u.email,
  u.username,
  u.subscription_status,
  u.subscription_end_date,
  COALESCE(SUM(uau.tokens_used), 0) as total_tokens,
  COALESCE(SUM(uau.cost_usd), 0) as total_cost_usd,
  COUNT(uau.id) as api_calls_count,
  COALESCE((SELECT COUNT(*) FROM subscription_history sh WHERE sh.user_id = u.user_id AND sh.event_type = 'subscription_renewed'), 0) as subscription_renewals_count
FROM users u
LEFT JOIN user_api_usage uau ON u.user_id = uau.user_id
GROUP BY u.user_id, u.email, u.username, u.subscription_status, u.subscription_end_date;
`);

console.log('-- 16. Create monthly usage summary view');
console.log(`
CREATE OR REPLACE VIEW monthly_usage_summary AS
SELECT 
  u.user_id,
  u.email,
  u.username,
  EXTRACT(YEAR FROM uau.created_at) as year,
  EXTRACT(MONTH FROM uau.created_at) as month,
  SUM(uau.tokens_used) as total_tokens,
  SUM(uau.cost_usd) as total_cost_usd,
  COUNT(uau.id) as api_calls_count
FROM users u
LEFT JOIN user_api_usage uau ON u.user_id = uau.user_id
GROUP BY u.user_id, u.email, u.username, EXTRACT(YEAR FROM uau.created_at), EXTRACT(MONTH FROM uau.created_at);
`);

console.log('\n🎉 SUCCESS! Copy and paste these SQL commands into your database!');
console.log('\n✅ After running these commands, your admin portal should show:');
console.log('   - Dashboard with user statistics');
console.log('   - Users in the Users tab');
console.log('   - Working API usage analytics');
console.log('   - Sample promo codes');
console.log('   - Device analytics data');
console.log('\n🔄 Please refresh your admin portal to see the changes!');
