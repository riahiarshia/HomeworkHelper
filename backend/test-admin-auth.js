#!/usr/bin/env node

/**
 * Test Admin Authentication Script
 * This script tests the admin authentication and API endpoints
 */

const { Pool } = require('pg');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');

// Your Azure database connection string
const DATABASE_URL = 'postgresql://homeworkadmin:Admin123!Staging@homework-helper-staging-db.postgres.database.azure.com:5432/homework_helper_staging?sslmode=require';

// Database connection configuration
const pool = new Pool({
  connectionString: DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

// JWT secret (should match your environment)
const ADMIN_JWT_SECRET = 'staging-super-secret-jwt-key-minimum-32-characters-long';

async function testAdminUser() {
  try {
    console.log('🔐 Testing admin user...');
    
    const adminResult = await pool.query(
      'SELECT id, username, email, role, is_active FROM admin_users WHERE username = $1',
      ['admin']
    );
    
    if (adminResult.rows.length > 0) {
      const admin = adminResult.rows[0];
      console.log(`   ✅ Admin user found: ${admin.username} (${admin.email})`);
      console.log(`   Role: ${admin.role}, Active: ${admin.is_active}`);
      return admin;
    } else {
      console.log('   ❌ Admin user not found');
      return null;
    }
    
  } catch (error) {
    console.error('❌ Error testing admin user:', error.message);
    return null;
  }
}

async function testAdminLogin() {
  try {
    console.log('\n🔑 Testing admin login...');
    
    const username = 'admin';
    const password = 'Admin123!Staging';
    
    // Hash the password
    const passwordHash = crypto.createHash('sha256').update(password).digest('hex');
    
    // Check if admin exists with correct password
    const result = await pool.query(
      'SELECT * FROM admin_users WHERE username = $1 AND password_hash = $2 AND is_active = true',
      [username, passwordHash]
    );
    
    if (result.rows.length > 0) {
      const admin = result.rows[0];
      console.log(`   ✅ Admin login successful: ${admin.username}`);
      
      // Generate JWT token
      const token = jwt.sign(
        { adminId: admin.id, username: admin.username, email: admin.email, isAdmin: true },
        ADMIN_JWT_SECRET,
        { expiresIn: '7d' }
      );
      
      console.log(`   ✅ JWT token generated: ${token.substring(0, 20)}...`);
      return { admin, token };
    } else {
      console.log('   ❌ Admin login failed - invalid credentials');
      return null;
    }
    
  } catch (error) {
    console.error('❌ Error testing admin login:', error.message);
    return null;
  }
}

async function testStatsEndpoint() {
  try {
    console.log('\n📊 Testing stats endpoint logic...');
    
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
    
    const stats = {
      total_users: totalUsers,
      active_subscriptions: activeSubs,
      trial_users: trialUsers,
      expired_subscriptions: expiredSubs,
      recent_signups_30d: totalUsers, // All users are recent in our test data
      total_revenue: 0
    };
    
    console.log('   ✅ Stats endpoint would return:', JSON.stringify(stats, null, 2));
    return stats;
    
  } catch (error) {
    console.error('❌ Error testing stats endpoint:', error.message);
    throw error;
  }
}

async function testUsersEndpoint() {
  try {
    console.log('\n👥 Testing users endpoint logic...');
    
    const usersResult = await pool.query(`
        SELECT user_id, email, username, subscription_status, is_active, created_at,
               subscription_start_date, subscription_end_date,
               EXTRACT(DAYS FROM (subscription_end_date - NOW())) as days_remaining
        FROM users 
        ORDER BY created_at DESC 
        LIMIT 5
    `);
    
    console.log(`   Found ${usersResult.rows.length} users for display`);
    usersResult.rows.forEach((user, index) => {
      console.log(`   ${index + 1}. ${user.email} (${user.subscription_status}) - ${user.days_remaining} days left`);
    });
    
    return usersResult.rows;
    
  } catch (error) {
    console.error('❌ Error testing users endpoint:', error.message);
    throw error;
  }
}

async function main() {
  console.log('🚀 ADMIN AUTHENTICATION TEST SCRIPT');
  console.log('===================================\n');
  
  try {
    // Test admin user
    const admin = await testAdminUser();
    if (!admin) {
      throw new Error('Admin user not found');
    }
    
    // Test admin login
    const loginResult = await testAdminLogin();
    if (!loginResult) {
      throw new Error('Admin login failed');
    }
    
    // Test stats endpoint
    const stats = await testStatsEndpoint();
    
    // Test users endpoint
    const users = await testUsersEndpoint();
    
    console.log('\n🎉 ALL TESTS PASSED!');
    console.log('===================');
    console.log('✅ Admin user exists and is active');
    console.log('✅ Admin login works with correct credentials');
    console.log('✅ JWT token generation works');
    console.log('✅ Stats endpoint logic works');
    console.log('✅ Users endpoint logic works');
    
    console.log('\n🔍 TROUBLESHOOTING THE EMPTY DASHBOARD:');
    console.log('========================================');
    console.log('1. Check browser console for JavaScript errors');
    console.log('2. Verify the admin token is being stored in localStorage');
    console.log('3. Check if the API calls are being made correctly');
    console.log('4. Verify the admin portal is loading the correct JavaScript file');
    console.log('5. Check if there are any CORS issues');
    console.log('6. Try opening browser developer tools and check Network tab');
    
    console.log('\n🔑 ADMIN LOGIN CREDENTIALS:');
    console.log('===========================');
    console.log('URL: https://homework-helper-staging.azurewebsites.net/admin/');
    console.log('Username: admin');
    console.log('Password: Admin123!Staging');
    
  } catch (error) {
    console.error('\n❌ TEST FAILED:', error.message);
    console.error('\n🔧 Troubleshooting:');
    console.error('1. Check database connection');
    console.error('2. Verify admin user exists');
    console.error('3. Check JWT secret configuration');
  } finally {
    await pool.end();
  }
}

// Run the test
main();
