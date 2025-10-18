#!/bin/bash

# Apply homework_submissions table migration to production database
# This fixes the missing table error after backend restore

echo "🔧 Applying homework_submissions table migration to production..."

# Set production database URL
export DATABASE_URL="postgresql://homework_helper_user:$(az keyvault secret show --vault-name OpenAI-1 --name DATABASE-PASSWORD --query 'value' -o tsv)@homework-helper-db.postgres.database.azure.com:5432/homework_helper"

# Create the homework_submissions table
echo "📊 Creating homework_submissions table..."
psql "$DATABASE_URL" -c "
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

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_homework_submissions_user_id ON homework_submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_homework_submissions_problem_id ON homework_submissions(problem_id);
CREATE INDEX IF NOT EXISTS idx_homework_submissions_submitted_at ON homework_submissions(submitted_at);
CREATE INDEX IF NOT EXISTS idx_homework_submissions_status ON homework_submissions(status);
"

if [ $? -eq 0 ]; then
    echo "✅ homework_submissions table created successfully!"
    echo "🔍 Verifying table exists..."
    psql "$DATABASE_URL" -c "SELECT table_name FROM information_schema.tables WHERE table_name = 'homework_submissions';"
else
    echo "❌ Failed to create homework_submissions table"
    exit 1
fi

echo "🎉 Migration completed successfully!"
