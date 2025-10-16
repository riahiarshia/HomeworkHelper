// Check staging users and compare with production
const { Pool } = require('pg');

const stagingPool = new Pool({
  connectionString: process.env.STAGING_DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

const prodPool = new Pool({
  connectionString: process.env.PROD_DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function checkUsers() {
  try {
    console.log('🔍 Checking users in staging vs production...\n');

    // Get staging users
    console.log('📊 STAGING USERS:');
    const stagingUsers = await stagingPool.query(`
      SELECT user_id, email, username, auth_provider, created_at, is_active 
      FROM users 
      ORDER BY created_at DESC 
      LIMIT 10
    `);
    
    console.log(`Found ${stagingUsers.rows.length} users in staging:`);
    stagingUsers.rows.forEach((user, index) => {
      console.log(`${index + 1}. ${user.email} (${user.username}) - ${user.auth_provider} - Created: ${user.created_at}`);
    });

    console.log('\n📊 PRODUCTION USERS:');
    const prodUsers = await prodPool.query(`
      SELECT user_id, email, username, auth_provider, created_at, is_active 
      FROM users 
      ORDER BY created_at DESC 
      LIMIT 10
    `);
    
    console.log(`Found ${prodUsers.rows.length} users in production:`);
    prodUsers.rows.forEach((user, index) => {
      console.log(`${index + 1}. ${user.email} (${user.username}) - ${user.auth_provider} - Created: ${user.created_at}`);
    });

    // Check for riahiarshia@gmail.com specifically
    console.log('\n🔍 Checking for riahiarshia@gmail.com:');
    
    const stagingRiahiar = await stagingPool.query(`
      SELECT * FROM users WHERE email = 'riahiarshia@gmail.com'
    `);
    
    const prodRiahiar = await prodPool.query(`
      SELECT * FROM users WHERE email = 'riahiarshia@gmail.com'
    `);

    console.log(`Staging: ${stagingRiahiar.rows.length} records found`);
    if (stagingRiahiar.rows.length > 0) {
      console.log('Staging user:', stagingRiahiar.rows[0]);
    }

    console.log(`Production: ${prodRiahiar.rows.length} records found`);
    if (prodRiahiar.rows.length > 0) {
      console.log('Production user:', prodRiahiar.rows[0]);
    }

    // Check total user counts
    const stagingCount = await stagingPool.query('SELECT COUNT(*) FROM users');
    const prodCount = await prodPool.query('SELECT COUNT(*) FROM users');
    
    console.log(`\n📈 Total user counts:`);
    console.log(`Staging: ${stagingCount.rows[0].count} users`);
    console.log(`Production: ${prodCount.rows[0].count} users`);

  } catch (error) {
    console.error('❌ Error checking users:', error);
  } finally {
    await stagingPool.end();
    await prodPool.end();
  }
}

checkUsers();
