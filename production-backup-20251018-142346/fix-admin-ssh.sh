#!/bin/bash

# Fix Admin Password - Azure App Service SSH Script
# Run this directly in Azure App Service SSH bash console

echo "🔐 FIXING ADMIN PASSWORD - AZURE APP SERVICE"
echo "============================================="
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Not in the correct directory. Please navigate to /home/site/wwwroot"
    echo "   Run: cd /home/site/wwwroot"
    exit 1
fi

echo "✅ In correct directory: $(pwd)"
echo ""

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    echo "❌ DATABASE_URL environment variable is not set!"
    echo "   This script must be run on the Azure App Service where DATABASE_URL is configured."
    exit 1
fi

echo "✅ DATABASE_URL is configured"
echo "   Database: $(echo $DATABASE_URL | cut -d'@' -f2 | cut -d'/' -f1)"
echo ""

# Create the fix script
echo "📝 Creating admin password fix script..."
cat > fix-admin-password.js << 'EOF'
// Fix Admin Password - SSH Version
const crypto = require('crypto');
const { Pool } = require('pg');

console.log('🔐 FIXING ADMIN PASSWORD - PRODUCTION DATABASE');
console.log('===============================================');
console.log('Environment:', process.env.NODE_ENV);
console.log('');

// Production database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

// Use SHA256 to match the current system (same as auth.js)
function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

async function fixAdminPassword() {
  try {
    const newEmail = 'support_homework@arshia.com';
    const newPassword = 'A@dMin%f$7';
    const username = 'admin';
    
    console.log('🔍 Connecting to database...');
    console.log('   Database URL:', process.env.DATABASE_URL.substring(0, 30) + '...');
    console.log('');
    
    // Hash the password using SHA256 (matches auth.js)
    console.log('⏳ Hashing password with SHA256...');
    const passwordHash = hashPassword(newPassword);
    
    console.log('📋 Password hash (SHA256):', passwordHash.substring(0, 20) + '...');
    console.log('');
    
    // First, check if admin user exists
    console.log('🔍 Checking if admin user exists...');
    const checkResult = await pool.query(
      'SELECT id, username, email, role FROM admin_users WHERE username = $1',
      [username]
    );
    
    if (checkResult.rows.length > 0) {
      const existingAdmin = checkResult.rows[0];
      console.log('✅ Found existing admin user:');
      console.log('   ID:', existingAdmin.id);
      console.log('   Username:', existingAdmin.username);
      console.log('   Current Email:', existingAdmin.email);
      console.log('   Role:', existingAdmin.role);
      console.log('');
      
      // Update the admin user
      console.log('⏳ Updating admin credentials...');
      const updateResult = await pool.query(
        `UPDATE admin_users 
         SET email = $1, password_hash = $2, updated_at = NOW()
         WHERE username = $3 
         RETURNING id, username, email, role`,
        [newEmail, passwordHash, username]
      );
      
      if (updateResult.rows.length > 0) {
        const admin = updateResult.rows[0];
        console.log('✅ Admin credentials updated successfully!');
        console.log('');
        console.log('📋 Updated Admin Details:');
        console.log('   Username:', admin.username);
        console.log('   Email:', admin.email);
        console.log('   Role:', admin.role);
        console.log('');
        console.log('🔑 Login Credentials:');
        console.log('   Username: admin');
        console.log('   Password: A@dMin%f$7');
        console.log('');
        console.log('🌐 Admin Portal URL:');
        if (process.env.NODE_ENV === 'production') {
          console.log('   https://homework-helper-api.azurewebsites.net/admin/');
        } else {
          console.log('   https://homework-helper-staging.azurewebsites.net/admin/');
        }
        console.log('');
        console.log('⚠️  Make sure to save these credentials securely!');
      }
    } else {
      console.log('❌ Admin user not found. Creating new admin user...');
      
      // Create new admin if not exists
      const createResult = await pool.query(
        `INSERT INTO admin_users (username, email, password_hash, role, is_active, created_at)
         VALUES ($1, $2, $3, 'super_admin', true, NOW())
         RETURNING id, username, email, role`,
        [username, newEmail, passwordHash]
      );
      
      if (createResult.rows.length > 0) {
        const newAdmin = createResult.rows[0];
        console.log('✅ New admin user created successfully!');
        console.log('');
        console.log('📋 Admin Details:');
        console.log('   Username:', newAdmin.username);
        console.log('   Email:', newAdmin.email);
        console.log('   Role:', newAdmin.role);
        console.log('');
        console.log('🔑 Login Credentials:');
        console.log('   Username: admin');
        console.log('   Password: A@dMin%f$7');
        console.log('');
        console.log('🌐 Admin Portal URL:');
        if (process.env.NODE_ENV === 'production') {
          console.log('   https://homework-helper-api.azurewebsites.net/admin/');
        } else {
          console.log('   https://homework-helper-staging.azurewebsites.net/admin/');
        }
      }
    }
    
    // Verify the fix
    console.log('🔍 Verifying the fix...');
    const verifyResult = await pool.query(
      'SELECT username, email, role, password_hash FROM admin_users WHERE username = $1',
      [username]
    );
    
    if (verifyResult.rows.length > 0) {
      const verified = verifyResult.rows[0];
      console.log('✅ Verification successful:');
      console.log('   Username:', verified.username);
      console.log('   Email:', verified.email);
      console.log('   Role:', verified.role);
      console.log('   Password Hash Length:', verified.password_hash.length);
      console.log('   Hash starts with:', verified.password_hash.substring(0, 10) + '...');
      console.log('');
      console.log('🎉 ADMIN PASSWORD FIX COMPLETE!');
      console.log('   You can now log into the admin portal.');
      console.log('');
      console.log('🔗 Next Steps:');
      console.log('   1. Go to the admin portal URL above');
      console.log('   2. Login with: admin / A@dMin%f$7');
      console.log('   3. Change the password to something more secure');
      console.log('   4. Delete this script file for security');
    }
    
  } catch (error) {
    console.error('❌ Error fixing admin password:', error.message);
    console.error('Full error:', error);
    
    if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
      console.error('');
      console.error('🔧 Database Connection Issue:');
      console.error('   - Check if the database server is running');
      console.error('   - Verify the DATABASE_URL is correct');
      console.error('   - Check network connectivity');
    }
    
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run the fix
fixAdminPassword();
EOF

echo "✅ Fix script created"
echo ""

# Run the fix
echo "🚀 Running admin password fix..."
echo ""
node fix-admin-password.js

# Clean up
echo ""
echo "🧹 Cleaning up..."
rm -f fix-admin-password.js
echo "✅ Cleanup complete"
echo ""

echo "🎉 ADMIN PASSWORD FIX COMPLETED!"
echo "================================"
echo ""
echo "🔑 Your new admin credentials:"
echo "   Username: admin"
echo "   Password: A@dMin%f$7"
echo "   Email: support_homework@arshia.com"
echo ""
echo "🌐 Admin Portal URL:"
echo "   https://homework-helper-api.azurewebsites.net/admin/"
echo ""
echo "⚠️  IMPORTANT: Change the password immediately after logging in!"
echo ""
echo "🔒 Security Recommendations:"
echo "   1. Login with the credentials above"
echo "   2. Change to a strong, unique password"
echo "   3. Enable 2FA if available"
echo "   4. Update the password in your password manager"
