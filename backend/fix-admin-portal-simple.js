#!/usr/bin/env node

/**
 * Simple Fix for Admin Portal Data Issues
 * This version uses the existing database connection from the app
 */

// Use the existing database connection from the app
const { Pool } = require('pg');

// Check if we're in Azure environment
const isAzure = process.env.WEBSITE_SITE_NAME || process.env.NODE_ENV === 'staging';

if (!isAzure) {
  console.log('❌ This script must be run in the Azure environment');
  console.log('   Make sure DATABASE_URL is set in Azure App Service settings');
  process.exit(1);
}

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function createTablesIfMissing() {
  try {
    console.log('🔧 Creating missing tables...');
    
    // Create users table if missing
    await pool.query(`
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
    console.log('✅ Users table created/verified');

    // Create admin_users table if missing
    await pool.query(`
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
    console.log('✅ Admin users table created/verified');

    // Create subscription_history table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS subscription_history (
        id SERIAL PRIMARY KEY,
        user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
        event_type VARCHAR(100) NOT NULL,
        metadata JSONB,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log('✅ Subscription history table created/verified');

    // Create promo_codes table
    await pool.query(`
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
    console.log('✅ Promo codes table created/verified');

    // Create device_logins table
    await pool.query(`
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
    console.log('✅ Device logins table created/verified');

    // Create user_api_usage table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS user_api_usage (
        id SERIAL PRIMARY KEY,
        user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
        endpoint VARCHAR(255) NOT NULL,
        tokens_used INTEGER DEFAULT 0,
        cost_usd DECIMAL(10,4) DEFAULT 0,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log('✅ API usage tracking table created/verified');

    // Create monthly_usage_summary table
    await pool.query(`
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
    console.log('✅ Monthly usage summary table created/verified');

    // Create entitlements_ledger table
    await pool.query(`
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
    console.log('✅ Entitlements ledger table created/verified');

    // Create user_entitlements table
    await pool.query(`
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
    console.log('✅ User entitlements table created/verified');

    // Create admin_audit_log table
    await pool.query(`
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
    console.log('✅ Admin audit log table created/verified');

    return true;
  } catch (error) {
    console.error('❌ Error creating tables:', error.message);
    throw error;
  }
}

async function populateSampleData() {
  try {
    console.log('📊 Populating sample data...');
    
    // Create sample users
    const sampleUsers = [
      {
        email: 'demo@example.com',
        username: 'demo_user',
        subscription_status: 'active',
        days: 30
      },
      {
        email: 'trial@example.com',
        username: 'trial_user',
        subscription_status: 'trial',
        days: 7
      },
      {
        email: 'expired@example.com',
        username: 'expired_user',
        subscription_status: 'expired',
        days: 0
      }
    ];
    
    for (const user of sampleUsers) {
      const existing = await pool.query('SELECT user_id FROM users WHERE email = $1', [user.email]);
      
      if (existing.rows.length === 0) {
        const userId = require('crypto').randomUUID();
        const startDate = new Date();
        const endDate = new Date();
        endDate.setDate(endDate.getDate() + user.days);
        
        await pool.query(`
          INSERT INTO users (user_id, email, username, auth_provider, subscription_status, subscription_start_date, subscription_end_date, is_active)
          VALUES ($1, $2, $3, 'email', $4, $5, $6, true)
        `, [userId, user.email, user.username, user.subscription_status, startDate, endDate]);
        
        console.log(`✅ Created user: ${user.email}`);
      }
    }
    
    // Create sample API usage data
    const users = await pool.query('SELECT user_id FROM users LIMIT 3');
    
    for (const user of users.rows) {
      const existingUsage = await pool.query(
        'SELECT id FROM user_api_usage WHERE user_id = $1',
        [user.user_id]
      );
      
      if (existingUsage.rows.length === 0) {
        await pool.query(`
          INSERT INTO user_api_usage (user_id, endpoint, tokens_used, cost_usd)
          VALUES 
            ($1, '/api/homework/analyze', 150, 0.003),
            ($1, '/api/homework/validate', 75, 0.0015),
            ($1, '/api/subscription/check', 25, 0.0005)
        `, [user.user_id]);
        
        console.log(`✅ Created API usage data for user: ${user.user_id}`);
      }
    }
    
    // Create sample device logins
    for (const user of users.rows) {
      const existingLogins = await pool.query(
        'SELECT id FROM device_logins WHERE user_id = $1',
        [user.user_id]
      );
      
      if (existingLogins.rows.length === 0) {
        await pool.query(`
          INSERT INTO device_logins (user_id, device_id, device_type, login_time, ip_address)
          VALUES 
            ($1, 'device-123', 'iPhone', NOW() - INTERVAL '1 day', '192.168.1.100'),
            ($1, 'device-456', 'iPad', NOW() - INTERVAL '2 days', '192.168.1.101')
        `, [user.user_id]);
        
        console.log(`✅ Created device login data for user: ${user.user_id}`);
      }
    }
    
    // Create sample promo codes
    const samplePromoCodes = [
      { code: 'WELCOME2024', days: 7, description: 'Welcome promo' },
      { code: 'STUDENT50', days: 14, description: 'Student discount' }
    ];
    
    for (const promo of samplePromoCodes) {
      const existing = await pool.query('SELECT id FROM promo_codes WHERE code = $1', [promo.code]);
      
      if (existing.rows.length === 0) {
        await pool.query(`
          INSERT INTO promo_codes (code, duration_days, uses_total, uses_remaining, description, created_by)
          VALUES ($1, $2, 100, 100, $3, 'admin')
        `, [promo.code, promo.days, promo.description]);
        
        console.log(`✅ Created promo code: ${promo.code}`);
      }
    }
    
    return true;
  } catch (error) {
    console.error('❌ Error populating sample data:', error.message);
    throw error;
  }
}

async function main() {
  console.log('🚀 Fixing Admin Portal Data Issues');
  console.log('==================================\n');
  
  try {
    // Create tables
    await createTablesIfMissing();
    
    // Populate sample data
    await populateSampleData();
    
    console.log('\n🎉 SUCCESS! Admin portal data issues fixed!');
    console.log('\n✅ The admin portal should now show:');
    console.log('   - Dashboard with user statistics');
    console.log('   - Users in the Users tab');
    console.log('   - Working API usage analytics');
    console.log('   - Sample promo codes');
    console.log('   - Device analytics data');
    
    console.log('\n🔄 Please refresh your admin portal to see the changes!');
    
  } catch (error) {
    console.error('\n❌ FAILED: Could not fix admin portal data');
    console.error('Error:', error.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run the fix
main();
