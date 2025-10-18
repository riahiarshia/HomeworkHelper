#!/bin/bash

# Complete Admin Fix - Handles all scenarios
# Run this in Azure App Service SSH bash console

echo "🔧 COMPLETE ADMIN FIX - ALL SCENARIOS"
echo "====================================="
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

# Create complete fix script
cat > fix-admin-complete.js << 'EOF'
const crypto = require('crypto');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

async function completeAdminFix() {
  try {
    console.log('🔧 COMPLETE ADMIN FIX - ALL SCENARIOS');
    console.log('=====================================');
    console.log('');
    
    const newEmail = 'support_homework@arshia.com';
    const newPassword = 'A@dMin%f$7';
    const username = 'admin';
    
    // Step 1: Check if admin_users table exists
    console.log('1️⃣ Checking if admin_users table exists...');
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'admin_users'
      );
    `);
    
    if (!tableCheck.rows[0].exists) {
      console.log('❌ admin_users table does not exist. Creating it...');
      
      // Create the admin_users table
      await pool.query(`
        CREATE TABLE admin_users (
          id SERIAL PRIMARY KEY,
          username VARCHAR(100) UNIQUE NOT NULL,
          email VARCHAR(255) UNIQUE NOT NULL,
          password_hash VARCHAR(255) NOT NULL,
          role VARCHAR(50) DEFAULT 'admin',
          is_active BOOLEAN DEFAULT true,
          created_at TIMESTAMP DEFAULT NOW(),
          updated_at TIMESTAMP DEFAULT NOW(),
          last_login TIMESTAMP
        );
      `);
      
      console.log('✅ admin_users table created');
    } else {
      console.log('✅ admin_users table exists');
    }
    
    // Step 2: Check table structure and fix if needed
    console.log('');
    console.log('2️⃣ Checking table structure...');
    const structure = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'admin_users'
      ORDER BY ordinal_position;
    `);
    
    const columns = structure.rows.map(row => row.column_name);
    console.log('📋 Current columns:', columns.join(', '));
    
    // Add missing columns if needed
    const requiredColumns = {
      'username': 'VARCHAR(100) UNIQUE NOT NULL',
      'email': 'VARCHAR(255) UNIQUE NOT NULL', 
      'password_hash': 'VARCHAR(255) NOT NULL',
      'role': 'VARCHAR(50) DEFAULT \'admin\'',
      'is_active': 'BOOLEAN DEFAULT true',
      'created_at': 'TIMESTAMP DEFAULT NOW()',
      'updated_at': 'TIMESTAMP DEFAULT NOW()',
      'last_login': 'TIMESTAMP'
    };
    
    for (const [colName, colDef] of Object.entries(requiredColumns)) {
      if (!columns.includes(colName)) {
        console.log(`   Adding missing column: ${colName}`);
        try {
          await pool.query(`ALTER TABLE admin_users ADD COLUMN ${colName} ${colDef};`);
        } catch (error) {
          console.log(`   Column ${colName} might already exist or error: ${error.message}`);
        }
      }
    }
    
    // Step 3: Delete any existing admin users to start fresh
    console.log('');
    console.log('3️⃣ Cleaning up existing admin users...');
    const deleteResult = await pool.query('DELETE FROM admin_users WHERE username = $1', [username]);
    console.log(`   Deleted ${deleteResult.rowCount} existing admin user(s)`);
    
    // Step 4: Create new admin user with correct hash
    console.log('');
    console.log('4️⃣ Creating new admin user...');
    const passwordHash = hashPassword(newPassword);
    
    const insertResult = await pool.query(`
      INSERT INTO admin_users (username, email, password_hash, role, is_active, created_at)
      VALUES ($1, $2, $3, 'super_admin', true, NOW())
      RETURNING id, username, email, role, is_active, created_at
    `, [username, newEmail, passwordHash]);
    
    if (insertResult.rows.length > 0) {
      const newAdmin = insertResult.rows[0];
      console.log('✅ New admin user created successfully!');
      console.log('');
      console.log('📋 Admin Details:');
      console.log(`   ID: ${newAdmin.id}`);
      console.log(`   Username: ${newAdmin.username}`);
      console.log(`   Email: ${newAdmin.email}`);
      console.log(`   Role: ${newAdmin.role}`);
      console.log(`   Active: ${newAdmin.is_active}`);
      console.log(`   Created: ${newAdmin.created_at}`);
    }
    
    // Step 5: Verify the admin user
    console.log('');
    console.log('5️⃣ Verifying admin user...');
    const verifyResult = await pool.query(
      'SELECT * FROM admin_users WHERE username = $1',
      [username]
    );
    
    if (verifyResult.rows.length > 0) {
      const admin = verifyResult.rows[0];
      console.log('✅ Admin user verified:');
      console.log(`   Username: ${admin.username}`);
      console.log(`   Email: ${admin.email}`);
      console.log(`   Role: ${admin.role}`);
      console.log(`   Active: ${admin.is_active}`);
      console.log(`   Password Hash Length: ${admin.password_hash.length}`);
      console.log(`   Hash starts with: ${admin.password_hash.substring(0, 20)}...`);
      
      // Test the hash
      const testHash = hashPassword(newPassword);
      if (admin.password_hash === testHash) {
        console.log('✅ Password hash verification successful!');
      } else {
        console.log('❌ Password hash verification failed!');
      }
    } else {
      console.log('❌ Admin user verification failed!');
    }
    
    // Step 6: Test login credentials
    console.log('');
    console.log('6️⃣ Testing login credentials...');
    
    const testResult = await pool.query(
      'SELECT * FROM admin_users WHERE username = $1 AND password_hash = $2',
      [username, passwordHash]
    );
    
    if (testResult.rows.length > 0) {
      console.log('✅ Login credentials test successful!');
      console.log('');
      console.log('🎉 COMPLETE ADMIN FIX SUCCESSFUL!');
      console.log('==================================');
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
      console.log('❌ Login credentials test failed!');
    }
    
  } catch (error) {
    console.error('❌ Error in complete admin fix:', error.message);
    console.error('Full error:', error);
  } finally {
    await pool.end();
  }
}

completeAdminFix();
EOF

echo "✅ Complete fix script created"
echo ""

# Run the complete fix
echo "🚀 Running complete admin fix..."
echo ""
node fix-admin-complete.js

# Clean up
echo ""
echo "🧹 Cleaning up..."
rm -f fix-admin-complete.js
echo "✅ Cleanup complete"
echo ""

echo "🎉 COMPLETE ADMIN FIX COMPLETED!"
echo "================================"
echo ""
echo "This script handles all possible scenarios:"
echo "✅ Creates admin_users table if missing"
echo "✅ Adds missing columns if needed"
echo "✅ Deletes old admin users"
echo "✅ Creates fresh admin user with correct SHA256 hash"
echo "✅ Verifies the fix worked"
echo "✅ Tests login credentials"
echo ""
echo "If you still get 'Invalid credentials', the issue might be:"
echo "1. Wrong admin portal URL"
echo "2. Cached login session - try incognito mode"
echo "3. Different authentication system"
echo "4. Network/firewall issues"
