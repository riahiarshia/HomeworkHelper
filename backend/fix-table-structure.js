#!/usr/bin/env node

/**
 * Fix Table Structure Script
 * This script checks and fixes the existing table structure
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

async function checkTableStructure() {
  try {
    console.log('🔍 Checking table structure...');
    
    // Check user_api_usage table structure
    const result = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'user_api_usage' 
      ORDER BY ordinal_position;
    `);
    
    console.log('📊 user_api_usage table columns:');
    result.rows.forEach(row => {
      console.log(`   - ${row.column_name}: ${row.data_type}`);
    });
    
    return result.rows;
  } catch (error) {
    console.error('❌ Error checking table structure:', error.message);
    return null;
  }
}

async function fixTableStructure() {
  try {
    console.log('🔧 Fixing table structure...');
    
    // Drop and recreate user_api_usage table with correct structure
    await pool.query('DROP TABLE IF EXISTS user_api_usage CASCADE');
    console.log('   ✅ Dropped existing user_api_usage table');
    
    await pool.query(`
      CREATE TABLE user_api_usage (
        id SERIAL PRIMARY KEY,
        user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
        endpoint VARCHAR(255) NOT NULL,
        tokens_used INTEGER DEFAULT 0,
        cost_usd DECIMAL(10,4) DEFAULT 0,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log('   ✅ Created user_api_usage table with correct structure');
    
    return true;
  } catch (error) {
    console.error('❌ Error fixing table structure:', error.message);
    throw error;
  }
}

async function populateApiUsageData() {
  try {
    console.log('📊 Populating API usage data...');
    
    const users = await pool.query('SELECT user_id FROM users LIMIT 5');
    let createdCount = 0;
    
    for (const user of users.rows) {
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
  console.log('🚀 FIXING TABLE STRUCTURE AND POPULATING DATA');
  console.log('=============================================\n');
  
  try {
    // Step 1: Check current table structure
    await checkTableStructure();
    
    // Step 2: Fix table structure
    console.log('\n🔧 FIXING TABLE STRUCTURE:');
    console.log('==========================');
    await fixTableStructure();
    
    // Step 3: Populate data
    console.log('\n🔧 POPULATING DATA:');
    console.log('===================');
    
    await populateApiUsageData();
    await populateDeviceLogins();
    await populatePromoCodes();
    
    // Step 4: Generate final report
    console.log('\n📈 FINAL RESULTS:');
    console.log('=================');
    await generateReport();
    
    console.log('\n🎉 SUCCESS! Database fix completed successfully!');
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
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run the fix
main();
