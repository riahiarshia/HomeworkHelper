// Standalone Admin Password Fix Script for Staging
// This script can be run directly in Azure Kudu console or locally
const crypto = require('crypto');
const { Pool } = require('pg');

// Configuration
const config = {
  username: 'admin',
  email: 'admin@homeworkhelper-staging.com',
  password: 'Admin123!Staging', // Updated password
  role: 'super_admin'
};

// Use SHA256 to match the current system (same as auth.js)
function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

async function fixAdminPassword() {
  let pool;
  
  try {
    console.log('🔐 Fixing staging admin credentials...');
    console.log('📋 Setting up admin with:');
    console.log('   Username:', config.username);
    console.log('   Email:', config.email);
    console.log('   Password:', config.password);
    
    // Create database connection
    const pool = new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'staging' 
        ? { rejectUnauthorized: false } 
        : false
    });
    
    const passwordHash = hashPassword(config.password);
    
    // First, try to update existing admin
    console.log('⏳ Checking for existing admin user...');
    const updateResult = await pool.query(
      `UPDATE admin_users 
       SET email = $1, password_hash = $2, is_active = true, updated_at = NOW()
       WHERE username = $3 
       RETURNING id, username, email, role`,
      [config.email, passwordHash, config.username]
    );
    
    if (updateResult.rows.length > 0) {
      console.log('✅ Updated existing admin user');
      console.log('   ID:', updateResult.rows[0].id);
      console.log('   Username:', updateResult.rows[0].username);
      console.log('   Email:', updateResult.rows[0].email);
      console.log('   Role:', updateResult.rows[0].role);
    } else {
      console.log('⏳ No existing admin found, creating new one...');
      
      // Create new admin if not exists
      const createResult = await pool.query(
        `INSERT INTO admin_users (username, email, password_hash, role, is_active, created_at, updated_at)
         VALUES ($1, $2, $3, $4, true, NOW(), NOW())
         RETURNING id, username, email, role`,
        [config.username, config.email, passwordHash, config.role]
      );
      
      if (createResult.rows.length > 0) {
        console.log('✅ Created new admin user');
        console.log('   ID:', createResult.rows[0].id);
        console.log('   Username:', createResult.rows[0].username);
        console.log('   Email:', createResult.rows[0].email);
        console.log('   Role:', createResult.rows[0].role);
      } else {
        throw new Error('Failed to create admin user');
      }
    }
    
    console.log('\n🎉 SUCCESS! Admin credentials are now set up.');
    console.log('\n🔑 Login Credentials:');
    console.log('   URL: https://homework-helper-staging.azurewebsites.net/admin/');
    console.log('   Username: admin');
    console.log('   Password: Admin123!Staging');
    console.log('\n✅ You can now login to the admin portal!');
    
  } catch (error) {
    console.error('❌ Error fixing admin credentials:', error.message);
    console.error('Full error:', error);
    
    if (!process.env.DATABASE_URL) {
      console.error('\n⚠️  DATABASE_URL environment variable is not set!');
      console.error('   Make sure you are running this in the Azure environment.');
    }
    
    // Don't exit in Azure environment
    if (process.env.WEBSITE_SITE_NAME) {
      console.log('\n💡 This script is running in Azure environment.');
    } else {
      process.exit(1);
    }
  } finally {
    if (pool) {
      await pool.end();
    }
  }
}

// Run the fix
fixAdminPassword();
