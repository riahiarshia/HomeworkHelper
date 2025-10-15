# Apply Apple Sign-In Database Migration

## ⚠️ Required: Add apple_user_id Column to Azure Database

The Apple Sign-In feature needs a new column in the database. Here's how to add it:

## 🔧 Option 1: Via Azure Portal (Easiest)

1. **Go to**: https://portal.azure.com
2. **Navigate to**: Your PostgreSQL database
3. **Click**: "Query editor" or "Cloud Shell"
4. **Run this SQL**:

```sql
-- Add apple_user_id column
ALTER TABLE users ADD COLUMN IF NOT EXISTS apple_user_id VARCHAR(255);

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_users_apple_user_id ON users(apple_user_id);

-- Verify it was added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' AND column_name = 'apple_user_id';
```

## 🔧 Option 2: Via psql Command Line

If you have the Azure database connection string:

```bash
# Connect to Azure PostgreSQL
psql "postgresql://[your-connection-string]"

# Then run the SQL above
```

## 🔧 Option 3: Via Admin Dashboard (If Available)

If your admin dashboard has a SQL console:

1. Go to your admin dashboard
2. Find the SQL/Database section
3. Run the SQL commands from Option 1

## ✅ Verify Migration

After running, you should see output like:
```
column_name    | data_type
---------------+--------------
apple_user_id  | character varying
```

## 🧪 Test Apple Sign-In

Once the column is added:
1. **Restart** your Azure backend (optional, but recommended)
2. **Open** the iOS app
3. **Tap** "Sign in with Apple"
4. **Should work!** ✅

## 🚨 Current Status

**Without this migration:**
- Apple Sign-In will fail with "Apple authentication failed"
- The backend will crash trying to query a non-existent column

**After migration:**
- Apple Sign-In will work perfectly
- Users can authenticate with Apple ID
- Data is stored correctly

## 📋 What This Column Does

`apple_user_id` stores Apple's unique user identifier, which:
- Is permanent for each user
- Doesn't change even if user changes email
- Allows us to link Apple accounts to our users
- Supports Apple's privacy features (Hide My Email)

