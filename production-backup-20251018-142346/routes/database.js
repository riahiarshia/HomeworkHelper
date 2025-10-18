const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

/**
 * POST /api/database/backup
 * Backup database structure
 */
router.post('/backup', async (req, res) => {
    try {
        console.log('📦 Starting database structure backup...');
        
        // Get all tables
        const tablesResult = await pool.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_type = 'BASE TABLE'
            ORDER BY table_name;
        `);
        
        let backup = `-- Database Backup - ${new Date().toISOString()}\n`;
        backup += `-- Generated automatically before Apple Sign-In migration\n\n`;
        
        console.log(`📋 Found ${tablesResult.rows.length} tables`);
        
        for (const row of tablesResult.rows) {
            const tableName = row.table_name;
            
            // Get table structure
            const columnsResult = await pool.query(`
                SELECT 
                    column_name,
                    data_type,
                    character_maximum_length,
                    is_nullable,
                    column_default
                FROM information_schema.columns
                WHERE table_name = $1
                ORDER BY ordinal_position;
            `, [tableName]);
            
            backup += `\n-- Table: ${tableName}\n`;
            backup += `-- Columns:\n`;
            for (const col of columnsResult.rows) {
                backup += `--   ${col.column_name}: ${col.data_type}`;
                if (col.character_maximum_length) {
                    backup += `(${col.character_maximum_length})`;
                }
                backup += ` | nullable: ${col.is_nullable}`;
                if (col.column_default) {
                    backup += ` | default: ${col.column_default}`;
                }
                backup += `\n`;
            }
            
            backup += `\n`;
        }
        
        console.log(`✅ Backup generated: ${(backup.length / 1024).toFixed(2)} KB`);
        
        res.json({
            success: true,
            backup: backup,
            timestamp: new Date().toISOString(),
            tables: tablesResult.rows.length
        });
        
    } catch (error) {
        console.error('❌ Backup failed:', error);
        res.status(500).json({ error: 'Backup failed', details: error.message });
    }
});

/**
 * POST /api/database/migrate-apple
 * Apply Apple Sign-In migration
 */
router.post('/migrate-apple', async (req, res) => {
    try {
        console.log('🔧 Applying Apple Sign-In migration...');
        
        // Check if column already exists
        const checkResult = await pool.query(`
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'users' 
            AND column_name = 'apple_user_id';
        `);
        
        if (checkResult.rows.length > 0) {
            console.log('ℹ️  apple_user_id column already exists - skipping');
            return res.json({
                success: true,
                message: 'apple_user_id column already exists',
                alreadyExists: true
            });
        }
        
        // Add the column
        console.log('📝 Adding apple_user_id column...');
        await pool.query(`
            ALTER TABLE users ADD COLUMN apple_user_id VARCHAR(255);
        `);
        console.log('✅ Column added successfully');
        
        // Add index
        console.log('📝 Creating index on apple_user_id...');
        await pool.query(`
            CREATE INDEX idx_users_apple_user_id ON users(apple_user_id);
        `);
        console.log('✅ Index created successfully');
        
        // Verify
        const verifyResult = await pool.query(`
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'users' 
            AND column_name = 'apple_user_id';
        `);
        
        if (verifyResult.rows.length > 0) {
            console.log('✅ Migration verified - apple_user_id column exists');
            res.json({
                success: true,
                message: 'apple_user_id column added successfully',
                column: verifyResult.rows[0]
            });
        } else {
            throw new Error('Migration verification failed');
        }
        
    } catch (error) {
        console.error('❌ Migration failed:', error);
        res.status(500).json({ error: 'Migration failed', details: error.message });
    }
});

/**
 * GET /api/database/status
 * Check database status and apple_user_id column
 */
router.get('/status', async (req, res) => {
    try {
        // Check if apple_user_id column exists
        const columnResult = await pool.query(`
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name = 'users' 
            AND column_name = 'apple_user_id';
        `);
        
        // Check if index exists
        const indexResult = await pool.query(`
            SELECT indexname
            FROM pg_indexes
            WHERE tablename = 'users'
            AND indexname = 'idx_users_apple_user_id';
        `);
        
        // Count users
        const countResult = await pool.query(`SELECT COUNT(*) FROM users;`);
        
        res.json({
            success: true,
            appleColumnExists: columnResult.rows.length > 0,
            appleIndexExists: indexResult.rows.length > 0,
            totalUsers: parseInt(countResult.rows[0].count),
            column: columnResult.rows[0] || null
        });
        
    } catch (error) {
        console.error('❌ Status check failed:', error);
        res.status(500).json({ error: 'Status check failed', details: error.message });
    }
});

module.exports = router;

