#!/usr/bin/env node

/**
 * Apply Monthly Usage Reset Migration
 * 
 * This script applies the monthly usage reset and cost tracking migration
 * to enable monthly cost tracking and usage reset on subscription renewal.
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
    const client = await pool.connect();
    
    try {
        console.log('🚀 Starting Monthly Usage Reset Migration...');
        
        // Read the migration SQL file
        const migrationPath = path.join(__dirname, 'database', 'monthly-usage-reset-migration.sql');
        const migrationSQL = fs.readFileSync(migrationPath, 'utf8');
        
        // Execute the migration
        await client.query(migrationSQL);
        
        console.log('✅ Monthly Usage Reset Migration Applied Successfully!');
        console.log('');
        console.log('📊 What was created:');
        console.log('   • monthly_usage_summary table');
        console.log('   • update_monthly_usage_summary() function');
        console.log('   • reset_monthly_usage_on_renewal() function');
        console.log('   • monthly_costs_summary view');
        console.log('');
        console.log('🔄 Features enabled:');
        console.log('   • Monthly usage reset on subscription renewal');
        console.log('   • Monthly cost tracking per user');
        console.log('   • Admin portal monthly costs view');
        console.log('   • Historical data preservation');
        console.log('');
        console.log('📈 Admin Portal Endpoints:');
        console.log('   • GET /api/admin/monthly-costs');
        console.log('   • GET /api/admin/user-monthly-usage/:userId');
        console.log('');
        console.log('🎯 Next Steps:');
        console.log('   1. ✅ Database migration applied');
        console.log('   2. ✅ Backend code updated');
        console.log('   3. 🔄 Deploy updated backend to Azure');
        console.log('   4. 📊 Test monthly costs in admin portal');
        console.log('   5. 🔄 Test subscription renewal with usage reset');
        
    } catch (error) {
        console.error('❌ Migration failed:', error);
        throw error;
    } finally {
        client.release();
    }
}

// Run the migration
if (require.main === module) {
    applyMigration()
        .then(() => {
            console.log('🎉 Migration completed successfully!');
            process.exit(0);
        })
        .catch((error) => {
            console.error('💥 Migration failed:', error);
            process.exit(1);
        });
}

module.exports = { applyMigration };


