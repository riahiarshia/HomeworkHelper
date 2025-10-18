// Migration script to add password_hash column to users table
require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function runMigration() {
    console.log('🔄 Running database migration...');
    console.log('📋 Adding password_hash column to users table');
    
    try {
        // Add password_hash column
        await pool.query(`
            ALTER TABLE users 
            ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);
        `);
        console.log('✅ password_hash column added');
        
        // Add index
        await pool.query(`
            CREATE INDEX IF NOT EXISTS idx_users_password_hash ON users(password_hash);
        `);
        console.log('✅ Index created');
        
        // Verify column exists
        const result = await pool.query(`
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'users' AND column_name = 'password_hash';
        `);
        
        if (result.rows.length > 0) {
            console.log('✅ Migration successful!');
            console.log('📊 Column info:', result.rows[0]);
        } else {
            console.log('❌ Migration failed - column not found');
        }
        
    } catch (error) {
        console.error('❌ Migration error:', error.message);
        process.exit(1);
    } finally {
        await pool.end();
    }
}

runMigration();

