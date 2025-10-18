#!/bin/bash

# Quick Database Fix Script for Azure SSH
# Run this directly in Azure App Service SSH

echo "🔧 QUICK DATABASE FIX"
echo "===================="
echo ""

# Navigate to app directory
cd /home/site/wwwroot

echo "📝 Creating database fix script..."
cat > fix-db.js << 'EOF'
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function fixDB() {
  try {
    console.log('🔧 FIXING DATABASE ISSUES...');
    
    // Fix 1: Create homework_submissions table
    console.log('1️⃣ Creating homework_submissions table...');
    await pool.query(`
      CREATE TABLE IF NOT EXISTS homework_submissions (
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
    
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_homework_submissions_user_id ON homework_submissions(user_id);
      CREATE INDEX IF NOT EXISTS idx_homework_submissions_problem_id ON homework_submissions(problem_id);
      CREATE INDEX IF NOT EXISTS idx_homework_submissions_submitted_at ON homework_submissions(submitted_at);
      CREATE INDEX IF NOT EXISTS idx_homework_submissions_status ON homework_submissions(status);
    `);
    console.log('✅ homework_submissions table created!');
    
    // Fix 2: Add grade column
    console.log('2️⃣ Adding grade column to users table...');
    await pool.query(`
      ALTER TABLE users 
      ADD COLUMN IF NOT EXISTS grade VARCHAR(50) DEFAULT '4th grade';
    `);
    console.log('✅ grade column added!');
    
    console.log('🎉 ALL FIXES COMPLETE!');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

fixDB();
EOF

echo "🚀 Running database fixes..."
node fix-db.js

echo ""
echo "🧹 Cleaning up..."
rm -f fix-db.js

echo "✅ Database fixes completed!"
