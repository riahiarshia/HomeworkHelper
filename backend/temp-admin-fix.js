// Fix Staging Admin Credentials
const crypto = require('crypto');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

async function fixStagingAdmin() {
  try {
    console.log('🔐 Fixing staging admin credentials...');
    
    const username = 'admin';
    const email = 'admin@homeworkhelper-staging.com';
    const password = 'admin123';
    const passwordHash = hashPassword(password);
    
    console.log('📋 Setting up admin with:');
    console.log('   Username:', username);
    console.log('   Email:', email);
    console.log('   Password:', password);
    
    // First, try to update existing admin
    const updateResult = await pool.query(
      `UPDATE admin_users 
       SET email = $1, password_hash = $2, is_active = true
       WHERE username = $3 
       RETURNING id, username, email, role`,
      [email, passwordHash, username]
    );
    
    if (updateResult.rows.length > 0) {
      console.log('✅ Updated existing admin user');
    } else {
      console.log('⏳ No existing admin found, creating new one...');
      
      const createResult = await pool.query(
        `INSERT INTO admin_users (username, email, password_hash, role, is_active)
         VALUES ($1, $2, $3, 'super_admin', true)
         RETURNING id, username, email, role`,
        [username, email, passwordHash]
      );
      
      if (createResult.rows.length > 0) {
        console.log('✅ Created new admin user');
      } else {
        throw new Error('Failed to create admin user');
      }
    }
    
    console.log('\n🎉 SUCCESS! Admin credentials are now set up.');
    console.log('\n🔑 Login Credentials:');
    console.log('   URL: https://homework-helper-staging.azurewebsites.net/admin/');
    console.log('   Username: admin');
    console.log('   Password: admin123');
    console.log('\n✅ You can now login to the admin portal!');
    
  } catch (error) {
    console.error('❌ Error fixing admin credentials:', error.message);
    console.error('Full error:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

fixStagingAdmin();
