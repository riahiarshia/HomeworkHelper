-- Migration: Add homework submission tracking
-- Description: Track total homework submissions per user for analytics
-- Created: 2025-10-11

-- Add homework submission counter to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS total_homework_submissions INTEGER DEFAULT 0;

-- Create homework_submissions table for detailed tracking
CREATE TABLE IF NOT EXISTS homework_submissions (
    submission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    problem_id VARCHAR(255),
    subject VARCHAR(100),
    problem_text TEXT,
    image_filename VARCHAR(255),
    total_steps INTEGER DEFAULT 0,
    completed_steps INTEGER DEFAULT 0,
    skipped_steps INTEGER DEFAULT 0,
    status VARCHAR(50),
    submitted_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    time_spent_seconds INTEGER,
    hints_used INTEGER DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_homework_submissions_user_id ON homework_submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_homework_submissions_submitted_at ON homework_submissions(submitted_at);
CREATE INDEX IF NOT EXISTS idx_homework_submissions_status ON homework_submissions(status);

-- Add comment for documentation
COMMENT ON TABLE homework_submissions IS 'Tracks all homework submissions for analytics, persists even if user deletes from app';
COMMENT ON COLUMN users.total_homework_submissions IS 'Running counter of total homework submissions, never decrements';

