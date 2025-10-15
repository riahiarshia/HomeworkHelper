/**
 * Auto-apply database migrations on server startup
 * This runs automatically when the server starts
 */

const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function checkAndApplyMigrations() {
    try {
        console.log('🔍 Checking if usage tracking migration is needed...');

        // Check if table already exists
        const checkResult = await pool.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'user_api_usage';
        `);

        if (checkResult.rows.length > 0) {
            console.log('✅ Usage tracking table already exists');
            
            // Check if device_id column exists
            const deviceColumnCheck = await pool.query(`
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_schema = 'public' 
                AND table_name = 'user_api_usage'
                AND column_name = 'device_id';
            `);
            
            if (deviceColumnCheck.rows.length === 0) {
                console.log('📱 Adding device tracking column...');
                const deviceMigrationPath = path.join(__dirname, 'database', 'add-device-to-usage-tracking.sql');
                const deviceMigrationSQL = fs.readFileSync(deviceMigrationPath, 'utf8');
                await pool.query(deviceMigrationSQL);
                console.log('✅ Device tracking column added!');
            } else {
                console.log('✅ Device tracking column already exists - skipping');
            }
            
            return;
        }

        console.log('📊 Usage tracking table not found - applying migration...');

        // Read and apply migration
        const migrationPath = path.join(__dirname, 'database', 'usage-tracking-migration.sql');
        const migrationSQL = fs.readFileSync(migrationPath, 'utf8');

        await pool.query(migrationSQL);

        console.log('✅ Usage tracking migration applied successfully!');
        console.log('   - user_api_usage table created');
        console.log('   - Views created for reporting');
        console.log('   - Indexes added for performance');

        // Also apply device tracking migration
        console.log('📱 Applying device tracking migration...');
        const deviceMigrationPath = path.join(__dirname, 'database', 'add-device-to-usage-tracking.sql');
        const deviceMigrationSQL = fs.readFileSync(deviceMigrationPath, 'utf8');
        await pool.query(deviceMigrationSQL);
        console.log('✅ Device tracking migration applied!');

    } catch (error) {
        console.error('⚠️  Migration check/apply failed:', error.message);
        // Don't crash the server if migration fails
    }
    // Note: Don't close the pool - server needs to keep using it!
}

// Export for use in server.js
module.exports = checkAndApplyMigrations;

