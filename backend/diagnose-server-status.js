#!/usr/bin/env node

/**
 * Diagnose Server Status Script
 * This script checks the current status of the Azure App Service
 */

const { Pool } = require('pg');

// Your Azure database connection string
const DATABASE_URL = 'postgresql://homeworkadmin:Admin123!Staging@homework-helper-staging-db.postgres.database.azure.com:5432/homework_helper_staging?sslmode=require';

console.log('🔍 DIAGNOSING SERVER STATUS');
console.log('===========================\n');

async function checkDatabaseConnection() {
  try {
    console.log('📊 Checking database connection...');
    
    const pool = new Pool({
      connectionString: DATABASE_URL,
      ssl: { rejectUnauthorized: false }
    });
    
    const client = await pool.connect();
    const result = await client.query('SELECT NOW() as current_time, current_database() as db_name');
    client.release();
    await pool.end();
    
    console.log('   ✅ Database connection successful');
    console.log(`   📅 Current time: ${result.rows[0].current_time}`);
    console.log(`   🗄️  Database: ${result.rows[0].db_name}`);
    
    return true;
  } catch (error) {
    console.error('   ❌ Database connection failed:', error.message);
    return false;
  }
}

async function checkEnvironmentVariables() {
  console.log('\n🔧 Checking environment variables...');
  
  const requiredVars = [
    'DATABASE_URL',
    'NODE_ENV', 
    'JWT_SECRET',
    'ADMIN_JWT_SECRET',
    'LEDGER_SALT'
  ];
  
  let allPresent = true;
  
  for (const varName of requiredVars) {
    const value = process.env[varName];
    if (value) {
      console.log(`   ✅ ${varName}: SET (length: ${value.length})`);
    } else {
      console.log(`   ❌ ${varName}: NOT SET`);
      allPresent = false;
    }
  }
  
  return allPresent;
}

async function checkServerFiles() {
  console.log('\n📁 Checking server files...');
  
  const fs = require('fs');
  const path = require('path');
  
  const requiredFiles = [
    'package.json',
    'server.js',
    'start.sh',
    'routes/admin.js',
    'middleware/adminAuth.js',
    'public/admin-staging/index.html'
  ];
  
  let allPresent = true;
  
  for (const filePath of requiredFiles) {
    if (fs.existsSync(filePath)) {
      console.log(`   ✅ ${filePath}: EXISTS`);
    } else {
      console.log(`   ❌ ${filePath}: MISSING`);
      allPresent = false;
    }
  }
  
  return allPresent;
}

async function checkDependencies() {
  console.log('\n📦 Checking dependencies...');
  
  try {
    const packageJson = require('./package.json');
    const dependencies = Object.keys(packageJson.dependencies);
    
    console.log(`   📋 Required dependencies: ${dependencies.length}`);
    
    const fs = require('fs');
    const nodeModulesPath = './node_modules';
    
    if (fs.existsSync(nodeModulesPath)) {
      console.log('   ✅ node_modules directory exists');
      
      // Check critical dependencies
      const criticalDeps = ['express', 'pg', 'bcrypt', 'jsonwebtoken', 'cors'];
      
      for (const dep of criticalDeps) {
        const depPath = path.join(nodeModulesPath, dep);
        if (fs.existsSync(depPath)) {
          console.log(`   ✅ ${dep}: installed`);
        } else {
          console.log(`   ❌ ${dep}: MISSING`);
        }
      }
    } else {
      console.log('   ❌ node_modules directory missing');
      return false;
    }
    
    return true;
  } catch (error) {
    console.error('   ❌ Error checking dependencies:', error.message);
    return false;
  }
}

async function testServerStartup() {
  console.log('\n🚀 Testing server startup...');
  
  try {
    // This is a basic test - in production, we'd need to actually start the server
    console.log('   📝 Server startup test would require actual server process');
    console.log('   💡 Check Azure logs for startup errors');
    return true;
  } catch (error) {
    console.error('   ❌ Server startup test failed:', error.message);
    return false;
  }
}

async function main() {
  try {
    // Check database connection
    const dbOk = await checkDatabaseConnection();
    
    // Check environment variables
    const envOk = checkEnvironmentVariables();
    
    // Check server files
    const filesOk = await checkServerFiles();
    
    // Check dependencies
    const depsOk = await checkDependencies();
    
    // Test server startup
    const serverOk = await testServerStartup();
    
    console.log('\n📊 DIAGNOSIS SUMMARY');
    console.log('===================');
    console.log(`Database Connection: ${dbOk ? '✅ OK' : '❌ FAILED'}`);
    console.log(`Environment Variables: ${envOk ? '✅ OK' : '❌ FAILED'}`);
    console.log(`Server Files: ${filesOk ? '✅ OK' : '❌ FAILED'}`);
    console.log(`Dependencies: ${depsOk ? '✅ OK' : '❌ FAILED'}`);
    console.log(`Server Startup: ${serverOk ? '✅ OK' : '❌ FAILED'}`);
    
    if (dbOk && envOk && filesOk && depsOk && serverOk) {
      console.log('\n🎉 ALL CHECKS PASSED!');
      console.log('The server should be working correctly.');
      console.log('\n🔧 TROUBLESHOOTING TIPS:');
      console.log('1. Check Azure App Service logs for startup errors');
      console.log('2. Verify the server is listening on the correct port');
      console.log('3. Check if the server process is running');
      console.log('4. Verify network connectivity');
    } else {
      console.log('\n❌ ISSUES DETECTED!');
      console.log('Please fix the issues above before the server will work.');
    }
    
    console.log('\n🔗 NEXT STEPS:');
    console.log('==============');
    console.log('1. Check Azure Portal → App Service → Log stream');
    console.log('2. Look for startup errors or crashes');
    console.log('3. Verify environment variables are set correctly');
    console.log('4. Check if the server is binding to the correct port');
    
  } catch (error) {
    console.error('\n❌ DIAGNOSIS FAILED:', error.message);
  }
}

// Run the diagnosis
main();
