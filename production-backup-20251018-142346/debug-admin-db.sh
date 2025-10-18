#!/bin/bash

# Debug Admin Database - Check what's actually in the database
# Run this in Azure App Service SSH bash console

echo "🔍 DEBUGGING ADMIN DATABASE"
echo "============================"
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

# Create debug script
cat > debug-admin.js << 'EOF'
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function debugAdmin() {
  try {
    console.log('🔍 DEBUGGING ADMIN DATABASE');
    console.log('============================');
    console.log('');
    
    // Check if admin_users table exists
    console.log('1️⃣ Checking if admin_users table exists...');
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'admin_users'
      );
    `);
    
    if (tableCheck.rows[0].exists) {
      console.log('✅ admin_users table exists');
    } else {
      console.log('❌ admin_users table does NOT exist!');
      console.log('   This is the problem - the table is missing.');
      return;
    }
    
    // Check table structure
    console.log('');
    console.log('2️⃣ Checking table structure...');
    const structure = await pool.query(`
      SELECT column_name, data_type, is_nullable 
      FROM information_schema.columns 
      WHERE table_name = 'admin_users'
      ORDER BY ordinal_position;
    `);
    
    console.log('📋 Table structure:');
    structure.rows.forEach(col => {
      console.log(`   ${col.column_name}: ${col.data_type} (${col.is_nullable === 'YES' ? 'nullable' : 'not null'})`);
    });
    
    // Check all admin users
    console.log('');
    console.log('3️⃣ Checking all admin users...');
    const allUsers = await pool.query('SELECT * FROM admin_users');
    
    if (allUsers.rows.length === 0) {
      console.log('❌ No admin users found in the database!');
      console.log('   This is why login fails - there are no admin users.');
    } else {
      console.log(`✅ Found ${allUsers.rows.length} admin user(s):`);
      allUsers.rows.forEach((user, index) => {
        console.log(`   User ${index + 1}:`);
        console.log(`     ID: ${user.id}`);
        console.log(`     Username: ${user.username}`);
        console.log(`     Email: ${user.email}`);
        console.log(`     Role: ${user.role}`);
        console.log(`     Active: ${user.is_active}`);
        console.log(`     Created: ${user.created_at}`);
        console.log(`     Password Hash Length: ${user.password_hash ? user.password_hash.length : 'NULL'}`);
        if (user.password_hash) {
          console.log(`     Hash starts with: ${user.password_hash.substring(0, 20)}...`);
        }
        console.log('');
      });
    }
    
    // Check specifically for 'admin' user
    console.log('4️⃣ Checking specifically for "admin" user...');
    const adminUser = await pool.query('SELECT * FROM admin_users WHERE username = $1', ['admin']);
    
    if (adminUser.rows.length === 0) {
      console.log('❌ No user with username "admin" found!');
    } else {
      const admin = adminUser.rows[0];
      console.log('✅ Found "admin" user:');
      console.log(`   ID: ${admin.id}`);
      console.log(`   Username: ${admin.username}`);
      console.log(`   Email: ${admin.email}`);
      console.log(`   Role: ${admin.role}`);
      console.log(`   Active: ${admin.is_active}`);
      console.log(`   Password Hash: ${admin.password_hash}`);
      console.log(`   Hash Length: ${admin.password_hash ? admin.password_hash.length : 'NULL'}`);
    }
    
    // Check other tables that might have admin data
    console.log('');
    console.log('5️⃣ Checking for other admin-related tables...');
    const otherTables = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_name LIKE '%admin%' OR table_name LIKE '%user%'
      AND table_schema = 'public'
      ORDER BY table_name;
    `);
    
    if (otherTables.rows.length > 0) {
      console.log('📋 Found other related tables:');
      otherTables.rows.forEach(table => {
        console.log(`   - ${table.table_name}`);
      });
    } else {
      console.log('❌ No other admin/user tables found');
    }
    
  } catch (error) {
    console.error('❌ Error debugging admin database:', error.message);
    console.error('Full error:', error);
  } finally {
    await pool.end();
  }
}

debugAdmin();
EOF

echo "✅ Debug script created"
echo ""

# Run the debug script
echo "🚀 Running database debug..."
echo ""
node debug-admin.js

# Clean up
echo ""
echo "🧹 Cleaning up..."
rm -f debug-admin.js
echo "✅ Cleanup complete"
echo ""

echo "🔍 DEBUG COMPLETE!"
echo "=================="
echo ""
echo "Based on the output above, we can see what's wrong and fix it."
echo "Common issues:"
echo "1. admin_users table doesn't exist"
echo "2. No admin users in the database"
echo "3. Wrong table structure"
echo "4. User exists but password hash is wrong format"
