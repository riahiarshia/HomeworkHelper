#!/usr/bin/env node

// Fix homework_submissions table - Run this on Azure App Service
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function fixHomeworkTable() {
  try {
    console.log('🔧 FIXING HOMEWORK_SUBMISSIONS TABLE');
    console.log('=====================================');
    console.log('');
    
    // Check if table exists
    console.log('1️⃣ Checking if homework_submissions table exists...');
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'homework_submissions'
      );
    `);
    
    if (tableCheck.rows[0].exists) {
      console.log('✅ homework_submissions table already exists');
      console.log('');
      
      // Check table structure
      console.log('2️⃣ Checking table structure...');
      const columns = await pool.query(`
        SELECT column_name, data_type, is_nullable 
        FROM information_schema.columns 
        WHERE table_name = 'homework_submissions'
        ORDER BY ordinal_position;
      `);
      
      console.log('📋 Current table structure:');
      columns.rows.forEach(col => {
        console.log(`   ${col.column_name}: ${col.data_type} ${col.is_nullable === 'NO' ? '(NOT NULL)' : '(NULL)'}`);
      });
      console.log('');
      
    } else {
      console.log('❌ homework_submissions table does NOT exist. Creating it...');
      console.log('');
      
      // Create the table
      console.log('2️⃣ Creating homework_submissions table...');
      await pool.query(`
        CREATE TABLE homework_submissions (
          submission_id SERIAL PRIMARY KEY,
          user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
          problem_id VARCHAR(255) NOT NULL,
          subject VARCHAR(100),
          problem_text TEXT,
          image_filename VARCHAR(255),
          total_steps INTEGER DEFAULT 0,
          completed_steps INTEGER DEFAULT 0,
          skipped_steps INTEGER DEFAULT 0,
          status VARCHAR(50) DEFAULT 'submitted',
          time_spent_seconds INTEGER DEFAULT 0,
          hints_used INTEGER DEFAULT 0,
          submitted_at TIMESTAMP DEFAULT NOW(),
          completed_at TIMESTAMP
        );
      `);
      
      console.log('✅ Table created successfully!');
      console.log('');
      
      // Create indexes
      console.log('3️⃣ Creating indexes...');
      await pool.query(`
        CREATE INDEX IF NOT EXISTS idx_homework_submissions_user_id ON homework_submissions(user_id);
        CREATE INDEX IF NOT EXISTS idx_homework_submissions_problem_id ON homework_submissions(problem_id);
        CREATE INDEX IF NOT EXISTS idx_homework_submissions_submitted_at ON homework_submissions(submitted_at);
        CREATE INDEX IF NOT EXISTS idx_homework_submissions_status ON homework_submissions(status);
      `);
      
      console.log('✅ Indexes created successfully!');
      console.log('');
    }
    
    // Test the table
    console.log('4️⃣ Testing table functionality...');
    const testQuery = await pool.query('SELECT COUNT(*) as count FROM homework_submissions');
    console.log(`✅ Table is working! Current records: ${testQuery.rows[0].count}`);
    console.log('');
    
    console.log('🎉 HOMEWORK_SUBMISSIONS TABLE FIX COMPLETE!');
    console.log('===========================================');
    console.log('');
    console.log('✅ The homework submission tracking should now work properly');
    console.log('✅ No more "relation homework_submissions does not exist" errors');
    console.log('');
    
  } catch (error) {
    console.error('❌ Error fixing homework_submissions table:', error.message);
    console.error('Full error:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

fixHomeworkTable();
