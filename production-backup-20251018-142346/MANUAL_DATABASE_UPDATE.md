# Manual Database Update for Apple Sign-In

Since Azure deployment is taking time, here's how to update the database manually:

## 🚀 Quick Method: Via Admin Dashboard

1. **Go to**: https://homework-helper-api.azurewebsites.net/admin/
2. **If there's a database/SQL section**, run this:

```sql
-- First, backup: List current columns
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users';

-- Then add the column
ALTER TABLE users ADD COLUMN IF NOT EXISTS apple_user_id VARCHAR(255);

-- Add index
CREATE INDEX IF NOT EXISTS idx_users_apple_user_id ON users(apple_user_id);

-- Verify
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' AND column_name = 'apple_user_id';
```

## 📊 Alternative: Azure Portal

1. **Go to**: https://portal.azure.com
2. **Find**: Your PostgreSQL database
3. **Click**: "Query editor" (or similar)
4. **Run the SQL above**

## ✅ Verify It Worked

Run this to check:
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name = 'apple_user_id';
```

You should see:
```
column_name    | data_type
---------------+--------------
apple_user_id  | character varying
```

## 🧪 Test Apple Sign-In

Once the column is added:
1. Open the iOS app
2. Tap "Sign in with Apple"
3. Should work now! ✅

## 🔄 Automated Method (When Azure Deploys)

Once the new backend deploys (in a few minutes), you can use:

```bash
# Backup database structure
curl -X POST "https://homework-helper-api.azurewebsites.net/api/database/backup"

# Apply migration
curl -X POST "https://homework-helper-api.azurewebsites.net/api/database/migrate-apple"

# Check status
curl "https://homework-helper-api.azurewebsites.net/api/database/status"
```

## ⚠️ Note

The database update is **safe and reversible**:
- We're only **adding** a column, not modifying existing data
- The column is nullable, so existing users won't be affected
- If needed, you can remove it with: `ALTER TABLE users DROP COLUMN apple_user_id;`

