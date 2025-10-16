# Staging Admin Portal Fix

## Problem
The staging admin portal at `https://homework-helper-staging.azurewebsites.net/admin/` is not accessible due to database connection issues.

## Root Cause
The `DATABASE_URL` environment variable is not configured in the Azure staging environment, preventing the backend from connecting to the database.

## Solution

### Option 1: Automatic Fix (Recommended)

1. **Set Environment Variables in Azure Portal:**
   - Go to Azure Portal → App Services → `homework-helper-staging`
   - Navigate to Configuration → Application settings
   - Add the following environment variables:
     ```
     DATABASE_URL=postgresql://username:password@host:port/database
     NODE_ENV=staging
     JWT_SECRET=your-secure-jwt-secret
     ADMIN_JWT_SECRET=your-secure-admin-jwt-secret
     LEDGER_SALT=your-secure-salt
     ```

2. **Run the Fix Script:**
   ```bash
   # In the backend directory
   chmod +x deploy-staging-admin-fix.sh
   ./deploy-staging-admin-fix.sh
   ```

### Option 2: Manual Fix via Azure Kudu Console

1. **Access Kudu Console:**
   - Go to `https://homework-helper-staging.scm.azurewebsites.net`
   - Navigate to Debug Console → CMD

2. **Run the Fix Script:**
   ```bash
   cd site/wwwroot
   node fix-staging-admin-portal.js
   ```

### Option 3: Manual Database Setup

If you have direct database access, run this SQL:

```sql
-- Create admin_users table if it doesn't exist
CREATE TABLE IF NOT EXISTS admin_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP,
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insert admin user (password: Admin123!Staging)
INSERT INTO admin_users (username, email, password_hash, role, is_active)
VALUES ('admin', 'admin@homeworkhelper-staging.com', 
        'a1b2c3d4e5f6789...', 'super_admin', true)
ON CONFLICT (username) DO UPDATE SET
    email = EXCLUDED.email,
    password_hash = EXCLUDED.password_hash,
    is_active = EXCLUDED.is_active;
```

## Expected Results

After running the fix, you should be able to access:

- **URL**: `https://homework-helper-staging.azurewebsites.net/admin/`
- **Username**: `admin`
- **Password**: `Admin123!Staging`

## Verification Steps

1. **Test Database Connection:**
   ```bash
   node diagnose-database.js
   ```

2. **Test Admin Portal:**
   - Go to the admin portal URL
   - Login with the provided credentials
   - Verify you can see the dashboard
   - Test user management functions

3. **Check Logs:**
   - Monitor Azure App Service logs for any errors
   - Verify database queries are executing successfully

## Troubleshooting

### Common Issues

1. **DATABASE_URL Not Set:**
   - Error: "DATABASE_URL environment variable is not set"
   - Solution: Configure DATABASE_URL in Azure Portal

2. **Database Connection Failed:**
   - Error: "Database connection failed"
   - Solution: Verify database server is accessible and credentials are correct

3. **Admin Table Missing:**
   - Error: "admin_users table does not exist"
   - Solution: The fix script will create the table automatically

4. **Permission Denied:**
   - Error: "Permission denied" when running scripts
   - Solution: Ensure the script has execute permissions

### Debug Commands

```bash
# Check environment variables
node -e "console.log('DATABASE_URL:', process.env.DATABASE_URL ? 'SET' : 'NOT SET')"

# Test database connection
node diagnose-database.js

# Run admin fix
node fix-staging-admin-portal.js
```

## Files Modified

- `backend/fix-staging-admin-portal.js` - Main fix script
- `backend/deploy-staging-admin-fix.sh` - Deployment script
- `backend/diagnose-database.js` - Database diagnostic tool

## Security Notes

- The staging admin password is: `Admin123!Staging`
- This is a staging environment password and should be changed for production
- The admin user has `super_admin` role with full access
- All admin actions are logged in the audit trail

## Support

If you continue to have issues:

1. Check Azure App Service logs
2. Verify database connectivity
3. Ensure all environment variables are set
4. Run the diagnostic script for detailed error information
