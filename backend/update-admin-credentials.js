// Update Admin Credentials
// This script updates the admin user's email and password
const bcrypt = require('bcrypt');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

async function updateAdminCredentials() {
  try {
    console.log('🔐 Updating admin credentials...');
    
    const newEmail = 'support_homework@arshia.com';
    const newPassword = 'A@dMin%f$7';
    const username = 'admin';
    
    // Hash the new password
    console.log('⏳ Hashing password...');
    const passwordHash = await bcrypt.hash(newPassword, 10);
    
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
      console.log('\n🔑 New Password: A@dMin%f$7');
      console.log('\n⚠️  Make sure to save these credentials securely!\n');
    } else {
      console.log(`❌ Admin user '${username}' not found in database`);
      console.log('   Creating new admin user...');
      
      // Create new admin if not exists
      const createResult = await pool.query(
        `INSERT INTO admin_users (username, email, password_hash, role)
         VALUES ($1, $2, $3, 'super_admin')
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
        console.log('\n🔑 Password: A@dMin%f$7\n');
      }
    }
    
  } catch (error) {
    console.error('❌ Error updating admin credentials:', error.message);
    console.error('Full error:', error);
    
    if (!process.env.DATABASE_URL) {
      console.error('\n⚠️  DATABASE_URL environment variable is not set!');
      console.error('   You need to set this to your Azure PostgreSQL connection string.');
      console.error('\n   Example:');
      console.error('   DATABASE_URL=postgresql://user:password@host:port/database node update-admin-credentials.js');
    }
    
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run the update
updateAdminCredentials();

