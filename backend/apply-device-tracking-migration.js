/**
 * Apply Device Tracking Migration to Azure PostgreSQL
 * Run this script to add device tracking tables to the database
 */

const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function applyMigration() {
    console.log('🚀 Starting Device Tracking Migration...');
    
    try {
        // Check if migration has already been applied
        const checkResult = await pool.query(`
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'device_logins'
            );
        `);
        
        if (checkResult.rows[0].exists) {
            console.log('✅ Device tracking tables already exist. Migration skipped.');
            return;
        }
        
        console.log('📋 Creating device tracking tables...');
        
        // Apply the migration
        await pool.query(`
            -- Device tracking tables for fraud detection and analytics
            -- Best practice: Track everything, block nothing, flag suspicious activity
            
            -- Track all device logins
            CREATE TABLE device_logins (
              id SERIAL PRIMARY KEY,
              user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
              device_id VARCHAR(255) NOT NULL,
              login_time TIMESTAMP DEFAULT NOW(),
              ip_address INET,
              user_agent TEXT,
              device_info JSONB, -- Store device model, OS version, etc.
              created_at TIMESTAMP DEFAULT NOW()
            );
            
            -- Create index for efficient queries
            CREATE INDEX idx_device_logins_device_id ON device_logins(device_id);
            CREATE INDEX idx_device_logins_user_id ON device_logins(user_id);
            CREATE INDEX idx_device_logins_login_time ON device_logins(login_time);
            
            -- Flag suspicious activity for manual review
            CREATE TABLE fraud_flags (
              id SERIAL PRIMARY KEY,
              user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
              device_id VARCHAR(255),
              reason TEXT NOT NULL,
              severity VARCHAR(20) DEFAULT 'low', -- 'low', 'medium', 'high'
              details JSONB, -- Store additional context
              resolved BOOLEAN DEFAULT FALSE,
              resolved_at TIMESTAMP,
              resolved_by UUID REFERENCES users(user_id),
              created_at TIMESTAMP DEFAULT NOW()
            );
            
            -- Create index for fraud monitoring
            CREATE INDEX idx_fraud_flags_user_id ON fraud_flags(user_id);
            CREATE INDEX idx_fraud_flags_device_id ON fraud_flags(device_id);
            CREATE INDEX idx_fraud_flags_resolved ON fraud_flags(resolved);
            CREATE INDEX idx_fraud_flags_severity ON fraud_flags(severity);
            
            -- Optional: Device preferences per user (for trusted devices)
            CREATE TABLE user_devices (
              user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
              device_id VARCHAR(255) NOT NULL,
              device_name VARCHAR(255), -- "iPhone 15", "iPad Pro", etc.
              is_trusted BOOLEAN DEFAULT FALSE,
              first_seen TIMESTAMP DEFAULT NOW(),
              last_seen TIMESTAMP DEFAULT NOW(),
              login_count INTEGER DEFAULT 1,
              PRIMARY KEY (user_id, device_id)
            );
            
            -- Create index for device preferences
            CREATE INDEX idx_user_devices_user_id ON user_devices(user_id);
            CREATE INDEX idx_user_devices_device_id ON user_devices(device_id);
            CREATE INDEX idx_user_devices_trusted ON user_devices(is_trusted);
            
            -- Add comments for documentation
            COMMENT ON TABLE device_logins IS 'Tracks all device login attempts for analytics and fraud detection';
            COMMENT ON TABLE fraud_flags IS 'Flags suspicious activity patterns for manual review';
            COMMENT ON TABLE user_devices IS 'Stores user device preferences and trusted device status';
        `);
        
        console.log('✅ Device tracking migration completed successfully!');
        console.log('📊 Created tables: device_logins, fraud_flags, user_devices');
        console.log('🔍 Added indexes for performance optimization');
        console.log('🚀 Device tracking system is now ready!');
        
    } catch (error) {
        console.error('❌ Migration failed:', error.message);
        console.error('Stack trace:', error.stack);
        process.exit(1);
    } finally {
        await pool.end();
    }
}

// Run the migration
applyMigration().catch(error => {
    console.error('❌ Migration script failed:', error);
    process.exit(1);
});
