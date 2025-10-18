#!/usr/bin/env node

const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function fixAllDatabaseIssues() {
  try {
    console.log('🔧 FIXING ALL DATABASE ISSUES');
    console.log('==============================');
    console.log('');
    
    // Issue 1: Create homework_submissions table
    console.log('1️⃣ Fixing homework_submissions table...');
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'homework_submissions'
      );
    `);
    
    if (!tableCheck.rows[0].exists) {
      console.log('❌ Creating homework_submissions table...');
      
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
      
      // Create indexes
      await pool.query(`
        CREATE INDEX IF NOT EXISTS idx_homework_submissions_user_id ON homework_submissions(user_id);
        CREATE INDEX IF NOT EXISTS idx_homework_submissions_problem_id ON homework_submissions(problem_id);
        CREATE INDEX IF NOT EXISTS idx_homework_submissions_submitted_at ON homework_submissions(submitted_at);
        CREATE INDEX IF NOT EXISTS idx_homework_submissions_status ON homework_submissions(status);
      `);
      
      console.log('✅ homework_submissions table created successfully!');
    } else {
      console.log('✅ homework_submissions table already exists');
    }
    
    console.log('');
    
    // Issue 2: Add grade column to users table
    console.log('2️⃣ Fixing grade column in users table...');
    const gradeColumnCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'users' AND column_name = 'grade'
      );
    `);
    
    if (!gradeColumnCheck.rows[0].exists) {
      console.log('❌ Adding grade column to users table...');
      
      await pool.query(`
        ALTER TABLE users 
        ADD COLUMN grade VARCHAR(50) DEFAULT '4th grade';
      `);
      
      console.log('✅ grade column added to users table successfully!');
    } else {
      console.log('✅ grade column already exists in users table');
    }
    
    console.log('');
    
    // Test both fixes
    console.log('3️⃣ Testing database fixes...');
    
    // Test homework_submissions table
    const homeworkTest = await pool.query('SELECT COUNT(*) as count FROM homework_submissions');
    console.log(`✅ homework_submissions table working! Records: ${homeworkTest.rows[0].count}`);
    
    // Test grade column
    const gradeTest = await pool.query('SELECT COUNT(*) as count FROM users WHERE grade IS NOT NULL');
    console.log(`✅ grade column working! Users with grade: ${gradeTest.rows[0].count}`);
    
    console.log('');
    console.log('🎉 ALL DATABASE ISSUES FIXED SUCCESSFULLY!');
    console.log('==========================================');
    console.log('');
    console.log('✅ homework_submissions table: Created');
    console.log('✅ grade column: Added to users table');
    console.log('');
    console.log('🚀 Your app should now work without database errors!');
    
  } catch (error) {
    console.error('❌ Error fixing database issues:', error.message);
    console.error('Full error:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

fixAllDatabaseIssues();
