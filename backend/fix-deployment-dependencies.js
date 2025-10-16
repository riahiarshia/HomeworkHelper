#!/usr/bin/env node

/**
 * Fix Deployment Dependencies Script
 * This script ensures all required dependencies are installed in Azure
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🔧 FIXING DEPLOYMENT DEPENDENCIES');
console.log('==================================\n');

try {
  // Check if we're in the right directory
  const packageJsonPath = path.join(__dirname, 'package.json');
  if (!fs.existsSync(packageJsonPath)) {
    console.error('❌ package.json not found in current directory');
    process.exit(1);
  }

  console.log('📦 Checking package.json...');
  const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
  console.log(`   ✅ Found package.json for: ${packageJson.name}`);
  console.log(`   📋 Dependencies: ${Object.keys(packageJson.dependencies).length} packages`);

  // Check if node_modules exists
  const nodeModulesPath = path.join(__dirname, 'node_modules');
  if (fs.existsSync(nodeModulesPath)) {
    console.log('   ✅ node_modules directory exists');
    
    // Check for express specifically
    const expressPath = path.join(nodeModulesPath, 'express');
    if (fs.existsSync(expressPath)) {
      console.log('   ✅ express module found');
    } else {
      console.log('   ❌ express module missing');
    }
  } else {
    console.log('   ❌ node_modules directory missing');
  }

  console.log('\n🚀 Installing dependencies...');
  
  // Install dependencies
  try {
    execSync('npm install', { 
      stdio: 'inherit',
      cwd: __dirname 
    });
    console.log('   ✅ npm install completed');
  } catch (error) {
    console.error('   ❌ npm install failed:', error.message);
    throw error;
  }

  // Verify express is installed
  const expressPath = path.join(__dirname, 'node_modules', 'express');
  if (fs.existsSync(expressPath)) {
    console.log('   ✅ express module verified');
  } else {
    console.error('   ❌ express module still missing after install');
    process.exit(1);
  }

  console.log('\n📋 CRITICAL DEPENDENCIES CHECK:');
  console.log('===============================');
  
  const criticalDeps = ['express', 'pg', 'bcrypt', 'jsonwebtoken', 'cors'];
  
  for (const dep of criticalDeps) {
    const depPath = path.join(__dirname, 'node_modules', dep);
    if (fs.existsSync(depPath)) {
      console.log(`   ✅ ${dep} - installed`);
    } else {
      console.log(`   ❌ ${dep} - MISSING`);
    }
  }

  console.log('\n🎉 DEPENDENCY FIX COMPLETE!');
  console.log('============================');
  console.log('✅ All dependencies should now be installed');
  console.log('✅ Express module is available');
  console.log('✅ Server should start successfully');
  
  console.log('\n🔄 NEXT STEPS:');
  console.log('===============');
  console.log('1. The server should restart automatically');
  console.log('2. Check the logs for successful startup');
  console.log('3. Test the admin portal: https://homework-helper-staging.azurewebsites.net/admin/');

} catch (error) {
  console.error('\n❌ DEPENDENCY FIX FAILED:', error.message);
  console.error('\n🔧 TROUBLESHOOTING:');
  console.error('1. Check if npm is available in the environment');
  console.error('2. Verify package.json is valid');
  console.error('3. Check Azure App Service configuration');
  console.error('4. Ensure sufficient disk space for node_modules');
}
