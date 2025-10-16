#!/usr/bin/env node

/**
 * Complete Staging Database Setup
 * This script will create all required tables and populate initial data
 * for the staging admin portal to work properly.
 */

const crypto = require('crypto');
const { Pool } = require('pg');

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'staging' 
    ? { rejectUnauthorized: false } 
    : false
});

// Use SHA256 to match the current system
function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

async function checkDatabaseConnection() {
  try {
    console.log('🔍 Checking database connection...');
    const client = await pool.connect();
    const result = await client.query('SELECT NOW() as current_time, current_database() as db_name');
    console.log('✅ Database connection successful!');
    console.log(`   Current time: ${result.rows[0].current_time}`);
    console.log(`   Database: ${result.rows[0].db_name}`);
    client.release();
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    return false;
  }
}

async function createAllTables() {
  try {
    console.log('🔧 Creating all required tables...');
    
    // Users table
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

    // Admin users table
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

    // Subscription history table
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

    // Promo codes table
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

    // Promo code usage table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS promo_code_usage (
        id SERIAL PRIMARY KEY,
        user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
        promo_code_id INTEGER REFERENCES promo_codes(id) ON DELETE CASCADE,
        used_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log('✅ Promo code usage table created/verified');

    // Device logins table
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

    // API usage tracking table
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

    // Monthly usage summary table
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

    // Entitlements ledger table
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

    // User entitlements table
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

    // Admin audit log table
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

async function setupAdminUser() {
  try {
    console.log('🔐 Setting up admin user...');
    
    const username = 'admin';
    const email = 'admin@homeworkhelper-staging.com';
    const password = 'Admin123!Staging';
    const passwordHash = hashPassword(password);
    
    // Check if admin exists
    const existingAdmin = await pool.query(
      'SELECT id FROM admin_users WHERE username = $1',
      [username]
    );
    
    if (existingAdmin.rows.length > 0) {
      // Update existing admin
      await pool.query(
        `UPDATE admin_users 
         SET email = $1, password_hash = $2, is_active = true, updated_at = NOW()
         WHERE username = $3`,
        [email, passwordHash, username]
      );
      console.log('✅ Updated existing admin user');
    } else {
      // Create new admin
      await pool.query(
        `INSERT INTO admin_users (username, email, password_hash, role, is_active)
         VALUES ($1, $2, $3, 'super_admin', true)`,
        [username, email, passwordHash]
      );
      console.log('✅ Created new admin user');
    }
    
    return true;
  } catch (error) {
    console.error('❌ Error setting up admin user:', error.message);
    throw error;
  }
}

async function createSampleData() {
  try {
    console.log('📊 Creating sample data...');
    
    // Create sample users
    const sampleUsers = [
      {
        email: 'testuser1@example.com',
        username: 'testuser1',
        subscription_status: 'active',
        subscription_days: 30
      },
      {
        email: 'testuser2@example.com',
        username: 'testuser2',
        subscription_status: 'trial',
        subscription_days: 7
      },
      {
        email: 'testuser3@example.com',
        username: 'testuser3',
        subscription_status: 'expired',
        subscription_days: 0
      }
    ];
    
    for (const user of sampleUsers) {
      // Check if user exists
      const existingUser = await pool.query(
        'SELECT user_id FROM users WHERE email = $1',
        [user.email]
      );
      
      if (existingUser.rows.length === 0) {
        const userId = crypto.randomUUID();
        const startDate = new Date();
        const endDate = new Date();
        endDate.setDate(endDate.getDate() + user.subscription_days);
        
        await pool.query(`
          INSERT INTO users (
            user_id, email, username, auth_provider, subscription_status,
            subscription_start_date, subscription_end_date, is_active
          ) VALUES ($1, $2, $3, 'email', $4, $5, $6, true)
        `, [userId, user.email, user.username, user.subscription_status, startDate, endDate]);
        
        console.log(`✅ Created sample user: ${user.email}`);
      }
    }
    
    // Create sample promo codes
    const samplePromoCodes = [
      {
        code: 'WELCOME2024',
        duration_days: 7,
        description: 'Welcome promo code',
        uses_total: 100
      },
      {
        code: 'STUDENT50',
        duration_days: 14,
        description: 'Student discount',
        uses_total: 50
      }
    ];
    
    for (const promo of samplePromoCodes) {
      const existingPromo = await pool.query(
        'SELECT id FROM promo_codes WHERE code = $1',
        [promo.code]
      );
      
      if (existingPromo.rows.length === 0) {
        await pool.query(`
          INSERT INTO promo_codes (code, duration_days, uses_total, uses_remaining, description, created_by)
          VALUES ($1, $2, $3, $3, $4, 'admin')
        `, [promo.code, promo.duration_days, promo.uses_total, promo.description]);
        
        console.log(`✅ Created sample promo code: ${promo.code}`);
      }
    }
    
    return true;
  } catch (error) {
    console.error('❌ Error creating sample data:', error.message);
    throw error;
  }
}

async function createViews() {
  try {
    console.log('🔍 Creating database views...');
    
    // User usage summary view
    await pool.query(`
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
    console.log('✅ User usage summary view created');
    
    // Monthly costs summary view
    await pool.query(`
      CREATE OR REPLACE VIEW monthly_costs_summary AS
      SELECT 
        mus.user_id,
        u.email,
        u.username,
        mus.year,
        mus.month,
        mus.total_tokens,
        mus.total_cost_usd,
        mus.api_calls_count,
        mus.subscription_renewals_count
      FROM monthly_usage_summary mus
      LEFT JOIN users u ON mus.user_id = u.user_id
      ORDER BY mus.year DESC, mus.month DESC, mus.total_cost_usd DESC;
    `);
    console.log('✅ Monthly costs summary view created');
    
    return true;
  } catch (error) {
    console.error('❌ Error creating views:', error.message);
    throw error;
  }
}

async function main() {
  console.log('🚀 Starting Complete Staging Database Setup');
  console.log('==========================================\n');
  
  try {
    // Step 1: Check database connection
    const dbConnected = await checkDatabaseConnection();
    if (!dbConnected) {
      throw new Error('Database connection failed');
    }
    
    // Step 2: Create all tables
    const tablesCreated = await createAllTables();
    if (!tablesCreated) {
      throw new Error('Failed to create tables');
    }
    
    // Step 3: Setup admin user
    const adminSetup = await setupAdminUser();
    if (!adminSetup) {
      throw new Error('Failed to setup admin user');
    }
    
    // Step 4: Create sample data
    const sampleData = await createSampleData();
    if (!sampleData) {
      throw new Error('Failed to create sample data');
    }
    
    // Step 5: Create views
    const viewsCreated = await createViews();
    if (!viewsCreated) {
      throw new Error('Failed to create views');
    }
    
    console.log('\n🎉 SUCCESS! Staging database is now fully configured!');
    console.log('\n🔑 Admin Portal Access:');
    console.log('   URL: https://homework-helper-staging.azurewebsites.net/admin/');
    console.log('   Username: admin');
    console.log('   Password: Admin123!Staging');
    console.log('\n✅ The admin portal should now show:');
    console.log('   - Dashboard with statistics');
    console.log('   - Sample users in Users tab');
    console.log('   - Sample promo codes');
    console.log('   - Working API usage analytics');
    console.log('   - Functional ledger and audit logs');
    
  } catch (error) {
    console.error('\n❌ FAILED: Database setup failed');
    console.error('Error:', error.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run the setup
main();
