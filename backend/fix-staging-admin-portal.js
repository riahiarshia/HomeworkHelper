#!/usr/bin/env node

/**
 * Comprehensive Staging Admin Portal Fix
 * This script will:
 * 1. Check database connectivity
 * 2. Create/update admin user
 * 3. Verify admin portal functionality
 * 4. Provide login credentials
 */

const crypto = require('crypto');
const { Pool } = require('pg');

// Database connection with proper SSL configuration for Azure
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'staging' 
    ? { rejectUnauthorized: false } 
    : false
});

// Use SHA256 to match the current system (same as auth.js)
function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

async function checkDatabaseConnection() {
  try {
    console.log('🔍 Checking database connection...');
    const client = await pool.connect();
    const result = await client.query('SELECT NOW() as current_time, current_database() as db_name');
    console.log('✅ Database connection successful!');
    console.log(`   Current time: ${result.rows[0].current_time}`);
    console.log(`   Database: ${result.rows[0].db_name}`);
    client.release();
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    return false;
  }
}

async function checkAdminTable() {
  try {
    console.log('🔍 Checking admin_users table...');
    const result = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'admin_users'
      );
    `);
    
    if (result.rows[0].exists) {
      console.log('✅ admin_users table exists');
      return true;
    } else {
      console.log('⚠️  admin_users table does not exist, creating it...');
      await createAdminTable();
      return true;
    }
  } catch (error) {
    console.error('❌ Error checking admin table:', error.message);
    return false;
  }
}

async function createAdminTable() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS admin_users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        role VARCHAR(50) DEFAULT 'admin',
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT NOW(),
        last_login TIMESTAMP,
        updated_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log('✅ admin_users table created successfully');
  } catch (error) {
    console.error('❌ Error creating admin table:', error.message);
    throw error;
  }
}

async function fixStagingAdmin() {
  try {
    console.log('🔐 Setting up staging admin credentials...');
    
    const username = 'admin';
    const email = 'admin@homeworkhelper-staging.com';
    const password = 'Admin123!Staging';
    const passwordHash = hashPassword(password);
    
    console.log('📋 Admin credentials:');
    console.log(`   Username: ${username}`);
    console.log(`   Email: ${email}`);
    console.log(`   Password: ${password}`);
    
    // First, try to update existing admin
    console.log('⏳ Checking for existing admin user...');
    const updateResult = await pool.query(
      `UPDATE admin_users 
       SET email = $1, password_hash = $2, is_active = true, updated_at = NOW()
       WHERE username = $3 
       RETURNING id, username, email, role`,
      [email, passwordHash, username]
    );
    
    if (updateResult.rows.length > 0) {
      console.log('✅ Updated existing admin user');
      console.log(`   Admin ID: ${updateResult.rows[0].id}`);
      console.log(`   Role: ${updateResult.rows[0].role}`);
    } else {
      console.log('⏳ No existing admin found, creating new one...');
      
      // Create new admin if not exists
      const createResult = await pool.query(
        `INSERT INTO admin_users (username, email, password_hash, role, is_active)
         VALUES ($1, $2, $3, 'super_admin', true)
         RETURNING id, username, email, role`,
        [username, email, passwordHash]
      );
      
      if (createResult.rows.length > 0) {
        console.log('✅ Created new admin user');
        console.log(`   Admin ID: ${createResult.rows[0].id}`);
        console.log(`   Role: ${createResult.rows[0].role}`);
      } else {
        throw new Error('Failed to create admin user');
      }
    }
    
    return true;
  } catch (error) {
    console.error('❌ Error setting up admin credentials:', error.message);
    throw error;
  }
}

async function verifyAdminSetup() {
  try {
    console.log('🔍 Verifying admin setup...');
    const result = await pool.query(
      'SELECT id, username, email, role, is_active, created_at FROM admin_users WHERE username = $1',
      ['admin']
    );
    
    if (result.rows.length > 0) {
      const admin = result.rows[0];
      console.log('✅ Admin user verified:');
      console.log(`   ID: ${admin.id}`);
      console.log(`   Username: ${admin.username}`);
      console.log(`   Email: ${admin.email}`);
      console.log(`   Role: ${admin.role}`);
      console.log(`   Active: ${admin.is_active}`);
      console.log(`   Created: ${admin.created_at}`);
      return true;
    } else {
      console.log('❌ Admin user not found');
      return false;
    }
  } catch (error) {
    console.error('❌ Error verifying admin setup:', error.message);
    return false;
  }
}

async function main() {
  console.log('🚀 Starting Staging Admin Portal Fix');
  console.log('=====================================\n');
  
  // Check environment variables
  console.log('📋 Environment Check:');
  console.log(`   NODE_ENV: ${process.env.NODE_ENV || 'undefined'}`);
  console.log(`   DATABASE_URL: ${process.env.DATABASE_URL ? 'SET (length: ' + process.env.DATABASE_URL.length + ')' : 'NOT SET'}`);
  console.log(`   WEBSITE_SITE_NAME: ${process.env.WEBSITE_SITE_NAME || 'undefined'}\n`);
  
  if (!process.env.DATABASE_URL) {
    console.error('❌ CRITICAL ERROR: DATABASE_URL environment variable is not set!');
    console.error('\n💡 To fix this:');
    console.error('1. Go to Azure Portal');
    console.error('2. Navigate to your App Service: homework-helper-staging');
    console.error('3. Go to Configuration > Application settings');
    console.error('4. Add DATABASE_URL with your PostgreSQL connection string');
    console.error('5. Format: postgresql://username:password@host:port/database');
    console.error('6. Restart the app service');
    process.exit(1);
  }
  
  try {
    // Step 1: Check database connection
    const dbConnected = await checkDatabaseConnection();
    if (!dbConnected) {
      throw new Error('Database connection failed');
    }
    
    // Step 2: Check/create admin table
    const tableExists = await checkAdminTable();
    if (!tableExists) {
      throw new Error('Failed to create admin table');
    }
    
    // Step 3: Fix admin credentials
    const adminFixed = await fixStagingAdmin();
    if (!adminFixed) {
      throw new Error('Failed to fix admin credentials');
    }
    
    // Step 4: Verify setup
    const verified = await verifyAdminSetup();
    if (!verified) {
      throw new Error('Admin setup verification failed');
    }
    
    console.log('\n🎉 SUCCESS! Staging admin portal is now ready!');
    console.log('\n🔑 Login Credentials:');
    console.log('   URL: https://homework-helper-staging.azurewebsites.net/admin/');
    console.log('   Username: admin');
    console.log('   Password: Admin123!Staging');
    console.log('\n✅ You can now login to the admin portal!');
    console.log('\n📝 Next Steps:');
    console.log('1. Go to the admin portal URL above');
    console.log('2. Use the credentials provided');
    console.log('3. Verify you can access the dashboard');
    console.log('4. Check that user management functions work');
    
  } catch (error) {
    console.error('\n❌ FAILED: Staging admin portal fix failed');
    console.error('Error:', error.message);
    console.error('\n🔧 Troubleshooting:');
    console.error('1. Verify DATABASE_URL is correctly set in Azure');
    console.error('2. Check that the database server is accessible');
    console.error('3. Ensure the database has the required tables');
    console.error('4. Check Azure App Service logs for more details');
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run the fix
main();
