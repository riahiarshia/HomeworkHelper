-- HomeworkHelper Database Schema
-- Subscription & User Management System
-- PostgreSQL Migration Script

-- ==================================================
-- 1. USERS TABLE
-- ==================================================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) NOT NULL,
    username VARCHAR(255),
    auth_provider VARCHAR(50),  -- 'google', 'apple', 'email'
    
    -- Subscription fields
    subscription_status VARCHAR(50) NOT NULL DEFAULT 'trial',
    -- Possible values: 'trial', 'active', 'promo_active', 'expired', 'cancelled'
    
    subscription_start_date TIMESTAMP,
    subscription_end_date TIMESTAMP,
    trial_started_at TIMESTAMP DEFAULT NOW(),
    
    -- Promo code tracking
    promo_code_used VARCHAR(100),
    promo_activated_at TIMESTAMP,
    
    -- Payment tracking
    stripe_customer_id VARCHAR(255),
    stripe_subscription_id VARCHAR(255),
    
    -- Access control
    is_active BOOLEAN DEFAULT true,
    is_banned BOOLEAN DEFAULT false,
    banned_reason TEXT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_active_at TIMESTAMP
);

-- Indexes for users table
CREATE INDEX IF NOT EXISTS idx_users_user_id ON users(user_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_subscription_status ON users(subscription_status);
CREATE INDEX IF NOT EXISTS idx_users_subscription_end_date ON users(subscription_end_date);
CREATE INDEX IF NOT EXISTS idx_users_stripe_customer_id ON users(stripe_customer_id);

-- ==================================================
-- 2. PROMO CODES TABLE
-- ==================================================
CREATE TABLE IF NOT EXISTS promo_codes (
    id SERIAL PRIMARY KEY,
    code VARCHAR(100) UNIQUE NOT NULL,
    
    -- Duration settings
    duration_days INTEGER NOT NULL,  -- 90 for 3 months, 365 for 1 year, etc.
    
    -- Usage limits
    uses_total INTEGER DEFAULT -1,     -- -1 = unlimited
    uses_remaining INTEGER,            
    used_count INTEGER DEFAULT 0,      
    
    -- Activation control
    active BOOLEAN DEFAULT true,
    starts_at TIMESTAMP,               -- When code becomes valid (optional)
    expires_at TIMESTAMP,              -- When code expires (optional)
    
    -- Metadata
    created_by VARCHAR(255),           -- Admin username who created it
    description TEXT,                  -- Internal note
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for promo_codes table
CREATE INDEX IF NOT EXISTS idx_promo_codes_code ON promo_codes(code);
CREATE INDEX IF NOT EXISTS idx_promo_codes_active ON promo_codes(active);
CREATE INDEX IF NOT EXISTS idx_promo_codes_expires_at ON promo_codes(expires_at);

-- ==================================================
-- 3. PROMO CODE USAGE TABLE
-- ==================================================
CREATE TABLE IF NOT EXISTS promo_code_usage (
    id SERIAL PRIMARY KEY,
    promo_code_id INTEGER REFERENCES promo_codes(id) ON DELETE CASCADE,
    user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
    activated_at TIMESTAMP DEFAULT NOW(),
    ip_address VARCHAR(50),
    
    UNIQUE(promo_code_id, user_id)  -- Prevent duplicate uses
);

-- Indexes for promo_code_usage table
CREATE INDEX IF NOT EXISTS idx_promo_usage_promo_id ON promo_code_usage(promo_code_id);
CREATE INDEX IF NOT EXISTS idx_promo_usage_user_id ON promo_code_usage(user_id);

-- ==================================================
-- 4. SUBSCRIPTION HISTORY TABLE
-- ==================================================
CREATE TABLE IF NOT EXISTS subscription_history (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL,
    -- Event types: 'trial_started', 'trial_expired', 'subscription_activated',
    --              'subscription_renewed', 'subscription_cancelled', 'promo_activated',
    --              'subscription_extended', 'access_toggled', 'user_banned', 'user_unbanned'
    
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    old_end_date TIMESTAMP,
    new_end_date TIMESTAMP,
    
    metadata JSONB,  -- Additional event data
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for subscription_history table
CREATE INDEX IF NOT EXISTS idx_sub_history_user_id ON subscription_history(user_id);
CREATE INDEX IF NOT EXISTS idx_sub_history_event_type ON subscription_history(event_type);
CREATE INDEX IF NOT EXISTS idx_sub_history_created_at ON subscription_history(created_at);

-- ==================================================
-- 5. ADMIN USERS TABLE
-- ==================================================
CREATE TABLE IF NOT EXISTS admin_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',  -- 'admin', 'super_admin'
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP
);

-- Indexes for admin_users table
CREATE INDEX IF NOT EXISTS idx_admin_username ON admin_users(username);
CREATE INDEX IF NOT EXISTS idx_admin_email ON admin_users(email);

-- ==================================================
-- 6. TRIGGERS
-- ==================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-set trial dates for new users
CREATE OR REPLACE FUNCTION set_trial_dates()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.subscription_status = 'trial' AND NEW.subscription_end_date IS NULL THEN
        NEW.subscription_start_date = NOW();
        NEW.subscription_end_date = NOW() + INTERVAL '14 days';
        NEW.trial_started_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER set_trial_on_insert BEFORE INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION set_trial_dates();

-- ==================================================
-- 7. DEFAULT DATA
-- ==================================================

-- Insert a default super admin (password: admin123 - CHANGE THIS!)
-- Password is bcrypt hash of 'admin123'
INSERT INTO admin_users (username, email, password_hash, role) 
VALUES (
    'admin',
    'admin@homeworkhelper.com',
    '$2b$10$ZjFzNjU3NjQ1YzQ0ZjQ1ZuKxqxqxqxqxqxqxqxqxqxqxqxqxqxqxqxqxqxq',  -- CHANGE THIS!
    'super_admin'
) ON CONFLICT (username) DO NOTHING;

-- Insert some sample promo codes
INSERT INTO promo_codes (code, duration_days, uses_total, uses_remaining, description, created_by)
VALUES 
    ('WELCOME2025', 90, 100, 100, 'Welcome promo - 3 months free', 'admin'),
    ('STUDENT50', 30, 50, 50, 'Student discount - 1 month', 'admin'),
    ('EARLYBIRD', 180, 20, 20, 'Early adopters - 6 months', 'admin')
ON CONFLICT (code) DO NOTHING;

-- ==================================================
-- 8. VIEWS FOR ANALYTICS
-- ==================================================

-- Active users view
CREATE OR REPLACE VIEW active_users AS
SELECT 
    user_id, 
    email, 
    username,
    subscription_status,
    subscription_end_date,
    EXTRACT(DAY FROM (subscription_end_date - NOW())) as days_remaining
FROM users
WHERE subscription_end_date > NOW() 
  AND is_active = true 
  AND is_banned = false;

-- Expired users view
CREATE OR REPLACE VIEW expired_users AS
SELECT 
    user_id, 
    email, 
    username,
    subscription_status,
    subscription_end_date,
    EXTRACT(DAY FROM (NOW() - subscription_end_date)) as days_expired
FROM users
WHERE subscription_end_date < NOW();

-- Promo code stats view
CREATE OR REPLACE VIEW promo_code_stats AS
SELECT 
    pc.code,
    pc.duration_days,
    pc.uses_total,
    pc.uses_remaining,
    pc.active,
    COUNT(pcu.id) as actual_uses,
    pc.created_at
FROM promo_codes pc
LEFT JOIN promo_code_usage pcu ON pc.id = pcu.promo_code_id
GROUP BY pc.id;

-- ==================================================
-- MIGRATION COMPLETE
-- ==================================================

-- Verify tables were created
SELECT 
    table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Display summary
SELECT 
    'Migration completed successfully!' as message,
    NOW() as completed_at;


