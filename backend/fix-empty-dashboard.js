#!/usr/bin/env node

/**
 * Fix Empty Dashboard Script
 * This script ensures the admin portal has all the data it needs to display
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

async function ensureAdminUser() {
  try {
    console.log('🔐 Ensuring admin user exists...');
    
    const adminResult = await pool.query(
      'SELECT id, username, email, role, is_active FROM admin_users WHERE username = $1',
      ['admin']
    );
    
    if (adminResult.rows.length > 0) {
      const admin = adminResult.rows[0];
      console.log(`   ✅ Admin user exists: ${admin.username} (${admin.email})`);
      return admin;
    } else {
      console.log('   ⚠️  Creating admin user...');
      
      const username = 'admin';
      const email = 'admin@homeworkhelper-staging.com';
      const password = 'Admin123!Staging';
      const passwordHash = crypto.createHash('sha256').update(password).digest('hex');
      
      const result = await pool.query(`
        INSERT INTO admin_users (username, email, password_hash, role, is_active)
        VALUES ($1, $2, $3, 'super_admin', true)
        RETURNING id, username, email, role, is_active
      `, [username, email, passwordHash]);
      
      console.log('   ✅ Admin user created');
      return result.rows[0];
    }
  } catch (error) {
    console.error('❌ Error ensuring admin user:', error.message);
    throw error;
  }
}

async function ensureUsersExist() {
  try {
    console.log('👥 Ensuring users exist...');
    
    const usersResult = await pool.query('SELECT COUNT(*) FROM users');
    const userCount = parseInt(usersResult.rows[0].count);
    
    if (userCount === 0) {
      console.log('   ⚠️  No users found, creating sample users...');
      
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
      
      for (const user of sampleUsers) {
        const userId = crypto.randomUUID();
        const startDate = new Date();
        const endDate = new Date();
        endDate.setDate(endDate.getDate() + user.days);
        
        await pool.query(`
          INSERT INTO users (user_id, email, username, auth_provider, subscription_status, subscription_start_date, subscription_end_date, is_active)
          VALUES ($1, $2, $3, 'email', $4, $5, $6, true)
        `, [userId, user.email, user.username, user.subscription_status, startDate, endDate]);
        
        console.log(`   ✅ Created user: ${user.email}`);
      }
    } else {
      console.log(`   ✅ Found ${userCount} existing users`);
    }
    
    return userCount;
  } catch (error) {
    console.error('❌ Error ensuring users exist:', error.message);
    throw error;
  }
}

async function ensureApiUsageData() {
  try {
    console.log('📊 Ensuring API usage data...');
    
    const apiUsageResult = await pool.query('SELECT COUNT(*) FROM user_api_usage');
    const apiUsageCount = parseInt(apiUsageResult.rows[0].count);
    
    if (apiUsageCount === 0) {
      console.log('   ⚠️  No API usage data found, creating sample data...');
      
      const users = await pool.query('SELECT user_id FROM users LIMIT 5');
      
      for (const user of users.rows) {
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
      }
    } else {
      console.log(`   ✅ Found ${apiUsageCount} existing API usage records`);
    }
    
    return apiUsageCount;
  } catch (error) {
    console.error('❌ Error ensuring API usage data:', error.message);
    throw error;
  }
}

async function ensurePromoCodes() {
  try {
    console.log('🎟️  Ensuring promo codes exist...');
    
    const promoResult = await pool.query('SELECT COUNT(*) FROM promo_codes');
    const promoCount = parseInt(promoResult.rows[0].count);
    
    if (promoCount === 0) {
      console.log('   ⚠️  No promo codes found, creating sample codes...');
      
      const samplePromoCodes = [
        { code: 'WELCOME2024', days: 7, description: 'Welcome promo for new users', uses: 100 },
        { code: 'STUDENT50', days: 14, description: 'Student discount promo', uses: 50 },
        { code: 'TEACHER30', days: 30, description: 'Teacher special offer', uses: 25 },
        { code: 'BACKTOSCHOOL', days: 21, description: 'Back to school promotion', uses: 75 },
        { code: 'HOLIDAY2024', days: 14, description: 'Holiday special offer', uses: 100 }
      ];
      
      for (const promo of samplePromoCodes) {
        await pool.query(`
          INSERT INTO promo_codes (code, duration_days, uses_total, uses_remaining, description, created_by)
          VALUES ($1, $2, $3, $3, $4, 'admin')
        `, [promo.code, promo.days, promo.uses, promo.description]);
        
        console.log(`   ✅ Created promo code: ${promo.code}`);
      }
    } else {
      console.log(`   ✅ Found ${promoCount} existing promo codes`);
    }
    
    return promoCount;
  } catch (error) {
    console.error('❌ Error ensuring promo codes:', error.message);
    throw error;
  }
}

async function ensureDeviceLogins() {
  try {
    console.log('📱 Ensuring device logins exist...');
    
    const deviceResult = await pool.query('SELECT COUNT(*) FROM device_logins');
    const deviceCount = parseInt(deviceResult.rows[0].count);
    
    if (deviceCount === 0) {
      console.log('   ⚠️  No device logins found, creating sample data...');
      
      const users = await pool.query('SELECT user_id FROM users LIMIT 5');
      
      for (const user of users.rows) {
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
      }
    } else {
      console.log(`   ✅ Found ${deviceCount} existing device logins`);
    }
    
    return deviceCount;
  } catch (error) {
    console.error('❌ Error ensuring device logins:', error.message);
    throw error;
  }
}

async function testAdminStats() {
  try {
    console.log('\n📊 Testing admin stats queries...');
    
    // Total users
    const totalUsersResult = await pool.query('SELECT COUNT(*) FROM users');
    const totalUsers = parseInt(totalUsersResult.rows[0].count);
    
    // Active subscriptions
    const activeSubsResult = await pool.query(`
        SELECT COUNT(*) FROM users 
        WHERE subscription_end_date > NOW() AND is_active = true
    `);
    const activeSubs = parseInt(activeSubsResult.rows[0].count);
    
    // Trial users
    const trialUsersResult = await pool.query(`
        SELECT COUNT(*) FROM users 
        WHERE subscription_status = 'trial'
    `);
    const trialUsers = parseInt(trialUsersResult.rows[0].count);
    
    // Expired subscriptions
    const expiredResult = await pool.query(`
        SELECT COUNT(*) FROM users 
        WHERE subscription_end_date < NOW()
    `);
    const expiredSubs = parseInt(expiredResult.rows[0].count);
    
    console.log(`   Total users: ${totalUsers}`);
    console.log(`   Active subscriptions: ${activeSubs}`);
    console.log(`   Trial users: ${trialUsers}`);
    console.log(`   Expired subscriptions: ${expiredSubs}`);
    
    return {
      total_users: totalUsers,
      active_subscriptions: activeSubs,
      trial_users: trialUsers,
      expired_subscriptions: expiredSubs,
      recent_signups_30d: totalUsers,
      total_revenue: 0
    };
    
  } catch (error) {
    console.error('❌ Error testing admin stats:', error.message);
    throw error;
  }
}

async function main() {
  console.log('🚀 FIXING EMPTY DASHBOARD');
  console.log('=========================\n');
  
  try {
    // Ensure all required data exists
    await ensureAdminUser();
    await ensureUsersExist();
    await ensureApiUsageData();
    await ensurePromoCodes();
    await ensureDeviceLogins();
    
    // Test the stats that the dashboard should show
    const stats = await testAdminStats();
    
    console.log('\n🎉 DASHBOARD FIX COMPLETE!');
    console.log('===========================');
    console.log('✅ Admin user: Ready');
    console.log('✅ Users: Populated');
    console.log('✅ API Usage: Populated');
    console.log('✅ Promo Codes: Populated');
    console.log('✅ Device Logins: Populated');
    
    console.log('\n📊 EXPECTED DASHBOARD DATA:');
    console.log('===========================');
    console.log(`👥 Total Users: ${stats.total_users}`);
    console.log(`✅ Active Subscriptions: ${stats.active_subscriptions}`);
    console.log(`🆓 Trial Users: ${stats.trial_users}`);
    console.log(`❌ Expired Subscriptions: ${stats.expired_subscriptions}`);
    
    console.log('\n🔑 ADMIN LOGIN:');
    console.log('==============');
    console.log('URL: https://homework-helper-staging.azurewebsites.net/admin/');
    console.log('Username: admin');
    console.log('Password: Admin123!Staging');
    
    console.log('\n🔄 NEXT STEPS:');
    console.log('==============');
    console.log('1. Refresh the admin portal page');
    console.log('2. Login with the credentials above');
    console.log('3. The dashboard should now show data');
    console.log('4. If still empty, check browser console for JavaScript errors');
    
  } catch (error) {
    console.error('\n❌ FIX FAILED:', error.message);
    console.error('\n🔧 Troubleshooting:');
    console.error('1. Check database connection');
    console.error('2. Verify all tables exist');
    console.error('3. Check Azure App Service configuration');
  } finally {
    await pool.end();
  }
}

// Run the fix
main();
