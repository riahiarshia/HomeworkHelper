// Fix Users Table Schema for Staging
const crypto = require('crypto');
const { Pool } = require('pg');

async function fixUsersTable() {
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
    console.log('🔧 Fixing users table schema...');
    
    const client = await pool.connect();
    
    // Create users table if it doesn't exist
    console.log('📊 Creating users table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        user_id UUID UNIQUE NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        username VARCHAR(255) NOT NULL,
        auth_provider VARCHAR(50) DEFAULT 'email',
        subscription_status VARCHAR(50) DEFAULT 'expired',
        subscription_start_date TIMESTAMP,
        subscription_end_date TIMESTAMP,
        is_active BOOLEAN DEFAULT true,
        is_banned BOOLEAN DEFAULT false,
        banned_reason TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ users table created/verified');
    
    // Create subscription_history table if it doesn't exist
    console.log('📊 Creating subscription_history table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS subscription_history (
        id SERIAL PRIMARY KEY,
        user_id UUID NOT NULL,
        event_type VARCHAR(100) NOT NULL,
        new_status VARCHAR(50),
        new_end_date TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
      );
    `);
    console.log('✅ subscription_history table created/verified');
    
    // Show table structure
    console.log('📋 Users table structure:');
    const columns = await client.query(`
      SELECT column_name, data_type, is_nullable, column_default 
      FROM information_schema.columns 
      WHERE table_name = 'users' 
      ORDER BY ordinal_position;
    `);
    
    columns.rows.forEach(col => {
      console.log(`   ${col.column_name}: ${col.data_type} ${col.is_nullable === 'YES' ? '(nullable)' : '(not null)'}`);
    });
    
    // Test user creation
    console.log('🧪 Testing user creation...');
    const testUserId = crypto.randomUUID();
    const testResult = await client.query(`
      INSERT INTO users (
        user_id, email, username, auth_provider,
        subscription_status, subscription_start_date, subscription_end_date,
        is_active, is_banned
      )
      VALUES ($1, $2, $3, 'google', 'expired', NULL, NULL, true, false)
      RETURNING user_id, email, username
    `, [testUserId, 'test@example.com', 'Test User']);
    
    console.log('✅ Test user created:', testResult.rows[0]);
    
    // Clean up test user
    await client.query('DELETE FROM users WHERE user_id = $1', [testUserId]);
    console.log('🧹 Test user cleaned up');
    
    console.log('\n🎉 Users table schema fix completed!');
    console.log('🔑 Google authentication should now work properly');
    
    client.release();
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error('Full error:', error);
  } finally {
    await pool.end();
  }
}

fixUsersTable();
