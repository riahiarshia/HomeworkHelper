// Direct SQL Update for Admin Credentials
// This script will directly update the admin password in the database

const crypto = require('crypto');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

async function updateAdminPassword() {
  try {
    console.log('🔐 Updating admin password...');
    
    const username = 'admin';
    const password = 'admin123';
    const passwordHash = hashPassword(password);
    
    console.log('📋 New credentials:');
    console.log('   Username: admin');
    console.log('   Password: admin123');
    console.log('   Hash:', passwordHash.substring(0, 20) + '...');
    
    // Update admin password
    const result = await pool.query(
      `UPDATE admin_users 
       SET password_hash = $1, is_active = true, updated_at = NOW()
       WHERE username = $2 
       RETURNING id, username, email, role`,
      [passwordHash, username]
    );
    
    if (result.rows.length > 0) {
      const admin = result.rows[0];
      console.log('\n✅ Admin password updated successfully!');
      console.log('📋 Admin Details:');
      console.log('   ID:', admin.id);
      console.log('   Username:', admin.username);
      console.log('   Email:', admin.email);
      console.log('   Role:', admin.role);
      console.log('\n🔑 Login Credentials:');
      console.log('   URL: https://homework-helper-staging.azurewebsites.net/admin/');
      console.log('   Username: admin');
      console.log('   Password: admin123');
      console.log('\n✅ You can now login!');
    } else {
      console.log('❌ Admin user not found. Creating new admin...');
      
      // Create new admin
      const createResult = await pool.query(
        `INSERT INTO admin_users (username, email, password_hash, role, is_active, created_at, updated_at)
         VALUES ($1, $2, $3, 'super_admin', true, NOW(), NOW())
         RETURNING id, username, email, role`,
        [username, 'admin@homeworkhelper-staging.com', passwordHash]
      );
      
      if (createResult.rows.length > 0) {
        console.log('\n✅ New admin user created!');
        console.log('🔑 Login Credentials:');
        console.log('   Username: admin');
        console.log('   Password: admin123');
      }
    }
    
  } catch (error) {
    console.error('❌ Error updating admin:', error.message);
    console.error('Full error:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

updateAdminPassword();
