const { Pool } = require('pg');

const pool = new Pool({
  connectionString: 'postgresql://homeworkadmin:Admin123!Staging@homework-helper-staging-db.postgres.database.azure.com:5432/homework_helper_staging?sslmode=require',
  ssl: { rejectUnauthorized: false }
});

async function completeFix() {
  try {
    console.log('🚀 COMPLETING DATABASE FIX');
    
    // Fix device_logins table
    await pool.query('DROP TABLE IF EXISTS device_logins CASCADE');
    await pool.query(`
      CREATE TABLE device_logins (
        id SERIAL PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        device_id VARCHAR(255) NOT NULL,
        device_type VARCHAR(50),
        login_time TIMESTAMP DEFAULT NOW(),
        ip_address INET,
        user_agent TEXT
      )
    `);
    console.log('✅ Fixed device_logins table');
    
    // Populate device data
    const users = await pool.query('SELECT user_id FROM users LIMIT 5');
    for (const user of users.rows) {
      for (let i = 0; i < 3; i++) {
        await pool.query(`
          INSERT INTO device_logins (user_id, device_id, device_type, login_time, ip_address)
          VALUES ($1, $2, $3, NOW() - INTERVAL '${i + 1} days', $4)
        `, [
          user.user_id, 
          `device-${i}`, 
          ['iPhone', 'iPad', 'Android'][i], 
          `192.168.1.${100 + i}`
        ]);
      }
    }
    console.log('✅ Populated device login data');
    
    // Create promo codes
    const promos = [
      ['WELCOME2024', 7, 100, 'Welcome promo'],
      ['STUDENT50', 14, 50, 'Student discount'],
      ['TEACHER30', 30, 25, 'Teacher special'],
      ['BACKTOSCHOOL', 21, 75, 'Back to school'],
      ['HOLIDAY2024', 14, 100, 'Holiday special']
    ];
    
    for (const [code, days, uses, desc] of promos) {
      await pool.query(`
        INSERT INTO promo_codes (code, duration_days, uses_total, uses_remaining, description, created_by)
        VALUES ($1, $2, $3, $3, $4, 'admin')
        ON CONFLICT (code) DO NOTHING
      `, [code, days, uses, desc]);
    }
    console.log('✅ Created promo codes');
    
    // Final report
    const [usersResult, apiResult, promoResult, deviceResult] = await Promise.all([
      pool.query('SELECT COUNT(*) as count FROM users'),
      pool.query('SELECT COUNT(*) as count FROM user_api_usage'),
      pool.query('SELECT COUNT(*) as count FROM promo_codes'),
      pool.query('SELECT COUNT(*) as count FROM device_logins')
    ]);
    
    console.log('\n📈 FINAL STATISTICS:');
    console.log(`👥 Users: ${usersResult.rows[0].count}`);
    console.log(`📊 API Usage: ${apiResult.rows[0].count}`);
    console.log(`🎟️  Promo Codes: ${promoResult.rows[0].count}`);
    console.log(`📱 Device Logins: ${deviceResult.rows[0].count}`);
    
    console.log('\n🎉 SUCCESS! Your admin portal is now fully populated!');
    console.log('🔑 Login: https://homework-helper-staging.azurewebsites.net/admin/');
    console.log('👤 Username: admin | Password: Admin123!Staging');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

completeFix();
