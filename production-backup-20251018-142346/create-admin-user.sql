-- Create admin user for testing
INSERT INTO admin_users (username, email, password_hash, is_active, created_at)
VALUES ('admin', 'admin@homeworkhelper.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', true, NOW())
ON CONFLICT (username) DO UPDATE SET
    email = EXCLUDED.email,
    password_hash = EXCLUDED.password_hash,
    is_active = EXCLUDED.is_active;
