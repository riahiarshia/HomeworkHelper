#!/usr/bin/env node

/**
 * Fix Existing Table Structure Script
 * This script works with the existing table structure and populates data
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
        // Create multiple API usage records for each user using existing table structure
        const apiEndpoints = [
          { 
            endpoint: '/api/homework/analyze', 
            model: 'gpt-4',
            prompt_tokens: 100,
            completion_tokens: 50,
            total_tokens: 150,
            cost: 0.003
          },
          { 
            endpoint: '/api/homework/validate', 
            model: 'gpt-3.5-turbo',
            prompt_tokens: 50,
            completion_tokens: 25,
            total_tokens: 75,
            cost: 0.0015
          },
          { 
            endpoint: '/api/subscription/check', 
            model: 'gpt-3.5-turbo',
            prompt_tokens: 20,
            completion_tokens: 5,
            total_tokens: 25,
            cost: 0.0005
          }
        ];
        
        for (const api of apiEndpoints) {
          await pool.query(`
            INSERT INTO user_api_usage (
              user_id, endpoint, model, prompt_tokens, completion_tokens, 
              total_tokens, cost_usd, problem_id, session_id, device_id
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
          `, [
            user.user_id, 
            api.endpoint, 
            api.model,
            api.prompt_tokens,
            api.completion_tokens,
            api.total_tokens,
            api.cost,
            `problem-${Math.random().toString(36).substr(2, 9)}`,
            `session-${Math.random().toString(36).substr(2, 9)}`,
            `device-${Math.random().toString(36).substr(2, 9)}`
          ]);
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
      const passwordHash = crypto.createHash('sha256').update(password).digest('hex');
      
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
  console.log('🚀 FIXING EXISTING DATABASE STRUCTURE');
  console.log('=====================================\n');
  
  try {
    // Step 1: Populate data using existing table structure
    console.log('\n🔧 POPULATING DATA:');
    console.log('===================');
    
    await populateApiUsageData();
    await populateDeviceLogins();
    await populatePromoCodes();
    await verifyAdminUser();
    
    // Step 2: Generate final report
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
