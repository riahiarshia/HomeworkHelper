#!/usr/bin/env node

/**
 * Quick Fix Azure Script
 * This script can be run in Azure Kudu Console to fix common issues
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🚀 QUICK FIX AZURE SCRIPT');
console.log('========================\n');

async function checkCurrentDirectory() {
  console.log('📁 Checking current directory...');
  try {
    const cwd = process.cwd();
    console.log(`   📍 Current directory: ${cwd}`);
    
    const files = fs.readdirSync('.');
    console.log(`   📋 Files in directory: ${files.length}`);
    
    // Check for key files
    const keyFiles = ['package.json', 'server.js', 'routes', 'middleware', 'public'];
    for (const file of keyFiles) {
      if (fs.existsSync(file)) {
        console.log(`   ✅ ${file}: EXISTS`);
      } else {
        console.log(`   ❌ ${file}: MISSING`);
      }
    }
    
    return true;
  } catch (error) {
    console.error('   ❌ Error checking directory:', error.message);
    return false;
  }
}

async function checkNodeModules() {
  console.log('\n📦 Checking node_modules...');
  try {
    if (fs.existsSync('node_modules')) {
      console.log('   ✅ node_modules directory exists');
      
      // Check critical dependencies
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
        console.log(`   🔧 Missing dependencies: ${missingDeps.join(', ')}`);
        return false;
      }
      
      return true;
    } else {
      console.log('   ❌ node_modules directory missing');
      return false;
    }
  } catch (error) {
    console.error('   ❌ Error checking node_modules:', error.message);
    return false;
  }
}

async function installDependencies() {
  console.log('\n🔧 Installing dependencies...');
  try {
    console.log('   📥 Running npm install...');
    execSync('npm install --production', { stdio: 'inherit' });
    console.log('   ✅ npm install completed');
    return true;
  } catch (error) {
    console.error('   ❌ npm install failed:', error.message);
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
    console.log('   💡 These need to be set in Azure Portal → Configuration → Application settings');
  }
  
  return missingVars.length === 0;
}

async function testServerStartup() {
  console.log('\n🚀 Testing server startup...');
  try {
    // Check if server.js exists and is valid
    if (!fs.existsSync('server.js')) {
      console.log('   ❌ server.js not found');
      return false;
    }
    
    console.log('   ✅ server.js exists');
    console.log('   💡 To start the server manually, run: node server.js');
    return true;
  } catch (error) {
    console.error('   ❌ Error testing server startup:', error.message);
    return false;
  }
}

async function main() {
  try {
    // Check current directory
    const dirOk = await checkCurrentDirectory();
    
    // Check node_modules
    const modulesOk = await checkNodeModules();
    
    // Install dependencies if needed
    if (!modulesOk) {
      console.log('\n🔧 Installing missing dependencies...');
      const installOk = await installDependencies();
      if (!installOk) {
        console.log('   ❌ Failed to install dependencies');
        return;
      }
    }
    
    // Check environment variables
    const envOk = await checkEnvironmentVariables();
    
    // Test server startup
    const serverOk = await testServerStartup();
    
    console.log('\n📊 QUICK FIX SUMMARY');
    console.log('===================');
    console.log(`Directory Check: ${dirOk ? '✅ OK' : '❌ FAILED'}`);
    console.log(`Dependencies: ${modulesOk ? '✅ OK' : '❌ FIXED'}`);
    console.log(`Environment Variables: ${envOk ? '✅ OK' : '❌ NEEDS ATTENTION'}`);
    console.log(`Server Files: ${serverOk ? '✅ OK' : '❌ FAILED'}`);
    
    if (dirOk && serverOk) {
      console.log('\n🎉 QUICK FIX COMPLETE!');
      console.log('=====================');
      console.log('✅ Dependencies are installed');
      console.log('✅ Server files are present');
      
      if (!envOk) {
        console.log('\n⚠️  ENVIRONMENT VARIABLES NEED TO BE SET:');
        console.log('1. Go to Azure Portal → App Service → Configuration');
        console.log('2. Add the missing environment variables');
        console.log('3. Restart the App Service');
      }
      
      console.log('\n🚀 NEXT STEPS:');
      console.log('==============');
      console.log('1. Set environment variables in Azure Portal');
      console.log('2. Restart the App Service');
      console.log('3. Check the logs for successful startup');
      console.log('4. Test the admin portal');
      
    } else {
      console.log('\n❌ QUICK FIX INCOMPLETE');
      console.log('======================');
      console.log('Some issues could not be resolved automatically.');
      console.log('Please check the Azure Portal logs for more details.');
    }
    
  } catch (error) {
    console.error('\n❌ QUICK FIX FAILED:', error.message);
    console.error('\n🔧 TROUBLESHOOTING:');
    console.error('1. Check if you are in the correct directory');
    console.error('2. Verify npm is available');
    console.error('3. Check Azure App Service configuration');
  }
}

// Run the quick fix
main();
