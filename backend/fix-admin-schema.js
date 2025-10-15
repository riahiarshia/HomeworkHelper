// Fix Admin Users Table Schema
const crypto = require('crypto');
const { Pool } = require('pg');

async function fixAdminSchema() {
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
    console.log('🔧 Fixing admin_users table schema...');
    
    const client = await pool.connect();
    
    // Add missing last_login column
    console.log('📊 Adding last_login column...');
    await client.query(`
      ALTER TABLE admin_users 
      ADD COLUMN IF NOT EXISTS last_login TIMESTAMP DEFAULT NULL;
    `);
    console.log('✅ last_login column added');
    
    // Check current admin user
    console.log('🔍 Checking admin user...');
    const adminCheck = await client.query('SELECT * FROM admin_users WHERE username = $1', ['admin']);
    
    if (adminCheck.rows.length > 0) {
      console.log('✅ Admin user exists');
      console.log('   Username:', adminCheck.rows[0].username);
      console.log('   Email:', adminCheck.rows[0].email);
      console.log('   Role:', adminCheck.rows[0].role);
      console.log('   Active:', adminCheck.rows[0].is_active);
    } else {
      console.log('⏳ Creating admin user...');
      
      // Create admin user with correct password
      const password = 'Admin123!Staging';
      const passwordHash = crypto.createHash('sha256').update(password).digest('hex');
      
      await client.query(
        `INSERT INTO admin_users (username, email, password_hash, role, is_active, created_at, updated_at) 
         VALUES ($1, $2, $3, 'super_admin', true, NOW(), NOW())`,
        ['admin', 'admin@homeworkhelper-staging.com', passwordHash]
      );
      
      console.log('✅ Admin user created');
    }
    
    // Show table structure
    console.log('📋 Current table structure:');
    const columns = await client.query(`
      SELECT column_name, data_type, is_nullable, column_default 
      FROM information_schema.columns 
      WHERE table_name = 'admin_users' 
      ORDER BY ordinal_position;
    `);
    
    columns.rows.forEach(col => {
      console.log(`   ${col.column_name}: ${col.data_type} ${col.is_nullable === 'YES' ? '(nullable)' : '(not null)'}`);
    });
    
    console.log('\n🎉 Schema fix completed!');
    console.log('🔑 Login credentials:');
    console.log('   Username: admin');
    console.log('   Password: Admin123!Staging');
    
    client.release();
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

fixAdminSchema();
