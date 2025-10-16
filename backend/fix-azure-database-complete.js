#!/usr/bin/env node

/**
 * Complete Azure Database Fix Script
 * This script connects directly to your Azure PostgreSQL database
 * and creates all required tables with proper structure, then populates data.
 */

const { Pool } = require('pg');
const crypto = require('crypto');

// Your Azure database connection string
const DATABASE_URL = 'postgresql://homeworkadmin:Admin123!Staging@homework-helper-staging-db.postgres.database.azure.com:5432/homework_helper_staging?sslmode=require';

// Database connection configuration
const pool = new Pool({
  connectionString: DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

// Helper function to hash passwords
function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

// Helper function to generate UUID
function generateUUID() {
  return crypto.randomUUID();
}

async function checkDatabaseConnection() {
  try {
    console.log('🔍 Testing database connection...');
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

async function createTablesIfMissing() {
  try {
    console.log('🔧 Creating/verifying database tables...');
    
    // Create user_api_usage table with correct structure
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
    console.log('   ✅ user_api_usage table created/verified');

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
    console.log('   ✅ device_logins table created/verified');

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
    console.log('   ✅ promo_codes table created/verified');

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
    console.log('   ✅ subscription_history table created/verified');

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
    console.log('   ✅ monthly_usage_summary table created/verified');

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
    console.log('   ✅ entitlements_ledger table created/verified');

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
    console.log('   ✅ user_entitlements table created/verified');

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
    console.log('   ✅ admin_audit_log table created/verified');

    return true;
  } catch (error) {
    console.error('❌ Error creating tables:', error.message);
    throw error;
  }
}

async function populateSampleUsers() {
  try {
    console.log('👥 Populating sample users...');
    
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
      },
      {
        email: 'student@example.com',
        username: 'student_user',
        subscription_status: 'active',
        days: 60
      },
      {
        email: 'teacher@example.com',
        username: 'teacher_user',
        subscription_status: 'active',
        days: 90
      }
    ];
    
    let createdCount = 0;
    
    for (const user of sampleUsers) {
      const existing = await pool.query('SELECT user_id FROM users WHERE email = $1', [user.email]);
      
      if (existing.rows.length === 0) {
        const userId = generateUUID();
        const startDate = new Date();
        const endDate = new Date();
        endDate.setDate(endDate.getDate() + user.days);
        
        await pool.query(`
          INSERT INTO users (user_id, email, username, auth_provider, subscription_status, subscription_start_date, subscription_end_date, is_active)
          VALUES ($1, $2, $3, 'email', $4, $5, $6, true)
        `, [userId, user.email, user.username, user.subscription_status, startDate, endDate]);
        
        console.log(`   ✅ Created user: ${user.email}`);
        createdCount++;
      } else {
        console.log(`   ⏭️  User already exists: ${user.email}`);
      }
    }
    
    console.log(`📊 Created ${createdCount} new users`);
    return true;
  } catch (error) {
    console.error('❌ Error populating sample users:', error.message);
    throw error;
  }
}

async function populateApiUsageData() {
  try {
    console.log('📊 Populating API usage data...');
    
    const users = await pool.query('SELECT user_id FROM users LIMIT 5');
    let createdCount = 0;
    
    for (const user of users.rows) {
      const existingUsage = await pool.query(
        'SELECT id FROM user_api_usage WHERE user_id = $1',
        [user.user_id]
      );
      
      if (existingUsage.rows.length === 0) {
        // Create multiple API usage records for each user
        const apiEndpoints = [
          { endpoint: '/api/homework/analyze', tokens: 150, cost: 0.003 },
          { endpoint: '/api/homework/validate', tokens: 75, cost: 0.0015 },
          { endpoint: '/api/subscription/check', tokens: 25, cost: 0.0005 },
          { endpoint: '/api/homework/analyze', tokens: 200, cost: 0.004 },
          { endpoint: '/api/homework/validate', tokens: 100, cost: 0.002 }
        ];
        
        for (const api of apiEndpoints) {
          await pool.query(`
            INSERT INTO user_api_usage (user_id, endpoint, tokens_used, cost_usd)
            VALUES ($1, $2, $3, $4)
          `, [user.user_id, api.endpoint, api.tokens, api.cost]);
        }
        
        console.log(`   ✅ Created API usage data for user: ${user.user_id.substring(0, 8)}...`);
        createdCount++;
      }
    }
    
    console.log(`📊 Created API usage data for ${createdCount} users`);
    return true;
  } catch (error) {
    console.error('❌ Error populating API usage data:', error.message);
    throw error;
  }
}

async function populateDeviceLogins() {
  try {
    console.log('📱 Populating device login data...');
    
    const users = await pool.query('SELECT user_id FROM users LIMIT 5');
    let createdCount = 0;
    
    for (const user of users.rows) {
      const existingLogins = await pool.query(
        'SELECT id FROM device_logins WHERE user_id = $1',
        [user.user_id]
      );
      
      if (existingLogins.rows.length === 0) {
        const deviceTypes = ['iPhone', 'iPad', 'Android', 'MacBook', 'Windows'];
        const deviceIds = ['device-123', 'device-456', 'device-789', 'device-abc', 'device-xyz'];
        
        for (let i = 0; i < 3; i++) {
          await pool.query(`
            INSERT INTO device_logins (user_id, device_id, device_type, login_time, ip_address)
            VALUES ($1, $2, $3, NOW() - INTERVAL '${i + 1} days', $4)
          `, [
            user.user_id, 
            deviceIds[i], 
            deviceTypes[i % deviceTypes.length],
            `192.168.1.${100 + i}`
          ]);
        }
        
        console.log(`   ✅ Created device login data for user: ${user.user_id.substring(0, 8)}...`);
        createdCount++;
      }
    }
    
    console.log(`📊 Created device login data for ${createdCount} users`);
    return true;
  } catch (error) {
    console.error('❌ Error populating device login data:', error.message);
    throw error;
  }
}

async function populatePromoCodes() {
  try {
    console.log('🎟️  Populating promo codes...');
    
    const samplePromoCodes = [
      { code: 'WELCOME2024', days: 7, description: 'Welcome promo for new users', uses: 100 },
      { code: 'STUDENT50', days: 14, description: 'Student discount promo', uses: 50 },
      { code: 'TEACHER30', days: 30, description: 'Teacher special offer', uses: 25 },
      { code: 'BACKTOSCHOOL', days: 21, description: 'Back to school promotion', uses: 75 },
      { code: 'HOLIDAY2024', days: 14, description: 'Holiday special offer', uses: 100 }
    ];
    
    let createdCount = 0;
    
    for (const promo of samplePromoCodes) {
      const existing = await pool.query('SELECT id FROM promo_codes WHERE code = $1', [promo.code]);
      
      if (existing.rows.length === 0) {
        await pool.query(`
          INSERT INTO promo_codes (code, duration_days, uses_total, uses_remaining, description, created_by)
          VALUES ($1, $2, $3, $3, $4, 'admin')
        `, [promo.code, promo.days, promo.uses, promo.description]);
        
        console.log(`   ✅ Created promo code: ${promo.code}`);
        createdCount++;
      } else {
        console.log(`   ⏭️  Promo code already exists: ${promo.code}`);
      }
    }
    
    console.log(`📊 Created ${createdCount} new promo codes`);
    return true;
  } catch (error) {
    console.error('❌ Error populating promo codes:', error.message);
    throw error;
  }
}

async function verifyAdminUser() {
  try {
    console.log('🔐 Verifying admin user...');
    
    const adminResult = await pool.query(
      'SELECT id, username, email, role, is_active FROM admin_users WHERE username = $1',
      ['admin']
    );
    
    if (adminResult.rows.length > 0) {
      const admin = adminResult.rows[0];
      console.log(`   ✅ Admin user exists: ${admin.username} (${admin.email})`);
      console.log(`   Role: ${admin.role}, Active: ${admin.is_active}`);
      return true;
    } else {
      console.log('   ⚠️  Admin user not found, creating...');
      
      const username = 'admin';
      const email = 'admin@homeworkhelper-staging.com';
      const password = 'Admin123!Staging';
      const passwordHash = hashPassword(password);
      
      await pool.query(`
        INSERT INTO admin_users (username, email, password_hash, role, is_active)
        VALUES ($1, $2, $3, 'super_admin', true)
      `, [username, email, passwordHash]);
      
      console.log('   ✅ Admin user created');
      return true;
    }
  } catch (error) {
    console.error('❌ Error verifying admin user:', error.message);
    throw error;
  }
}

async function generateReport() {
  try {
    console.log('📊 Generating final report...');
    
    // Get user count
    const usersResult = await pool.query('SELECT COUNT(*) as count FROM users');
    const userCount = parseInt(usersResult.rows[0].count);
    
    // Get API usage count
    const apiUsageResult = await pool.query('SELECT COUNT(*) as count FROM user_api_usage');
    const apiUsageCount = parseInt(apiUsageResult.rows[0].count);
    
    // Get promo codes count
    const promoResult = await pool.query('SELECT COUNT(*) as count FROM promo_codes');
    const promoCount = parseInt(promoResult.rows[0].count);
    
    console.log('\n📈 FINAL DATABASE STATISTICS:');
    console.log('============================');
    console.log(`👥 Users: ${userCount}`);
    console.log(`📊 API Usage Records: ${apiUsageCount}`);
    console.log(`🎟️  Promo Codes: ${promoCount}`);
    
    // Get some sample data
    const sampleUsers = await pool.query('SELECT email, subscription_status FROM users LIMIT 3');
    console.log('\n👥 Sample Users:');
    sampleUsers.rows.forEach((user, index) => {
      console.log(`   ${index + 1}. ${user.email} (${user.subscription_status})`);
    });
    
    const samplePromos = await pool.query('SELECT code, description FROM promo_codes LIMIT 3');
    console.log('\n🎟️  Sample Promo Codes:');
    samplePromos.rows.forEach((promo, index) => {
      console.log(`   ${index + 1}. ${promo.code} - ${promo.description}`);
    });
    
    return true;
  } catch (error) {
    console.error('❌ Error generating report:', error.message);
    return false;
  }
}

async function main() {
  console.log('🚀 COMPLETE AZURE DATABASE FIX SCRIPT');
  console.log('=====================================\n');
  
  const startTime = new Date();
  
  try {
    // Step 1: Check database connection
    const dbConnected = await checkDatabaseConnection();
    if (!dbConnected) {
      throw new Error('Database connection failed');
    }
    
    // Step 2: Create all required tables
    console.log('\n🔧 CREATING DATABASE TABLES:');
    console.log('============================');
    await createTablesIfMissing();
    
    // Step 3: Populate sample data
    console.log('\n🔧 POPULATING SAMPLE DATA:');
    console.log('===========================');
    
    await populateSampleUsers();
    await populateApiUsageData();
    await populateDeviceLogins();
    await populatePromoCodes();
    await verifyAdminUser();
    
    // Step 4: Generate final report
    console.log('\n📈 FINAL RESULTS:');
    console.log('=================');
    await generateReport();
    
    const endTime = new Date();
    const duration = Math.round((endTime - startTime) / 1000);
    
    console.log('\n🎉 SUCCESS! Database fix completed successfully!');
    console.log(`⏱️  Total time: ${duration} seconds`);
    console.log('\n✅ Your admin portal should now show:');
    console.log('   - Dashboard with user statistics');
    console.log('   - Users in the Users tab');
    console.log('   - Working API usage analytics');
    console.log('   - Sample promo codes');
    console.log('   - Device analytics data');
    console.log('\n🔄 Please refresh your admin portal to see the changes!');
    console.log('\n🔑 Admin Login Credentials:');
    console.log('   URL: https://homework-helper-staging.azurewebsites.net/admin/');
    console.log('   Username: admin');
    console.log('   Password: Admin123!Staging');
    
  } catch (error) {
    console.error('\n❌ FAILED: Database fix failed');
    console.error('Error:', error.message);
    console.error('\n🔧 Troubleshooting:');
    console.error('1. Check database server accessibility');
    console.error('2. Verify connection string is correct');
    console.error('3. Ensure database permissions');
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run the complete fix
main();
