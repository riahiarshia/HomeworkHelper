/**
 * Apply Usage Tracking Migration
 * This script creates the user_api_usage table and views
 */

const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function applyMigration() {
    console.log('🚀 Starting Usage Tracking Migration...\n');

    try {
        // Read the migration SQL file
        const migrationPath = path.join(__dirname, 'database', 'usage-tracking-migration.sql');
        const migrationSQL = fs.readFileSync(migrationPath, 'utf8');

        console.log('📄 Migration file loaded successfully');
        console.log('🔗 Connecting to database...');

        // Execute the migration
        await pool.query(migrationSQL);

        console.log('\n✅ Migration applied successfully!');
        console.log('📊 Created:');
        console.log('   - user_api_usage table');
        console.log('   - user_usage_summary view');
        console.log('   - monthly_usage_summary view');
        console.log('   - endpoint_usage_summary view');
        console.log('   - daily_usage_summary view');
        console.log('\n🎉 Token tracking system is now ready!\n');

        // Verify tables were created
        const checkResult = await pool.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'user_api_usage';
        `);

        if (checkResult.rows.length > 0) {
            console.log('✓ Verified: user_api_usage table exists');
        } else {
            console.log('⚠️  Warning: Could not verify table creation');
        }

    } catch (error) {
        console.error('\n❌ Migration failed:', error.message);
        console.error('Error details:', error);
        process.exit(1);
    } finally {
        await pool.end();
    }
}

// Run the migration
applyMigration();

