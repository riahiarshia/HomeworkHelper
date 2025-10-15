#!/usr/bin/env node

/**
 * Run Monthly Usage Reset Migration
 * This script runs the database migration through the backend connection
 */

const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Database connection using the same config as the backend
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function runMigration() {
    const client = await pool.connect();
    
    try {
        console.log('🚀 Starting Monthly Usage Reset Migration...');
        console.log('📊 Connecting to database...');
        
        // Read the migration SQL file
        const migrationPath = path.join(__dirname, 'database', 'monthly-usage-reset-migration.sql');
        const migrationSQL = fs.readFileSync(migrationPath, 'utf8');
        
        console.log('📝 Executing migration SQL...');
        
        // Split by semicolons and execute each statement
        const statements = migrationSQL.split(';').filter(stmt => stmt.trim().length > 0);
        
        for (const statement of statements) {
            if (statement.trim()) {
                console.log(`⚡ Executing: ${statement.trim().substring(0, 50)}...`);
                await client.query(statement);
            }
        }
        
        console.log('✅ Migration completed successfully!');
        console.log('');
        console.log('📊 What was created:');
        console.log('   • monthly_usage_summary table');
        console.log('   • update_monthly_usage_summary() function');
        console.log('   • reset_monthly_usage_on_renewal() function');
        console.log('   • monthly_costs_summary view');
        console.log('');
        console.log('🎯 Monthly usage reset system is now ready!');
        
    } catch (error) {
        console.error('❌ Migration failed:', error.message);
        throw error;
    } finally {
        client.release();
        await pool.end();
    }
}

// Run the migration
runMigration()
    .then(() => {
        console.log('🎉 Migration completed successfully!');
        process.exit(0);
    })
    .catch((error) => {
        console.error('💥 Migration failed:', error.message);
        process.exit(1);
    });


