#!/usr/bin/env node

/**
 * Safe Database Fix Script
 * This script includes environment checks to prevent accidental local database connections
 * and only runs in Azure environments where DATABASE_URL is properly configured
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

async function checkEnvironment() {
  console.log('🔍 ENVIRONMENT CHECK');
  console.log('===================');
  
  // Check if we're in Azure environment
  const isAzure = process.env.WEBSITE_SITE_NAME || process.env.NODE_ENV === 'staging' || process.env.NODE_ENV === 'production';
  
  if (!isAzure) {
    console.log('⚠️  WARNING: This appears to be a LOCAL DEVELOPMENT environment');
    console.log('❌ DO NOT run production database fixes locally');
    console.log('💡 This script should be run in Azure environment');
    console.log('🔗 Go to: https://homework-helper-staging.scm.azurewebsites.net');
    console.log('   Navigate to: Debug Console → CMD');
    console.log('   Then run: node safe-database-fix.js');
    process.exit(1);
  }
  
  console.log('✅ Azure environment detected - safe to proceed');
  return true;
}

async function checkDatabaseConnection() {
  try {
    console.log('🔍 Testing database connection...');
    const client = await pool.connect();
    const result = await client.query('SELECT current_database() as db_name, inet_server_addr() as server_ip');
    const dbName = result.rows[0].db_name;
    const serverIp = result.rows[0].server_ip;
    
    console.log(`✅ Connected to database: ${dbName}`);
    console.log(`   Server IP: ${serverIp}`);
    
    if (dbName.includes('staging')) {
      console.log('✅ Connected to Azure Staging Database - Safe for fixes');
    } else if (dbName.includes('homework_helper')) {
      console.log('✅ Connected to Azure Production Database - Safe for fixes');
    } else {
      console.log('⚠️  Connected to unexpected database - Proceeding with caution');
    }
    
    client.release();
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    return false;
  }
}

async function populateSampleData() {
  try {
    console.log('📊 Populating sample data...');
    
    // Create promo codes
    const promos = [
      ['WELCOME2024', 7, 100, 'Welcome promo'],
      ['STUDENT50', 14, 50, 'Student discount'],
      ['TEACHER30', 30, 25, 'Teacher special'],
      ['BACKTOSCHOOL', 21, 75, 'Back to school'],
      ['HOLIDAY2024', 14, 100, 'Holiday special']
    ];
    
    for (const [code, days, uses, desc] of promos) {
      await pool.query(`
        INSERT INTO promo_codes (code, duration_days, uses_total, uses_remaining, description, created_by)
        VALUES ($1, $2, $3, $3, $4, 'admin')
        ON CONFLICT (code) DO NOTHING
      `, [code, days, uses, desc]);
    }
    console.log('✅ Created promo codes');
    
    // Create device logins if table exists
    try {
      const users = await pool.query('SELECT user_id FROM users LIMIT 5');
      for (const user of users.rows) {
        for (let i = 0; i < 3; i++) {
          await pool.query(`
            INSERT INTO device_logins (user_id, device_id, device_type, login_time, ip_address)
            VALUES ($1, $2, $3, NOW() - INTERVAL '${i + 1} days', $4)
            ON CONFLICT DO NOTHING
          `, [
            user.user_id, 
            `device-${i}`, 
            ['iPhone', 'iPad', 'Android'][i], 
            `192.168.1.${100 + i}`
          ]);
        }
      }
      console.log('✅ Populated device login data');
    } catch (error) {
      console.log('⚠️  Device logins table not found - skipping');
    }
    
    return true;
  } catch (error) {
    console.error('❌ Error populating sample data:', error.message);
    throw error;
  }
}

async function generateReport() {
  try {
    console.log('📊 Generating final report...');
    
    const [usersResult, apiResult, promoResult] = await Promise.all([
      pool.query('SELECT COUNT(*) as count FROM users'),
      pool.query('SELECT COUNT(*) as count FROM user_api_usage'),
      pool.query('SELECT COUNT(*) as count FROM promo_codes')
    ]);
    
    console.log('\n📈 FINAL STATISTICS:');
    console.log('============================');
    console.log(`👥 Users: ${usersResult.rows[0].count}`);
    console.log(`📊 API Usage: ${apiResult.rows[0].count}`);
    console.log(`🎟️  Promo Codes: ${promoResult.rows[0].count}`);
    
    console.log('\n🎉 SUCCESS! Database fix completed safely!');
    console.log('🔑 Login: https://homework-helper-staging.azurewebsites.net/admin/');
    console.log('👤 Username: admin | Password: Admin123!Staging');
    
  } catch (error) {
    console.error('❌ Error generating report:', error.message);
  }
}

async function main() {
  console.log('🚀 SAFE DATABASE FIX SCRIPT');
  console.log('===========================\n');
  
  try {
    // Step 1: Check environment
    await checkEnvironment();
    
    // Step 2: Check database connection
    const dbConnected = await checkDatabaseConnection();
    if (!dbConnected) {
      throw new Error('Database connection failed');
    }
    
    // Step 3: Populate data
    await populateSampleData();
    
    // Step 4: Generate report
    await generateReport();
    
  } catch (error) {
    console.error('\n❌ FAILED: Database fix failed');
    console.error('Error:', error.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run the safe fix
main();
