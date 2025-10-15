const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function backupDatabaseStructure() {
    console.log('📦 Starting database structure backup...');
    
    try {
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
            console.log(`📝 Backing up table: ${tableName}`);
            
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
            
            // Get indexes
            const indexesResult = await pool.query(`
                SELECT
                    indexname,
                    indexdef
                FROM pg_indexes
                WHERE tablename = $1
                AND schemaname = 'public';
            `, [tableName]);
            
            if (indexesResult.rows.length > 0) {
                backup += `-- Indexes:\n`;
                for (const idx of indexesResult.rows) {
                    backup += `--   ${idx.indexname}: ${idx.indexdef}\n`;
                }
            }
            
            // Get constraints
            const constraintsResult = await pool.query(`
                SELECT
                    conname,
                    pg_get_constraintdef(oid) as condef
                FROM pg_constraint
                WHERE conrelid = $1::regclass;
            `, [tableName]);
            
            if (constraintsResult.rows.length > 0) {
                backup += `-- Constraints:\n`;
                for (const con of constraintsResult.rows) {
                    backup += `--   ${con.conname}: ${con.condef}\n`;
                }
            }
            
            backup += `\n`;
        }
        
        // Save backup to file
        const backupDir = path.join(__dirname, 'backups');
        if (!fs.existsSync(backupDir)) {
            fs.mkdirSync(backupDir);
        }
        
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const backupFile = path.join(backupDir, `db-backup-${timestamp}.sql`);
        fs.writeFileSync(backupFile, backup);
        
        console.log(`✅ Backup saved to: ${backupFile}`);
        console.log(`📊 Backup size: ${(backup.length / 1024).toFixed(2)} KB`);
        
        return backupFile;
        
    } catch (error) {
        console.error('❌ Backup failed:', error);
        throw error;
    }
}

async function applyAppleMigration() {
    console.log('\n🔧 Applying Apple Sign-In migration...');
    
    try {
        // Check if column already exists
        const checkResult = await pool.query(`
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'users' 
            AND column_name = 'apple_user_id';
        `);
        
        if (checkResult.rows.length > 0) {
            console.log('ℹ️  apple_user_id column already exists - skipping');
            return false;
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
            console.log(`   Type: ${verifyResult.rows[0].data_type}`);
            return true;
        } else {
            throw new Error('Migration verification failed');
        }
        
    } catch (error) {
        console.error('❌ Migration failed:', error);
        throw error;
    }
}

async function main() {
    try {
        console.log('🚀 Starting backup and migration process...\n');
        
        // Step 1: Backup
        const backupFile = await backupDatabaseStructure();
        
        // Step 2: Apply migration
        const migrated = await applyAppleMigration();
        
        if (migrated) {
            console.log('\n🎉 SUCCESS! Database updated for Apple Sign-In');
            console.log(`📦 Backup saved at: ${backupFile}`);
        } else {
            console.log('\n✅ No changes needed - column already exists');
        }
        
    } catch (error) {
        console.error('\n❌ Process failed:', error);
        process.exit(1);
    } finally {
        await pool.end();
    }
}

// Run if called directly
if (require.main === module) {
    main();
}

module.exports = { backupDatabaseStructure, applyAppleMigration };

