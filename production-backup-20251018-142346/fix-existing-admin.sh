#!/bin/bash

# Fix Existing Admin User - Update Password Hash to SHA256
# Run this in Azure App Service SSH bash console

echo "🔧 FIXING EXISTING ADMIN USER - SHA256 HASH"
echo "============================================"
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
    exit 1
fi

echo "✅ DATABASE_URL is configured"
echo ""

# Create the fix script
cat > fix-existing-admin.js << 'EOF'
const crypto = require('crypto');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

async function fixExistingAdmin() {
  try {
    console.log('🔧 FIXING EXISTING ADMIN USER - SHA256 HASH');
    console.log('============================================');
    console.log('');
    
    const newEmail = 'support_homework@arshia.com';
    const newPassword = 'A@dMin%f$7';
    const username = 'admin';
    
    // Step 1: Check current admin user
    console.log('1️⃣ Checking current admin user...');
    const currentAdmin = await pool.query(
      'SELECT * FROM admin_users WHERE username = $1',
      [username]
    );
    
    if (currentAdmin.rows.length === 0) {
      console.log('❌ No admin user found!');
      return;
    }
    
    const admin = currentAdmin.rows[0];
    console.log('✅ Found existing admin user:');
    console.log(`   ID: ${admin.id}`);
    console.log(`   Username: ${admin.username}`);
    console.log(`   Current Email: ${admin.email}`);
    console.log(`   Role: ${admin.role}`);
    console.log(`   Active: ${admin.is_active}`);
    console.log(`   Current Hash: ${admin.password_hash}`);
    console.log(`   Hash Length: ${admin.password_hash.length}`);
    console.log(`   Hash Type: ${admin.password_hash.startsWith('$2') ? 'bcrypt (WRONG)' : 'SHA256 (CORRECT)'}`);
    console.log('');
    
    // Step 2: Create SHA256 hash
    console.log('2️⃣ Creating SHA256 hash...');
    const sha256Hash = hashPassword(newPassword);
    console.log(`   New SHA256 Hash: ${sha256Hash}`);
    console.log(`   Hash Length: ${sha256Hash.length}`);
    console.log('');
    
    // Step 3: Update the admin user
    console.log('3️⃣ Updating admin user with SHA256 hash...');
    const updateResult = await pool.query(
      `UPDATE admin_users 
       SET email = $1, password_hash = $2, updated_at = NOW()
       WHERE username = $3 
       RETURNING id, username, email, role, password_hash`,
      [newEmail, sha256Hash, username]
    );
    
    if (updateResult.rows.length > 0) {
      const updatedAdmin = updateResult.rows[0];
      console.log('✅ Admin user updated successfully!');
      console.log('');
      console.log('📋 Updated Admin Details:');
      console.log(`   ID: ${updatedAdmin.id}`);
      console.log(`   Username: ${updatedAdmin.username}`);
      console.log(`   Email: ${updatedAdmin.email}`);
      console.log(`   Role: ${updatedAdmin.role}`);
      console.log(`   New Hash: ${updatedAdmin.password_hash}`);
      console.log(`   Hash Length: ${updatedAdmin.password_hash.length}`);
      console.log('');
    }
    
    // Step 4: Verify the update
    console.log('4️⃣ Verifying the update...');
    const verifyResult = await pool.query(
      'SELECT * FROM admin_users WHERE username = $1',
      [username]
    );
    
    if (verifyResult.rows.length > 0) {
      const verified = verifyResult.rows[0];
      console.log('✅ Verification successful:');
      console.log(`   Username: ${verified.username}`);
      console.log(`   Email: ${verified.email}`);
      console.log(`   Role: ${verified.role}`);
      console.log(`   Password Hash: ${verified.password_hash}`);
      console.log(`   Hash Type: ${verified.password_hash.startsWith('$2') ? 'bcrypt (STILL WRONG)' : 'SHA256 (CORRECT)'}`);
      console.log('');
      
      // Test the hash
      const testHash = hashPassword(newPassword);
      if (verified.password_hash === testHash) {
        console.log('✅ Password hash verification successful!');
        console.log('');
        console.log('🎉 ADMIN PASSWORD FIX COMPLETE!');
        console.log('===============================');
        console.log('');
        console.log('🔑 Your new admin credentials:');
        console.log('   Username: admin');
        console.log('   Password: A@dMin%f$7');
        console.log('   Email: support_homework@arshia.com');
        console.log('');
        console.log('🌐 Admin Portal URL:');
        console.log('   https://homework-helper-api.azurewebsites.net/admin/');
        console.log('');
        console.log('⚠️  IMPORTANT: Change the password immediately after logging in!');
      } else {
        console.log('❌ Password hash verification failed!');
        console.log(`   Expected: ${testHash}`);
        console.log(`   Actual: ${verified.password_hash}`);
      }
    } else {
      console.log('❌ Verification failed - admin user not found!');
    }
    
  } catch (error) {
    console.error('❌ Error fixing existing admin:', error.message);
    console.error('Full error:', error);
  } finally {
    await pool.end();
  }
}

fixExistingAdmin();
EOF

echo "✅ Fix script created"
echo ""

# Run the fix
echo "🚀 Running existing admin fix..."
echo ""
node fix-existing-admin.js

# Clean up
echo ""
echo "🧹 Cleaning up..."
rm -f fix-existing-admin.js
echo "✅ Cleanup complete"
echo ""

echo "🎉 EXISTING ADMIN FIX COMPLETED!"
echo "================================"
echo ""
echo "This script specifically:"
echo "✅ Updates the existing admin user (ID: 9)"
echo "✅ Changes password hash from bcrypt to SHA256"
echo "✅ Updates email to support_homework@arshia.com"
echo "✅ Verifies the fix worked"
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
