#!/usr/bin/env node

/**
 * Environment Check Script
 * This script checks which database environment you're connected to
 * and prevents accidental local database connections for production fixes
 */

const { Pool } = require('pg');

async function checkEnvironment() {
  console.log('🔍 ENVIRONMENT CHECK');
  console.log('===================');
  
  // Check environment variables
  console.log(`NODE_ENV: ${process.env.NODE_ENV || 'undefined'}`);
  console.log(`WEBSITE_SITE_NAME: ${process.env.WEBSITE_SITE_NAME || 'undefined'}`);
  console.log(`DATABASE_URL: ${process.env.DATABASE_URL ? 'SET' : 'NOT SET'}`);
  
  if (!process.env.DATABASE_URL) {
    console.log('❌ DATABASE_URL not set - cannot connect to database');
    console.log('💡 Make sure you are running this in the Azure environment');
    return;
  }
  
  try {
    const pool = new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false }
    });
    
    const result = await pool.query('SELECT current_database() as db_name, inet_server_addr() as server_ip');
    const dbName = result.rows[0].db_name;
    const serverIp = result.rows[0].server_ip;
    
    console.log(`Database: ${dbName}`);
    console.log(`Server IP: ${serverIp}`);
    
    if (dbName.includes('staging')) {
      console.log('✅ AZURE STAGING ENVIRONMENT - Safe for production fixes');
      console.log('🎯 You can run database fix scripts here');
    } else if (dbName.includes('homework_helper')) {
      console.log('✅ AZURE PRODUCTION ENVIRONMENT - Safe for production fixes');
      console.log('🎯 You can run database fix scripts here');
    } else if (dbName === 'ar616n' || dbName.includes('local')) {
      console.log('⚠️  LOCAL DEVELOPMENT ENVIRONMENT - NOT suitable for production fixes');
      console.log('❌ DO NOT run production database fixes here');
      console.log('💡 Run this script in Azure environment instead');
      console.log('🔗 Go to: https://homework-helper-staging.scm.azurewebsites.net');
    } else {
      console.log('⚠️  UNKNOWN ENVIRONMENT - Check database connection');
    }
    
    await pool.end();
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    
    if (error.message.includes('database "ar616n" does not exist')) {
      console.log('⚠️  This is a LOCAL DEVELOPMENT environment');
      console.log('❌ DO NOT run production database fixes here');
      console.log('💡 Run this script in Azure environment instead');
      console.log('🔗 Go to: https://homework-helper-staging.scm.azurewebsites.net');
    }
  }
}

// Run the environment check
checkEnvironment();
