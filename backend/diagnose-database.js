// Database Connection Diagnostic Script
// Run this in Azure Kudu console to check environment variables and database connection

console.log('🔍 Database Connection Diagnostic');
console.log('================================');

// Check environment variables
console.log('\n📋 Environment Variables:');
console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('DATABASE_URL:', process.env.DATABASE_URL ? 'SET (length: ' + process.env.DATABASE_URL.length + ')' : 'NOT SET');
console.log('WEBSITE_SITE_NAME:', process.env.WEBSITE_SITE_NAME);
console.log('DB_HOST:', process.env.DB_HOST);
console.log('DB_NAME:', process.env.DB_NAME);
console.log('DB_USER:', process.env.DB_USER);
console.log('DB_PORT:', process.env.DB_PORT);

// If DATABASE_URL is set, try to parse it
if (process.env.DATABASE_URL) {
  try {
    const url = new URL(process.env.DATABASE_URL);
    console.log('\n🔗 Parsed DATABASE_URL:');
    console.log('  Protocol:', url.protocol);
    console.log('  Host:', url.hostname);
    console.log('  Port:', url.port);
    console.log('  Database:', url.pathname.substring(1));
    console.log('  Username:', url.username);
    console.log('  Has Password:', url.password ? 'YES' : 'NO');
  } catch (error) {
    console.log('\n❌ Error parsing DATABASE_URL:', error.message);
  }
}

// Try to connect to database
async function testConnection() {
  const { Pool } = require('pg');
  
  try {
    console.log('\n🔌 Testing Database Connection...');
    
    if (!process.env.DATABASE_URL) {
      console.log('❌ DATABASE_URL is not set!');
      console.log('\n💡 To fix this:');
      console.log('1. Go to Azure Portal');
      console.log('2. Navigate to your App Service: homework-helper-staging');
      console.log('3. Go to Configuration > Application settings');
      console.log('4. Add/Update DATABASE_URL with your PostgreSQL connection string');
      console.log('5. Format: postgresql://username:password@host:port/database');
      return;
    }
    
    const pool = new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'staging' 
        ? { rejectUnauthorized: false } 
        : false
    });
    
    console.log('⏳ Attempting to connect...');
    const client = await pool.connect();
    
    // Test query
    const result = await client.query('SELECT NOW() as current_time, current_database() as db_name');
    console.log('✅ Database connection successful!');
    console.log('  Current time:', result.rows[0].current_time);
    console.log('  Database name:', result.rows[0].db_name);
    
    // Check if admin_users table exists
    const tableCheck = await client.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'admin_users'
      );
    `);
    
    console.log('  admin_users table exists:', tableCheck.rows[0].exists);
    
    if (tableCheck.rows[0].exists) {
      // Check current admin users
      const adminCheck = await client.query('SELECT username, email, role, is_active FROM admin_users WHERE username = $1', ['admin']);
      if (adminCheck.rows.length > 0) {
        console.log('  Current admin user:');
        console.log('    Username:', adminCheck.rows[0].username);
        console.log('    Email:', adminCheck.rows[0].email);
        console.log('    Role:', adminCheck.rows[0].role);
        console.log('    Active:', adminCheck.rows[0].is_active);
      } else {
        console.log('  No admin user found with username "admin"');
      }
    }
    
    client.release();
    await pool.end();
    
  } catch (error) {
    console.log('❌ Database connection failed:', error.message);
    console.log('Error code:', error.code);
    
    if (error.code === 'ENOTFOUND') {
      console.log('\n💡 This usually means:');
      console.log('1. The database hostname in DATABASE_URL is incorrect');
      console.log('2. The database server is not accessible from Azure');
      console.log('3. Network connectivity issues');
    } else if (error.code === 'ECONNREFUSED') {
      console.log('\n💡 This usually means:');
      console.log('1. The database server is not running');
      console.log('2. The port is incorrect');
      console.log('3. Firewall blocking the connection');
    } else if (error.code === '28P01') {
      console.log('\n💡 This usually means:');
      console.log('1. Invalid username or password');
      console.log('2. User does not exist in the database');
    }
  }
}

testConnection();
