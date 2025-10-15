# Database Migration - Quick Reference

## 🚦 **Safe Migration Process**

```
┌─────────────────────────────────────────────────────────┐
│ 1. CREATE MIGRATION                                     │
│    cd backend/migrations                                │
│    nano 007_add_new_feature.sql                         │
│    (Use safe SQL patterns)                              │
└─────────────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────┐
│ 2. TEST LOCALLY                                         │
│    psql -d homework_helper_dev -f migrations/007_...    │
│    npm run dev:watch                                    │
│    (Test the feature)                                   │
└─────────────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────┐
│ 3. DEPLOY TO STAGING                                    │
│    ./backup-database.sh staging                         │
│    ./apply-migration-staging.sh migrations/007_...      │
│    ./deploy-staging.sh                                  │
│    (Test for 24+ hours)                                 │
└─────────────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────┐
│ 4. PRODUCTION (AUTO-BACKUP)                             │
│    ./apply-migration-production.sh migrations/007_...   │
│    # This script automatically:                         │
│    #  - Creates backup                                  │
│    #  - Tests migration (dry run)                       │
│    #  - Applies to production                           │
│    #  - Logs migration                                  │
│    ./deploy-production.sh                               │
└─────────────────────────────────────────────────────────┘
```

---

## 📝 **Safe SQL Patterns**

### ✅ **Always Use:**
```sql
CREATE TABLE IF NOT EXISTS ...
ALTER TABLE ... ADD COLUMN IF NOT EXISTS ...
CREATE INDEX IF NOT EXISTS ...
DROP TABLE IF EXISTS old_table;  -- Only if truly obsolete
```

### ❌ **Never Use (without backup):**
```sql
DROP TABLE users;           -- ❌ Data loss!
DROP COLUMN important;      -- ❌ Data loss!
TRUNCATE users;             -- ❌ Empties table!
DELETE FROM users;          -- ❌ Use soft delete
```

---

## 🛡️ **Safety Scripts**

| Script | Purpose | Safety Level |
|--------|---------|--------------|
| `backup-database.sh` | Create backup | ⭐⭐⭐ Essential |
| `restore-database.sh` | Restore from backup | ⭐⭐⭐ Emergency |
| `apply-migration-staging.sh` | Apply to staging | ⭐⭐ Safe testing |
| `apply-migration-production.sh` | Apply to production | ⭐⭐⭐ Auto-backup |

---

## 🔄 **Common Scenarios**

### **Adding a Column**
```sql
-- Safe: Add with default value
ALTER TABLE users ADD COLUMN premium_tier VARCHAR(20) DEFAULT 'basic';
```

### **Removing a Column (Safe Way)**
```sql
-- Step 1: Rename (keeps data)
ALTER TABLE users RENAME COLUMN old_column TO old_column_deprecated;

-- Step 2: Update code to not use it

-- Step 3 (later): Actually drop it
-- ALTER TABLE users DROP COLUMN old_column_deprecated;
```

### **Changing Data Type**
```sql
-- Safe: With USING clause
ALTER TABLE users 
ALTER COLUMN age TYPE INTEGER 
USING age::INTEGER;
```

### **Adding NOT NULL**
```sql
-- Step 1: Fill nulls first
UPDATE users SET email = 'unknown@example.com' WHERE email IS NULL;

-- Step 2: Add constraint
ALTER TABLE users ALTER COLUMN email SET NOT NULL;
```

---

## 🚨 **Emergency Rollback**

```bash
# If migration fails or causes issues:

# 1. Find your backup
ls -lt backups/production/

# 2. Restore immediately
./restore-database.sh production backups/production/pre_migration_20251015_120000.dump

# 3. Verify restoration
curl https://your-app.com/api/health/detailed

# 4. Roll back code if needed
git revert HEAD
./deploy-production.sh
```

---

## 📊 **Example: Complete Migration**

**Scenario:** Add "teacher mode" feature

### **1. Create Migration**
```bash
cd backend/migrations
cat > 008_add_teacher_mode.sql << 'SQL'
BEGIN;

ALTER TABLE users ADD COLUMN IF NOT EXISTS is_teacher BOOLEAN DEFAULT false;
CREATE INDEX IF NOT EXISTS idx_users_is_teacher ON users(is_teacher);

CREATE TABLE IF NOT EXISTS teacher_profiles (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) REFERENCES users(user_id),
    school_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

COMMIT;
SQL
```

### **2. Test Locally**
```bash
psql -d homework_helper_dev -f migrations/008_add_teacher_mode.sql
npm run dev:watch
# Test feature...
git add migrations/008_add_teacher_mode.sql
git commit -m "Add teacher mode database migration"
```

### **3. Deploy to Staging**
```bash
git push origin develop
./backup-database.sh staging
./apply-migration-staging.sh migrations/008_add_teacher_mode.sql
./deploy-staging.sh

# Test for 24-48 hours
```

### **4. Deploy to Production**
```bash
git checkout main
git merge develop
./apply-migration-production.sh migrations/008_add_teacher_mode.sql
# Script asks for confirmation multiple times
# Script creates automatic backup
./deploy-production.sh
```

---

## ✅ **Pre-Production Checklist**

Before running production migration:

```
☐ Tested locally
☐ Tested in staging for 24+ hours
☐ No DROP/TRUNCATE/DELETE commands
☐ Uses IF EXISTS / IF NOT EXISTS
☐ Has BEGIN/COMMIT transaction
☐ Scheduled during low-traffic time (2-4am)
☐ Team notified
☐ Monitoring ready
☐ Rollback plan prepared
```

---

## 💡 **Pro Tips**

1. **Schedule during low traffic** (2-4am typically)
2. **Keep backups for 30 days** minimum
3. **Test rollback procedure** in staging
4. **Monitor after migration** for 24 hours
5. **Document each migration** with comments
6. **Use transactions** (BEGIN/COMMIT)
7. **Make changes backwards-compatible** when possible

---

## 📞 **If Something Goes Wrong**

```bash
# STOP - Don't panic!
# 1. Check what happened
./pre-deploy-check.sh production

# 2. If critical, restore immediately
./restore-database.sh production [backup_file]

# 3. Verify restoration worked
curl https://your-app.com/api/health/detailed

# 4. Debug offline, plan retry
```

---

**Remember:** Better 30 minutes of preparation than 3 hours of recovery! 🛡️

