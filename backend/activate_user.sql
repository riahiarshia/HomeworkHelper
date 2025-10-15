-- Activate user riahiarshia@gmail.com
-- Run this in your Azure PostgreSQL database

UPDATE users 
SET is_active = true, 
    is_banned = false,
    banned_reason = NULL,
    updated_at = NOW()
WHERE email = 'riahiarshia@gmail.com';

-- Verify the update
SELECT 
    email,
    is_active,
    is_banned,
    subscription_status,
    last_active_at
FROM users 
WHERE email = 'riahiarshia@gmail.com';

