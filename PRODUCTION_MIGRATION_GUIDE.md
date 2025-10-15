# Production Database Migration Guide
## How to Safely Update Production Database Without Data Loss

---

## ⚠️ **Golden Rules**

1. **ALWAYS backup before migration**
2. **ALWAYS test in staging first**
3. **NEVER delete data directly** - use soft deletes
4. **NEVER drop tables** - rename them first as backup
5. **Make changes backwards-compatible** when possible
6. **Have a rollback plan**

---

## 🔄 **Safe Migration Workflow**

```
Local Dev (Test migration)
     ↓
Staging (Test with real-like data)
     ↓
Production (Backup → Migrate → Verify)
```

---

## 📋 **Step-by-Step: Adding a New Feature**

### Example: Adding "premium_tier" field to users table

#### **Step 1: Create Migration File**

```bash
# Create new migration
cd /Users/ar616n/Documents/ios-app/ios-app/backend/migrations
nano 007_add_premium_tier.sql
```

```sql
-- Migration: Add premium tier feature
-- Date: 2025-10-15
-- Safe: YES (adds column with default value)

BEGIN;

-- Add new column (safe - doesn't affect existing data)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS premium_tier VARCHAR(20) DEFAULT 'basic';

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_users_premium_tier 
ON users(premium_tier);

-- Update existing users to have a tier based on subscription status
UPDATE users 
SET premium_tier = 'premium' 
WHERE subscription_status = 'active';

COMMIT;

-- Rollback script (keep this commented)
/*
BEGIN;
ALTER TABLE users DROP COLUMN IF EXISTS premium_tier;
COMMIT;
*/
```

#### **Step 2: Test Locally**

```bash
# Apply to local dev database
cd /Users/ar616n/Documents/ios-app/ios-app/backend

psql -d homework_helper_dev -f migrations/007_add_premium_tier.sql

# Verify
psql -d homework_helper_dev -c "\d users"

# Test your code changes
npm run dev:watch
# Test the feature...
```

#### **Step 3: Deploy and Test in Staging**

```bash
# Deploy code to staging
./deploy-staging.sh

# IMPORTANT: Backup staging database first
./backup-database.sh staging

# Apply migration to staging database
./apply-migration-staging.sh migrations/007_add_premium_tier.sql

# Verify staging
curl https://homework-helper-staging.azurewebsites.net/api/health/detailed

# Test thoroughly for 1-2 days!
```

#### **Step 4: Production Deployment (The Safe Way)**

```bash
# 1. BACKUP PRODUCTION (Critical!)
./backup-database.sh production

# 2. Apply migration during low-traffic time
./apply-migration-production.sh migrations/007_add_premium_tier.sql

# 3. Verify migration
./verify-migration-production.sh

# 4. Deploy new code
./deploy-production.sh

# 5. Monitor for issues
./monitor-production.sh
```

---

## 🛡️ **Migration Safety Patterns**

### ✅ **SAFE Operations (No Data Loss)**

```sql
-- Add column with default
ALTER TABLE users ADD COLUMN IF NOT EXISTS new_field VARCHAR(50) DEFAULT 'value';

-- Add index
CREATE INDEX IF NOT EXISTS idx_name ON table(column);

-- Add table
CREATE TABLE IF NOT EXISTS new_table (...);

-- Add constraint (non-breaking)
ALTER TABLE users ADD CONSTRAINT check_email CHECK (email LIKE '%@%');

-- Rename column (with careful code coordination)
ALTER TABLE users RENAME COLUMN old_name TO new_name;
```

### ⚠️ **CAREFUL Operations (Need Planning)**

```sql
-- Change column type (ensure data fits)
ALTER TABLE users ALTER COLUMN age TYPE INTEGER USING age::INTEGER;

-- Add NOT NULL constraint (ensure no nulls first)
UPDATE users SET email = 'unknown@example.com' WHERE email IS NULL;
ALTER TABLE users ALTER COLUMN email SET NOT NULL;

-- Change default value (doesn't affect existing rows)
ALTER TABLE users ALTER COLUMN status SET DEFAULT 'active';
```

### ❌ **DANGEROUS Operations (HIGH RISK!)**

```sql
-- DON'T DO THIS IN PRODUCTION:
DROP TABLE users;                    -- ❌ Deletes all data!
DROP COLUMN sensitive_data;          -- ❌ Data loss!
TRUNCATE TABLE users;                -- ❌ Empties table!
DELETE FROM users WHERE ...;         -- ❌ Use soft delete instead

-- Instead, use safe alternatives:
ALTER TABLE users RENAME TO users_backup;  -- ✅ Keeps data
ALTER TABLE users RENAME COLUMN old TO old_deprecated;  -- ✅ Keeps data
UPDATE users SET deleted_at = NOW() WHERE ...;  -- ✅ Soft delete
```

---

## 💾 **Backup Strategy**

### **Before Every Production Migration:**

```bash
# 1. Full database backup
pg_dump "postgresql://..." -Fc -f backup_$(date +%Y%m%d_%H%M%S).dump

# 2. Table-specific backup (if modifying specific table)
pg_dump "postgresql://..." -t users -f users_backup_$(date +%Y%m%d_%H%M%S).sql

# 3. Store backup in safe location (Azure Blob Storage)
az storage blob upload \
  --account-name yourstorageaccount \
  --container-name database-backups \
  --file backup_*.dump
```

---

## 🔄 **Rollback Strategy**

### **If Migration Fails:**

```bash
# Option 1: Restore from backup
pg_restore -d homework_helper "backup_20251015_120000.dump"

# Option 2: Run rollback script
psql -d homework_helper -f migrations/007_add_premium_tier_rollback.sql

# Option 3: Manual rollback (if you have the commands)
psql -d homework_helper -c "ALTER TABLE users DROP COLUMN premium_tier;"
```

---

## 🎯 **Production Migration Checklist**

Before running migration in production:

- [ ] Migration tested locally ✅
- [ ] Migration tested in staging ✅
- [ ] Staging tests passed (24+ hours) ✅
- [ ] Production database backed up ✅
- [ ] Backup verified (can restore) ✅
- [ ] Rollback script prepared ✅
- [ ] Migration scheduled during low traffic ✅
- [ ] Team notified ✅
- [ ] Monitoring ready ✅
- [ ] Code is backwards-compatible ✅

---

## 🔧 **Advanced: Zero-Downtime Migrations**

For critical changes that can't have downtime:

### **Phase 1: Add new column (backwards compatible)**
```sql
-- Week 1: Add column
ALTER TABLE users ADD COLUMN new_email VARCHAR(255);
-- Deploy code that writes to BOTH old and new columns
```

### **Phase 2: Migrate data**
```sql
-- Week 2: Copy data in batches
UPDATE users SET new_email = email WHERE new_email IS NULL LIMIT 1000;
-- Repeat until all migrated
```

### **Phase 3: Switch over**
```sql
-- Week 3: Make new column primary
ALTER TABLE users ALTER COLUMN new_email SET NOT NULL;
CREATE INDEX idx_users_new_email ON users(new_email);
-- Deploy code that uses new column
```

### **Phase 4: Cleanup (optional)**
```sql
-- Week 4: Remove old column
ALTER TABLE users DROP COLUMN email;
-- Or keep it for historical purposes
```

---

## 📊 **Example: Real Production Migration**

### **Scenario:** Add "teacher_mode" feature to existing users

```sql
-- migrations/008_add_teacher_mode.sql

BEGIN;

-- 1. Add new columns (safe)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS is_teacher BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS teacher_verified_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS school_name VARCHAR(255);

-- 2. Add index
CREATE INDEX IF NOT EXISTS idx_users_is_teacher ON users(is_teacher);

-- 3. Create new table for teacher profiles
CREATE TABLE IF NOT EXISTS teacher_profiles (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) REFERENCES users(user_id) ON DELETE CASCADE,
    school_district VARCHAR(255),
    subjects TEXT[],
    grade_levels TEXT[],
    verification_document_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 4. Log this migration
INSERT INTO migration_log (migration_name, applied_at) 
VALUES ('008_add_teacher_mode', NOW());

COMMIT;
```

**Deployment:**
1. Backup production ✅
2. Apply migration during 2am (low traffic) ✅
3. Deploy new code ✅
4. Monitor for 24 hours ✅
5. Announce feature to users ✅

---

## 🚨 **Emergency Rollback Procedure**

If something goes wrong:

```bash
# 1. STOP - Don't panic!
# 2. Assess the situation
curl https://your-app.com/api/health/detailed

# 3. If critical, rollback immediately
./emergency-rollback.sh

# 4. Restore from backup if needed
./restore-database.sh production backup_20251015_120000.dump

# 5. Roll back code deployment
az webapp deployment slot swap --name homework-helper-api --slot production --target-slot previous

# 6. Verify system is working
# 7. Debug the issue offline
# 8. Plan retry
```

---

## 📝 **Migration Log Table**

Keep track of what's been applied:

```sql
-- Create migration tracking table
CREATE TABLE IF NOT EXISTS migration_log (
    id SERIAL PRIMARY KEY,
    migration_name VARCHAR(255) UNIQUE NOT NULL,
    applied_at TIMESTAMP DEFAULT NOW(),
    applied_by VARCHAR(255),
    rollback_script TEXT,
    notes TEXT
);

-- Check what migrations have been applied
SELECT * FROM migration_log ORDER BY applied_at DESC;
```

---

## ✅ **Summary: Safe Migration Checklist**

```
☑️ Write migration with IF NOT EXISTS / IF EXISTS
☑️ Test locally first
☑️ Deploy to staging
☑️ Test staging thoroughly (24+ hours)
☑️ Backup production database
☑️ Verify backup works
☑️ Schedule migration during low traffic
☑️ Apply migration
☑️ Verify migration succeeded
☑️ Deploy matching code
☑️ Monitor for issues
☑️ Keep backup for 30 days
```

**Remember:** It's better to spend 30 minutes planning than 3 hours recovering from data loss! 🛡️

