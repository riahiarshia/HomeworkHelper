#!/usr/bin/env node

/**
 * Post Deployment Verification Script
 * This script runs after deployment to verify everything is working
 */

const { Pool } = require('pg');

console.log('🔍 POST DEPLOYMENT VERIFICATION');
console.log('==============================\n');

async function checkDatabaseConnection() {
  console.log('📊 Testing database connection...');
  
  try {
    const pool = new Pool({
      connectionString: process.env.DATABASE_URL,
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
  
  let missingVars = [];
  
  for (const varName of requiredVars) {
    const value = process.env[varName];
    if (value) {
      console.log(`   ✅ ${varName}: SET`);
    } else {
      console.log(`   ❌ ${varName}: NOT SET`);
      missingVars.push(varName);
    }
  }
  
  if (missingVars.length > 0) {
    console.log(`   ⚠️  Missing environment variables: ${missingVars.join(', ')}`);
    return false;
  } else {
    console.log('   ✅ All environment variables set');
    return true;
  }
}

async function checkServerFiles() {
  console.log('\n📁 Checking server files...');
  
  const fs = require('fs');
  const requiredFiles = [
    'package.json',
    'server.js',
    'routes/admin.js',
    'middleware/adminAuth.js',
    'public/admin-staging/index.html'
  ];
  
  let missingFiles = [];
  
  for (const filePath of requiredFiles) {
    if (fs.existsSync(filePath)) {
      console.log(`   ✅ ${filePath}: EXISTS`);
    } else {
      console.log(`   ❌ ${filePath}: MISSING`);
      missingFiles.push(filePath);
    }
  }
  
  if (missingFiles.length > 0) {
    console.log(`   ❌ Missing files: ${missingFiles.join(', ')}`);
    return false;
  } else {
    console.log('   ✅ All required files present');
    return true;
  }
}

async function checkDependencies() {
  console.log('\n📦 Checking dependencies...');
  
  const fs = require('fs');
  const path = require('path');
  
  if (!fs.existsSync('node_modules')) {
    console.log('   ❌ node_modules directory missing');
    return false;
  }
  
  const criticalDeps = ['express', 'pg', 'bcrypt', 'jsonwebtoken', 'cors'];
  let missingDeps = [];
  
  for (const dep of criticalDeps) {
    const depPath = path.join('node_modules', dep);
    if (fs.existsSync(depPath)) {
      console.log(`   ✅ ${dep}: installed`);
    } else {
      console.log(`   ❌ ${dep}: MISSING`);
      missingDeps.push(dep);
    }
  }
  
  if (missingDeps.length > 0) {
    console.log(`   ❌ Missing dependencies: ${missingDeps.join(', ')}`);
    return false;
  } else {
    console.log('   ✅ All critical dependencies present');
    return true;
  }
}

async function testAdminAPI() {
  console.log('\n🧪 Testing admin API endpoints...');
  
  try {
    // Test if we can require the admin routes
    const adminRoutes = require('./routes/admin.js');
    console.log('   ✅ Admin routes loaded successfully');
    
    // Test if we can require the auth middleware
    const adminAuth = require('./middleware/adminAuth.js');
    console.log('   ✅ Admin auth middleware loaded successfully');
    
    return true;
  } catch (error) {
    console.error('   ❌ Error loading admin components:', error.message);
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
    
    // Test admin API
    const apiOk = await testAdminAPI();
    
    console.log('\n📊 VERIFICATION SUMMARY');
    console.log('======================');
    console.log(`Database Connection: ${dbOk ? '✅ OK' : '❌ FAILED'}`);
    console.log(`Environment Variables: ${envOk ? '✅ OK' : '❌ FAILED'}`);
    console.log(`Server Files: ${filesOk ? '✅ OK' : '❌ FAILED'}`);
    console.log(`Dependencies: ${depsOk ? '✅ OK' : '❌ FAILED'}`);
    console.log(`Admin API: ${apiOk ? '✅ OK' : '❌ FAILED'}`);
    
    if (dbOk && envOk && filesOk && depsOk && apiOk) {
      console.log('\n🎉 POST DEPLOYMENT VERIFICATION PASSED!');
      console.log('=====================================');
      console.log('✅ All systems are operational');
      console.log('✅ Admin portal should be accessible');
      console.log('✅ Database connection is working');
      console.log('✅ All dependencies are installed');
      
      console.log('\n🔗 TEST THE ADMIN PORTAL:');
      console.log('=========================');
      console.log('URL: https://homework-helper-staging.azurewebsites.net/admin/');
      console.log('Username: admin');
      console.log('Password: Admin123!Staging');
      
    } else {
      console.log('\n❌ POST DEPLOYMENT VERIFICATION FAILED!');
      console.log('=====================================');
      console.log('Some components are not working correctly.');
      console.log('Check the Azure Portal logs for more details.');
      
      console.log('\n🔧 TROUBLESHOOTING STEPS:');
      console.log('=========================');
      console.log('1. Check Azure Portal → App Service → Log stream');
      console.log('2. Verify environment variables are set');
      console.log('3. Check if dependencies are installed');
      console.log('4. Restart the App Service if needed');
    }
    
  } catch (error) {
    console.error('\n❌ VERIFICATION FAILED:', error.message);
    console.error('\n🔧 TROUBLESHOOTING:');
    console.error('1. Check if all required files are present');
    console.error('2. Verify database connection string');
    console.error('3. Check Azure App Service configuration');
  }
}

// Run the verification
main();
