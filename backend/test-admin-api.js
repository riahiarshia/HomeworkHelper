#!/usr/bin/env node

/**
 * Test Admin API Script
 * This script tests the admin API endpoints to see what data is being returned
 */

const { Pool } = require('pg');

// Your Azure database connection string
const DATABASE_URL = 'postgresql://homeworkadmin:Admin123!Staging@homework-helper-staging-db.postgres.database.azure.com:5432/homework_helper_staging?sslmode=require';

// Database connection configuration
const pool = new Pool({
  connectionString: DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function testDatabaseConnection() {
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

async function testAdminStats() {
  try {
    console.log('\n📊 Testing admin stats queries...');
    
    // Total users
    const totalUsersResult = await pool.query('SELECT COUNT(*) FROM users');
    console.log(`   Total users: ${totalUsersResult.rows[0].count}`);
    
    // Active subscriptions
    const activeSubsResult = await pool.query(`
        SELECT COUNT(*) FROM users 
        WHERE subscription_end_date > NOW() AND is_active = true
    `);
    console.log(`   Active subscriptions: ${activeSubsResult.rows[0].count}`);
    
    // Trial users
    const trialUsersResult = await pool.query(`
        SELECT COUNT(*) FROM users 
        WHERE subscription_status = 'trial'
    `);
    console.log(`   Trial users: ${trialUsersResult.rows[0].count}`);
    
    // Expired subscriptions
    const expiredResult = await pool.query(`
        SELECT COUNT(*) FROM users 
        WHERE subscription_end_date < NOW()
    `);
    console.log(`   Expired subscriptions: ${expiredResult.rows[0].count}`);
    
    // Recent signups (last 30 days)
    const recentSignupsResult = await pool.query(`
        SELECT COUNT(*) FROM users 
        WHERE created_at > NOW() - INTERVAL '30 days'
    `);
    console.log(`   Recent signups (30d): ${recentSignupsResult.rows[0].count}`);
    
    return {
      total_users: parseInt(totalUsersResult.rows[0].count),
      active_subscriptions: parseInt(activeSubsResult.rows[0].count),
      trial_users: parseInt(trialUsersResult.rows[0].count),
      expired_subscriptions: parseInt(expiredResult.rows[0].count),
      recent_signups_30d: parseInt(recentSignupsResult.rows[0].count)
    };
    
  } catch (error) {
    console.error('❌ Error testing admin stats:', error.message);
    throw error;
  }
}

async function testUsersData() {
  try {
    console.log('\n👥 Testing users data...');
    
    // Get sample users
    const usersResult = await pool.query(`
        SELECT user_id, email, username, subscription_status, is_active, created_at
        FROM users 
        ORDER BY created_at DESC 
        LIMIT 5
    `);
    
    console.log(`   Found ${usersResult.rows.length} users:`);
    usersResult.rows.forEach((user, index) => {
      console.log(`   ${index + 1}. ${user.email} (${user.subscription_status}) - Active: ${user.is_active}`);
    });
    
    return usersResult.rows;
    
  } catch (error) {
    console.error('❌ Error testing users data:', error.message);
    throw error;
  }
}

async function testApiUsageData() {
  try {
    console.log('\n📊 Testing API usage data...');
    
    // Check if user_api_usage table exists and has data
    const apiUsageResult = await pool.query('SELECT COUNT(*) FROM user_api_usage');
    console.log(`   API usage records: ${apiUsageResult.rows[0].count}`);
    
    if (parseInt(apiUsageResult.rows[0].count) > 0) {
      const sampleUsage = await pool.query(`
          SELECT endpoint, model, total_tokens, cost_usd, created_at
          FROM user_api_usage 
          ORDER BY created_at DESC 
          LIMIT 3
      `);
      
      console.log('   Sample API usage:');
      sampleUsage.rows.forEach((usage, index) => {
        console.log(`   ${index + 1}. ${usage.endpoint} (${usage.model}) - ${usage.total_tokens} tokens, $${usage.cost_usd}`);
      });
    }
    
    return parseInt(apiUsageResult.rows[0].count);
    
  } catch (error) {
    console.error('❌ Error testing API usage data:', error.message);
    throw error;
  }
}

async function testPromoCodesData() {
  try {
    console.log('\n🎟️  Testing promo codes data...');
    
    const promoResult = await pool.query('SELECT COUNT(*) FROM promo_codes');
    console.log(`   Promo codes: ${promoResult.rows[0].count}`);
    
    if (parseInt(promoResult.rows[0].count) > 0) {
      const samplePromos = await pool.query(`
          SELECT code, duration_days, uses_total, description, active
          FROM promo_codes 
          ORDER BY created_at DESC 
          LIMIT 3
      `);
      
      console.log('   Sample promo codes:');
      samplePromos.rows.forEach((promo, index) => {
        console.log(`   ${index + 1}. ${promo.code} (${promo.duration_days} days) - Active: ${promo.active}`);
      });
    }
    
    return parseInt(promoResult.rows[0].count);
    
  } catch (error) {
    console.error('❌ Error testing promo codes data:', error.message);
    throw error;
  }
}

async function testDeviceLoginsData() {
  try {
    console.log('\n📱 Testing device logins data...');
    
    const deviceResult = await pool.query('SELECT COUNT(*) FROM device_logins');
    console.log(`   Device logins: ${deviceResult.rows[0].count}`);
    
    if (parseInt(deviceResult.rows[0].count) > 0) {
      const sampleDevices = await pool.query(`
          SELECT user_id, device_id, device_type, login_time
          FROM device_logins 
          ORDER BY login_time DESC 
          LIMIT 3
      `);
      
      console.log('   Sample device logins:');
      sampleDevices.rows.forEach((device, index) => {
        console.log(`   ${index + 1}. ${device.device_id} (${device.device_type}) - ${device.login_time}`);
      });
    }
    
    return parseInt(deviceResult.rows[0].count);
    
  } catch (error) {
    console.error('❌ Error testing device logins data:', error.message);
    throw error;
  }
}

async function main() {
  console.log('🚀 ADMIN API TEST SCRIPT');
  console.log('========================\n');
  
  try {
    // Test database connection
    const dbConnected = await testDatabaseConnection();
    if (!dbConnected) {
      throw new Error('Database connection failed');
    }
    
    // Test all data sources
    const stats = await testAdminStats();
    const users = await testUsersData();
    const apiUsage = await testApiUsageData();
    const promoCodes = await testPromoCodesData();
    const deviceLogins = await testDeviceLoginsData();
    
    console.log('\n📈 FINAL SUMMARY:');
    console.log('=================');
    console.log(`👥 Users: ${stats.total_users}`);
    console.log(`📊 API Usage Records: ${apiUsage}`);
    console.log(`🎟️  Promo Codes: ${promoCodes}`);
    console.log(`📱 Device Logins: ${deviceLogins}`);
    
    console.log('\n✅ All data sources are working!');
    console.log('\n🔍 TROUBLESHOOTING TIPS:');
    console.log('1. Check browser console for JavaScript errors');
    console.log('2. Verify admin token is valid');
    console.log('3. Check if API endpoints are accessible');
    console.log('4. Try refreshing the admin portal');
    console.log('5. Check Azure App Service logs for errors');
    
  } catch (error) {
    console.error('\n❌ TEST FAILED:', error.message);
    console.error('\n🔧 Troubleshooting:');
    console.error('1. Check database connection');
    console.error('2. Verify all tables exist');
    console.error('3. Check Azure App Service configuration');
  } finally {
    await pool.end();
  }
}

// Run the test
main();
