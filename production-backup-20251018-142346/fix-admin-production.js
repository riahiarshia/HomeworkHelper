// Fix Admin Password - Production Database
// Upload this to Azure and run in Kudu Console
const crypto = require('crypto');
const { Pool } = require('pg');

console.log('🔐 FIXING ADMIN PASSWORD - PRODUCTION DATABASE');
console.log('===============================================');
console.log('');

// Check if DATABASE_URL is set
if (!process.env.DATABASE_URL) {
  console.error('❌ DATABASE_URL environment variable is not set!');
  console.error('   This script must be run on the Azure server where DATABASE_URL is configured.');
  console.error('   Go to Azure Portal → App Service → Configuration → Connection strings');
  process.exit(1);
}

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
    
    console.log('🔍 Connecting to production database...');
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
        console.log('   https://homework-helper-api.azurewebsites.net/admin/');
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
        console.log('   https://homework-helper-api.azurewebsites.net/admin/');
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
      console.log('   1. Go to: https://homework-helper-api.azurewebsites.net/admin/');
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
