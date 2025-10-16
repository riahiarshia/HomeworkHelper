// Update Admin Password Script - Run locally
const crypto = require('crypto');
const { Pool } = require('pg');

async function updateAdminPassword() {
  // Database connection details from the setup
  const dbConfig = {
    host: 'homework-helper-staging-db.postgres.database.azure.com',
    port: 5432,
    database: 'homework_helper_staging',
    user: 'homeworkadmin',
    password: 'Admin123!Staging',
    ssl: { rejectUnauthorized: false }
  };

  const pool = new Pool(dbConfig);

  try {
    console.log('🔐 Connecting to staging database...');
    console.log('📋 Database:', dbConfig.database);
    console.log('🌐 Host:', dbConfig.host);
    
    // Test connection
    const client = await pool.connect();
    console.log('✅ Connected to database successfully!');
    
    // New admin password
    const newPassword = 'Admin123!Staging';
    const passwordHash = crypto.createHash('sha256').update(newPassword).digest('hex');
    
    console.log('\n🔑 Updating admin password...');
    console.log('   Username: admin');
    console.log('   New Password:', newPassword);
    console.log('   Password Hash:', passwordHash.substring(0, 20) + '...');
    
    // First, create the admin_users table if it doesn't exist
    console.log('\n📊 Checking/Creating admin_users table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS admin_users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(255) UNIQUE NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        role VARCHAR(50) DEFAULT 'super_admin',
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ admin_users table ready');
    
    // Try to update existing admin user
    const updateResult = await client.query(
      'UPDATE admin_users SET password_hash = $1, updated_at = CURRENT_TIMESTAMP WHERE username = $2 RETURNING username, email, role',
      [passwordHash, 'admin']
    );
    
    if (updateResult.rows.length > 0) {
      console.log('✅ Updated existing admin user');
      console.log('   Username:', updateResult.rows[0].username);
      console.log('   Email:', updateResult.rows[0].email);
      console.log('   Role:', updateResult.rows[0].role);
    } else {
      console.log('⏳ No existing admin found, creating new one...');
      
      // Create new admin user
      const createResult = await client.query(
        `INSERT INTO admin_users (username, email, password_hash, role, is_active) 
         VALUES ($1, $2, $3, 'super_admin', true) 
         RETURNING username, email, role`,
        ['admin', 'admin@homeworkhelper-staging.com', passwordHash]
      );
      
      if (createResult.rows.length > 0) {
        console.log('✅ Created new admin user');
        console.log('   Username:', createResult.rows[0].username);
        console.log('   Email:', createResult.rows[0].email);
        console.log('   Role:', createResult.rows[0].role);
      }
    }
    
    console.log('\n🎉 SUCCESS! Admin password updated!');
    console.log('\n🔑 Login Credentials:');
    console.log('   URL: https://homework-helper-staging.azurewebsites.net/admin/');
    console.log('   Username: admin');
    console.log('   Password: Admin123!Staging');
    console.log('\n✅ You can now login to the admin portal!');
    
    client.release();
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error('Error code:', error.code);
  } finally {
    await pool.end();
  }
}

updateAdminPassword();
