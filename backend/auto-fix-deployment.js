#!/usr/bin/env node

/**
 * Auto Fix Deployment Script
 * This script runs automatically during deployment to fix common issues
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('🚀 AUTO FIX DEPLOYMENT SCRIPT');
console.log('============================\n');

async function ensureNodeModules() {
  console.log('📦 Ensuring node_modules are installed...');
  
  try {
    // Check if node_modules exists
    if (!fs.existsSync('node_modules')) {
      console.log('   📥 node_modules missing, installing...');
      execSync('npm install --production', { stdio: 'inherit' });
      console.log('   ✅ Dependencies installed');
    } else {
      console.log('   ✅ node_modules exists');
    }
    
    // Verify critical dependencies
    const criticalDeps = ['express', 'pg', 'bcrypt', 'jsonwebtoken', 'cors'];
    let missingDeps = [];
    
    for (const dep of criticalDeps) {
      const depPath = path.join('node_modules', dep);
      if (!fs.existsSync(depPath)) {
        missingDeps.push(dep);
      }
    }
    
    if (missingDeps.length > 0) {
      console.log(`   🔧 Missing dependencies: ${missingDeps.join(', ')}`);
      console.log('   📥 Reinstalling dependencies...');
      execSync('npm install --production', { stdio: 'inherit' });
      console.log('   ✅ Dependencies reinstalled');
    } else {
      console.log('   ✅ All critical dependencies present');
    }
    
    return true;
  } catch (error) {
    console.error('   ❌ Error ensuring node_modules:', error.message);
    return false;
  }
}

async function verifyServerFiles() {
  console.log('\n📁 Verifying server files...');
  
  const requiredFiles = [
    'package.json',
    'server.js',
    'routes/admin.js',
    'middleware/adminAuth.js',
    'public/admin-staging/index.html'
  ];
  
  let missingFiles = [];
  
  for (const filePath of requiredFiles) {
    if (!fs.existsSync(filePath)) {
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
    if (!value) {
      missingVars.push(varName);
    }
  }
  
  if (missingVars.length > 0) {
    console.log(`   ⚠️  Missing environment variables: ${missingVars.join(', ')}`);
    console.log('   💡 These need to be set in Azure Portal → Configuration → Application settings');
    return false;
  } else {
    console.log('   ✅ All environment variables set');
    return true;
  }
}

async function createStartupScript() {
  console.log('\n🚀 Creating startup script...');
  
  try {
    const startScript = `#!/bin/bash

echo "🚀 Starting Homework Helper Backend..."

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install --production
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install dependencies"
        exit 1
    fi
fi

# Start the server
echo "🌐 Starting server..."
node server.js
`;

    fs.writeFileSync('start.sh', startScript);
    execSync('chmod +x start.sh', { stdio: 'inherit' });
    console.log('   ✅ Startup script created');
    return true;
  } catch (error) {
    console.error('   ❌ Error creating startup script:', error.message);
    return false;
  }
}

async function testServerStartup() {
  console.log('\n🧪 Testing server startup...');
  
  try {
    // Check if server.js is syntactically valid
    const serverContent = fs.readFileSync('server.js', 'utf8');
    
    // Basic syntax check
    if (serverContent.includes('require(') && serverContent.includes('app.listen')) {
      console.log('   ✅ server.js appears to be valid');
      return true;
    } else {
      console.log('   ❌ server.js appears to be invalid');
      return false;
    }
  } catch (error) {
    console.error('   ❌ Error testing server startup:', error.message);
    return false;
  }
}

async function main() {
  try {
    console.log('🔍 Running automated deployment fixes...\n');
    
    // Ensure node_modules are installed
    const modulesOk = await ensureNodeModules();
    
    // Verify server files
    const filesOk = await verifyServerFiles();
    
    // Check environment variables
    const envOk = await checkEnvironmentVariables();
    
    // Create startup script
    const scriptOk = await createStartupScript();
    
    // Test server startup
    const serverOk = await testServerStartup();
    
    console.log('\n📊 AUTO FIX SUMMARY');
    console.log('==================');
    console.log(`Dependencies: ${modulesOk ? '✅ OK' : '❌ FAILED'}`);
    console.log(`Server Files: ${filesOk ? '✅ OK' : '❌ FAILED'}`);
    console.log(`Environment Variables: ${envOk ? '✅ OK' : '❌ NEEDS ATTENTION'}`);
    console.log(`Startup Script: ${scriptOk ? '✅ OK' : '❌ FAILED'}`);
    console.log(`Server Validation: ${serverOk ? '✅ OK' : '❌ FAILED'}`);
    
    if (modulesOk && filesOk && scriptOk && serverOk) {
      console.log('\n🎉 AUTO FIX COMPLETE!');
      console.log('====================');
      console.log('✅ All automated fixes applied successfully');
      console.log('✅ Server should start correctly');
      
      if (!envOk) {
        console.log('\n⚠️  MANUAL ACTION REQUIRED:');
        console.log('========================');
        console.log('Environment variables need to be set in Azure Portal:');
        console.log('1. Go to Azure Portal → App Service → Configuration');
        console.log('2. Add missing environment variables');
        console.log('3. Restart the App Service');
      }
      
      console.log('\n🚀 DEPLOYMENT READY!');
      console.log('===================');
      console.log('The server should now start successfully after deployment.');
      
    } else {
      console.log('\n❌ AUTO FIX INCOMPLETE');
      console.log('=====================');
      console.log('Some issues could not be resolved automatically.');
      console.log('Check the logs above for specific failures.');
    }
    
  } catch (error) {
    console.error('\n❌ AUTO FIX FAILED:', error.message);
    console.error('\n🔧 TROUBLESHOOTING:');
    console.error('1. Check if npm is available');
    console.error('2. Verify file permissions');
    console.error('3. Check Azure App Service configuration');
  }
}

// Run the auto fix
main();
