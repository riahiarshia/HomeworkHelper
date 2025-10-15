-- ============================================
-- UPDATE ADMIN CREDENTIALS
-- ============================================
-- 
-- New Credentials:
--   Email: support_homework@arshia.com
--   Password: A@dMin%f$7
--   Username: admin
--
-- Run this SQL in Azure Portal → PostgreSQL → Query Editor
-- ============================================

-- Update the admin user credentials
UPDATE admin_users 
SET 
  email = 'support_homework@arshia.com',
  password_hash = '$2b$10$axkGOxhejBkQHEl3ZBjxwuAzDvfVJc6d743luWah0Txh67UhsKLs.'
WHERE username = 'admin';

-- Verify the update
SELECT 
  id, 
  username, 
  email, 
  role, 
  is_active, 
  created_at,
  last_login
FROM admin_users 
WHERE username = 'admin';



