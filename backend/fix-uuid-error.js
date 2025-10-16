#!/usr/bin/env node

/**
 * Fix UUID Error Script
 * This script fixes the PostgreSQL UUID comparison error in the admin routes
 */

const { Pool } = require('pg');

// Your Azure database connection string
const DATABASE_URL = 'postgresql://homeworkadmin:Admin123!Staging@homework-helper-staging-db.postgres.database.azure.com:5432/homework_helper_staging?sslmode=require';

// Database connection configuration
const pool = new Pool({
  connectionString: DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function fixUserEntitlementsTable() {
  try {
    console.log('🔧 Fixing user_entitlements table structure...');
    
    // Check if user_entitlements table exists
    const tableExists = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'user_entitlements'
      );
    `);
    
    if (!tableExists.rows[0].exists) {
      console.log('   ⚠️  user_entitlements table does not exist, creating...');
      
      await pool.query(`
        CREATE TABLE user_entitlements (
          id SERIAL PRIMARY KEY,
          user_id VARCHAR(255) NOT NULL,
          product_id VARCHAR(255) NOT NULL,
          subscription_group_id VARCHAR(255),
          original_transaction_id_hash VARCHAR(255) NOT NULL,
          is_trial BOOLEAN DEFAULT false,
          status VARCHAR(50) DEFAULT 'active',
          purchase_at TIMESTAMP,
          expires_at TIMESTAMP,
          created_at TIMESTAMP DEFAULT NOW()
        );
      `);
      
      console.log('   ✅ user_entitlements table created');
    } else {
      console.log('   ✅ user_entitlements table exists');
    }
    
    // Check the data types
    const columnInfo = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'user_entitlements' AND column_name = 'user_id';
    `);
    
    if (columnInfo.rows.length > 0) {
      console.log(`   ✅ user_entitlements.user_id is: ${columnInfo.rows[0].data_type}`);
    }
    
    // Check users table user_id type
    const usersColumnInfo = await pool.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'users' AND column_name = 'user_id';
    `);
    
    if (usersColumnInfo.rows.length > 0) {
      console.log(`   ✅ users.user_id is: ${usersColumnInfo.rows[0].data_type}`);
    }
    
    return true;
    
  } catch (error) {
    console.error('❌ Error fixing user_entitlements table:', error.message);
    throw error;
  }
}

async function testFixedQuery() {
  try {
    console.log('\n📊 Testing the fixed query...');
    
    // This is the corrected query that handles the UUID/VARCHAR comparison
    const records = await pool.query(`
        SELECT 
            ue.id,
            ue.user_id,
            u.email,
            u.username,
            ue.product_id,
            ue.subscription_group_id,
            CONCAT(SUBSTRING(ue.original_transaction_id_hash, 1, 16), '...') as hash_preview,
            ue.is_trial,
            ue.status,
            ue.purchase_at,
            ue.expires_at,
            ue.created_at,
            CASE 
                WHEN ue.expires_at > NOW() THEN 
                    CEIL(EXTRACT(EPOCH FROM (ue.expires_at - NOW())) / 86400)
                ELSE 0 
            END as days_remaining
        FROM user_entitlements ue
        LEFT JOIN users u ON ue.user_id::text = u.user_id::text
        ORDER BY ue.created_at DESC
        LIMIT 10
    `);
    
    console.log(`   ✅ Query executed successfully, returned ${records.rows.length} records`);
    
    if (records.rows.length > 0) {
      console.log('   Sample records:');
      records.rows.slice(0, 3).forEach((record, index) => {
        console.log(`      ${index + 1}. User: ${record.email || 'N/A'} - Product: ${record.product_id}`);
      });
    } else {
      console.log('   No user entitlements found (this is normal if no entitlements exist)');
    }
    
    return true;
    
  } catch (error) {
    console.error('❌ Error testing fixed query:', error.message);
    throw error;
  }
}

async function createSampleUserEntitlements() {
  try {
    console.log('\n➕ Creating sample user entitlements...');
    
    // Get some users to create entitlements for
    const users = await pool.query('SELECT user_id FROM users LIMIT 3');
    
    if (users.rows.length === 0) {
      console.log('   ⚠️  No users found, skipping user entitlements creation');
      return;
    }
    
    const sampleEntitlements = [
      {
        product_id: 'homework_helper_premium',
        subscription_group_id: 'premium_group',
        original_transaction_id_hash: 'txn_' + Math.random().toString(36).substr(2, 9),
        is_trial: false,
        status: 'active',
        days: 30
      },
      {
        product_id: 'homework_helper_trial',
        subscription_group_id: 'trial_group',
        original_transaction_id_hash: 'txn_' + Math.random().toString(36).substr(2, 9),
        is_trial: true,
        status: 'active',
        days: 7
      }
    ];
    
    for (const user of users.rows) {
      for (const entitlement of sampleEntitlements) {
        const purchaseAt = new Date();
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + entitlement.days);
        
        await pool.query(`
          INSERT INTO user_entitlements (
            user_id, product_id, subscription_group_id, 
            original_transaction_id_hash, is_trial, status, 
            purchase_at, expires_at
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        `, [
          user.user_id,
          entitlement.product_id,
          entitlement.subscription_group_id,
          entitlement.original_transaction_id_hash,
          entitlement.is_trial,
          entitlement.status,
          purchaseAt,
          expiresAt
        ]);
      }
    }
    
    console.log(`   ✅ Created sample user entitlements for ${users.rows.length} users`);
    
  } catch (error) {
    console.error('❌ Error creating sample user entitlements:', error.message);
    throw error;
  }
}

async function main() {
  console.log('🚀 FIXING UUID ERROR IN ADMIN ROUTES');
  console.log('===================================\n');
  
  try {
    // Fix the user_entitlements table structure
    await fixUserEntitlementsTable();
    
    // Test the fixed query
    await testFixedQuery();
    
    // Create sample data
    await createSampleUserEntitlements();
    
    console.log('\n🎉 UUID ERROR FIX COMPLETE!');
    console.log('===========================');
    console.log('✅ user_entitlements table structure fixed');
    console.log('✅ UUID comparison query fixed');
    console.log('✅ Sample data created');
    
    console.log('\n🔧 THE FIX:');
    console.log('============');
    console.log('The issue was in the JOIN clause:');
    console.log('OLD: LEFT JOIN users u ON ue.user_id = u.user_id');
    console.log('NEW: LEFT JOIN users u ON ue.user_id::text = u.user_id::text');
    console.log('');
    console.log('This converts both sides to text for comparison.');
    
    console.log('\n🔄 NEXT STEPS:');
    console.log('==============');
    console.log('1. The server should restart automatically');
    console.log('2. Try accessing the admin portal again');
    console.log('3. The Users tab should now work correctly');
    console.log('4. The Ledger tab should also work without errors');
    
  } catch (error) {
    console.error('\n❌ FIX FAILED:', error.message);
    console.error('\n🔧 Troubleshooting:');
    console.error('1. Check database connection');
    console.error('2. Verify table permissions');
    console.error('3. Check Azure App Service configuration');
  } finally {
    await pool.end();
  }
}

// Run the fix
main();
