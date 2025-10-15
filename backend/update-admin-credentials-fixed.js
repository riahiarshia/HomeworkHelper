// Update Admin Credentials - FIXED VERSION
// This script uses SHA256 hashing to match the current auth system
const crypto = require('crypto');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// Use SHA256 to match the current system (same as auth.js)
function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

async function updateAdminCredentials() {
  try {
    console.log('🔐 Updating admin credentials...');
    
    const newEmail = 'support_homework@arshia.com';
    const newPassword = 'A@dMin%f$7';
    const username = 'admin';
    
    // Hash the password using SHA256 (matches auth.js)
    console.log('⏳ Hashing password with SHA256...');
    const passwordHash = hashPassword(newPassword);
    
    console.log('📋 Password hash (SHA256):', passwordHash.substring(0, 20) + '...');
    
    // Update the admin user
    console.log('⏳ Updating database...');
    const result = await pool.query(
      `UPDATE admin_users 
       SET email = $1, password_hash = $2 
       WHERE username = $3 
       RETURNING id, username, email, role`,
      [newEmail, passwordHash, username]
    );
    
    if (result.rows.length > 0) {
      const admin = result.rows[0];
      console.log('\n✅ Admin credentials updated successfully!\n');
      console.log('📋 Updated Admin Details:');
      console.log('   Username:', admin.username);
      console.log('   Email:', admin.email);
      console.log('   Role:', admin.role);
      console.log('\n🔑 Login Credentials:');
      console.log('   Username: admin');
      console.log('   Password: A@dMin%f$7');
      console.log('\n⚠️  Make sure to save these credentials securely!');
      console.log('\n🌐 Admin Portal URL:');
      console.log('   https://your-app-name.azurewebsites.net/admin/\n');
    } else {
      console.log(`❌ Admin user '${username}' not found in database`);
      console.log('   Creating new admin user...');
      
      // Create new admin if not exists
      const createResult = await pool.query(
        `INSERT INTO admin_users (username, email, password_hash, role, is_active)
         VALUES ($1, $2, $3, 'super_admin', true)
         RETURNING id, username, email, role`,
        [username, newEmail, passwordHash]
      );
      
      if (createResult.rows.length > 0) {
        const newAdmin = createResult.rows[0];
        console.log('\n✅ New admin user created successfully!\n');
        console.log('📋 Admin Details:');
        console.log('   Username:', newAdmin.username);
        console.log('   Email:', newAdmin.email);
        console.log('   Role:', newAdmin.role);
        console.log('\n🔑 Login Credentials:');
        console.log('   Username: admin');
        console.log('   Password: A@dMin%f$7\n');
      }
    }
    
  } catch (error) {
    console.error('❌ Error updating admin credentials:', error.message);
    console.error('Full error:', error);
    
    if (!process.env.DATABASE_URL) {
      console.error('\n⚠️  DATABASE_URL environment variable is not set!');
      console.error('   You need to set this to your Azure PostgreSQL connection string.');
    }
    
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run the update
updateAdminCredentials();



