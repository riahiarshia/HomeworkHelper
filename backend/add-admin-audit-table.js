// Add admin audit logging table for tracking admin actions
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function addAdminAuditTable() {
  try {
    console.log('🔧 Adding admin audit logging table...');

    // Create admin_audit_log table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS admin_audit_log (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        admin_user_id UUID NOT NULL REFERENCES admin_users(id),
        admin_username VARCHAR(255) NOT NULL,
        admin_email VARCHAR(255) NOT NULL,
        action VARCHAR(100) NOT NULL,
        target_type VARCHAR(50) NOT NULL,
        target_id UUID,
        target_email VARCHAR(255),
        target_username VARCHAR(255),
        details JSONB,
        ip_address INET,
        user_agent TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
      );
    `);

    // Create indexes for better query performance
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_admin_audit_log_admin_user_id ON admin_audit_log(admin_user_id);
    `);

    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_admin_audit_log_created_at ON admin_audit_log(created_at);
    `);

    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_admin_audit_log_action ON admin_audit_log(action);
    `);

    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_admin_audit_log_target_type ON admin_audit_log(target_type);
    `);

    console.log('✅ admin_audit_log table created successfully');

    // Test the table structure
    const tableInfo = await pool.query(`
      SELECT column_name, data_type, is_nullable 
      FROM information_schema.columns 
      WHERE table_name = 'admin_audit_log' 
      ORDER BY ordinal_position;
    `);

    console.log('\n📋 admin_audit_log table structure:');
    tableInfo.rows.forEach(row => {
      console.log(`   ${row.column_name}: ${row.data_type} (${row.is_nullable === 'YES' ? 'nullable' : 'not null'})`);
    });

    // Test insert
    console.log('\n🧪 Testing audit log insert...');
    const testInsert = await pool.query(`
      INSERT INTO admin_audit_log (admin_user_id, admin_username, admin_email, action, target_type, target_id, details)
      VALUES (
        (SELECT id FROM admin_users WHERE username = 'admin' LIMIT 1),
        'admin',
        'admin@homeworkhelper-staging.com',
        'table_creation_test',
        'system',
        gen_random_uuid(),
        '{"test": true, "message": "Testing audit log functionality"}'
      )
      RETURNING id, action, created_at;
    `);

    console.log('✅ Test audit log entry created:', testInsert.rows[0]);

    // Clean up test entry
    await pool.query(`
      DELETE FROM admin_audit_log WHERE action = 'table_creation_test';
    `);

    console.log('🧹 Test entry cleaned up');

    console.log('\n🎉 Admin audit logging table setup complete!');
    console.log('\n📋 What this enables:');
    console.log('   ✅ Track all admin actions (user deletions, modifications, etc.)');
    console.log('   ✅ Maintain audit trail for compliance');
    console.log('   ✅ Identify which admin performed which actions');
    console.log('   ✅ Log IP addresses and user agents for security');
    console.log('   ✅ Store action details in JSON format for flexibility');

  } catch (error) {
    console.error('❌ Error setting up admin audit table:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

addAdminAuditTable();
