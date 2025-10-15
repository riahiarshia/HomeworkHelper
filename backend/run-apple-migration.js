const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

async function runAppleMigration() {
    try {
        console.log('🍎 Starting Apple subscription database migration...');
        
        // Test database connection
        const testResult = await pool.query('SELECT NOW() as current_time');
        console.log('✅ Database connected:', testResult.rows[0].current_time);
        
        // Add Apple subscription columns
        console.log('📊 Adding Apple subscription columns...');
        
        await pool.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS apple_original_transaction_id VARCHAR(255)');
        console.log('✅ Added apple_original_transaction_id');
        
        await pool.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS apple_product_id VARCHAR(255)');
        console.log('✅ Added apple_product_id');
        
        await pool.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS apple_environment VARCHAR(50) DEFAULT \'Production\'');
        console.log('✅ Added apple_environment');
        
        // Add indexes for performance
        console.log('📊 Creating performance indexes...');
        await pool.query('CREATE INDEX IF NOT EXISTS idx_apple_original_transaction_id ON users(apple_original_transaction_id)');
        await pool.query('CREATE INDEX IF NOT EXISTS idx_apple_product_id ON users(apple_product_id)');
        console.log('✅ Created indexes');
        
        // Verify columns were added
        const columnCheck = await pool.query('SELECT column_name FROM information_schema.columns WHERE table_name = \'users\' AND column_name LIKE \'apple_%\'');
        console.log('📋 Apple columns in database:', columnCheck.rows.map(r => r.column_name));
        
        console.log('🎉 Apple subscription database migration completed successfully!');
        
    } catch (error) {
        if (error.message.includes('already exists')) {
            console.log('ℹ️ Apple subscription columns already exist - migration not needed');
        } else {
            console.error('❌ Migration failed:', error.message);
            console.error('Error details:', error);
        }
    } finally {
        await pool.end();
    }
}

runAppleMigration();
