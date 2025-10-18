# Entitlements Ledger Implementation - Complete ✅

## Overview

Minimal, additive implementation of a de-identified transaction ledger for fraud prevention and accounting compliance (Apple 5.1.1(v)). **Zero breaking changes** - all modifications are purely additive.

---

## 🎯 What Was Implemented

### 1. Database Schema (Additive Only)

**New Tables** (No existing tables modified):

- `entitlements_ledger` - PII-free ledger that persists after account deletion
- `user_entitlements` - User-linked entitlements (deleted with account)

**Migration**: `backend/migrations/008_add_entitlements_ledger.sql`

### 2. Core Services (New Files)

- `backend/lib/txidHash.js` - Transaction ID hashing utility (SHA-256)
- `backend/services/entitlementsLedgerService.js` - Ledger management service

### 3. Integration Points (Minimal Hooks)

#### a) Environment Validation
**File**: `backend/server.js`
**Change**: Added validation for `LEDGER_SALT` env var (non-breaking)

#### b) Receipt Validation Hook
**File**: `backend/routes/subscription.js`
**Change**: Added 3 imports + upsert calls after existing trial tracking logic
**Lines**: Added ~60 lines in existing `/apple/validate-receipt` endpoint
**Impact**: None - all wrapped in try/catch, failures don't break validation

#### c) Account Deletion Hook
**File**: `backend/routes/auth.js`
**Change**: Added 1 import + mirror logic before deletion
**Lines**: Added ~40 lines in existing `/delete-account` endpoint
**Impact**: None - all wrapped in try/catch, failures don't break deletion

### 4. Documentation

- `backend/docs/deletion-and-ledger.md` - Complete privacy & legal documentation
- `backend/env-example.txt` - Added LEDGER_SALT and RETENTION_MONTHS variables

### 5. Tests

- `backend/tests/entitlementsLedger.test.js` - Unit tests for ledger service

---

## 📊 Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Receipt Validation Flow                       │
└─────────────────────────────────────────────────────────────────┘

Apple Receipt
    ↓
[Existing Validation Logic]  ← No changes
    ↓
[Update users table]  ← No changes
    ↓
[Update trial_usage_history]  ← No changes
    ↓
[NEW] Upsert user_entitlements  ← Additive (user-linked)
    ↓
[NEW] Upsert entitlements_ledger  ← Additive (de-identified)
    ↓
[Continue existing flow]  ← No changes


┌─────────────────────────────────────────────────────────────────┐
│                    Account Deletion Flow                         │
└─────────────────────────────────────────────────────────────────┘

Delete Account Request
    ↓
[Verify user exists]  ← No changes
    ↓
[NEW] Query user_entitlements  ← Additive
    ↓
[NEW] Mirror to entitlements_ledger  ← Additive (de-identifies)
    ↓
[Delete user_entitlements]  ← Additive (new table)
    ↓
[Delete subscription_history]  ← No changes
    ↓
[Delete other user data]  ← No changes
    ↓
[Delete user]  ← No changes
```

---

## 🔐 Privacy & Compliance

### What Gets Deleted on Account Deletion

- ✅ User profile (name, email, username)
- ✅ `user_entitlements` (plain transaction IDs, user links)
- ✅ Subscription history
- ✅ All personally identifiable information (PII)

### What Persists (De-Identified)

- `entitlements_ledger` table only:
  - Hashed transaction ID (SHA-256, salted)
  - Product ID
  - Subscription group ID
  - Trial flag (boolean)
  - Status
  - Timestamps

**No PII**: No user_id, email, name, or reversible identifiers

### Legal Basis

- **GDPR**: Legitimate Interest (Article 6(1)(f)) - Fraud prevention
- **CCPA**: Business Purpose Exception - Detecting fraud, security incidents
- **Apple**: Compliance with App Store Guidelines 5.1.1(v)

---

## 🚀 Deployment Checklist

### Step 1: Generate LEDGER_SALT

```bash
# Run this ONCE to generate a secure salt
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Save the output as `LEDGER_SALT` environment variable (never commit to git!).

### Step 2: Set Environment Variables

#### Development (.env)
```bash
DATABASE_URL=postgresql://...
LEDGER_SALT=<generated-salt-from-step-1>
RETENTION_MONTHS_ENTITLEMENTS_LEDGER=24  # Optional, defaults to 24
```

#### Production (Azure App Service)
```bash
# Set via Azure Portal or CLI
az webapp config appsettings set \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api \
  --settings LEDGER_SALT="<your-salt-here>"
```

### Step 3: Apply Database Migration

```bash
# Local/Development
psql $DATABASE_URL < backend/migrations/008_add_entitlements_ledger.sql

# Production (via Azure Portal)
# 1. Go to Azure Portal → PostgreSQL
# 2. Open Query Editor
# 3. Paste contents of 008_add_entitlements_ledger.sql
# 4. Execute
```

**Or use the provided script**:
```bash
cd backend
node apply-migration-008.js  # TODO: Create this helper script
```

### Step 4: Deploy Backend

```bash
cd backend
zip -r backend-ledger.zip . -x "node_modules/*" -x ".git/*"
az webapp deployment source config-zip \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api \
  --src backend-ledger.zip
```

### Step 5: Verify Deployment

```bash
# Check logs
az webapp log tail --name homework-helper-api --resource-group homework-helper-rg-f

# Look for:
# - "✅ Environment variables validated"
# - No errors about LEDGER_SALT

# Test receipt validation (watch logs for ledger upserts)
# Test account deletion (watch logs for ledger mirroring)
```

---

## 🧪 Testing

### Unit Tests

```bash
cd backend
npm test tests/entitlementsLedger.test.js
```

### Integration Tests

1. **Receipt Validation Test**:
   ```bash
   # Purchase subscription in app
   # Check logs: Should see "📊 Ledger record upserted"
   # Query database:
   SELECT * FROM user_entitlements WHERE user_id = '<test-user-id>';
   SELECT * FROM entitlements_ledger ORDER BY last_seen_at DESC LIMIT 5;
   ```

2. **Account Deletion Test**:
   ```bash
   # Delete account via app
   # Check logs: Should see "📊 Mirroring X entitlement(s) to ledger"
   # Query database:
   SELECT * FROM users WHERE user_id = '<test-user-id>';  -- Empty
   SELECT * FROM user_entitlements WHERE user_id = '<test-user-id>';  -- Empty
   SELECT * FROM entitlements_ledger ORDER BY last_seen_at DESC LIMIT 5;  -- Has record
   ```

3. **Hash Stability Test**:
   ```javascript
   const { txidHash } = require('./lib/txidHash');
   const salt = process.env.LEDGER_SALT;
   
   const hash1 = txidHash('1000000000000001', salt);
   const hash2 = txidHash('1000000000000001', salt);
   
   console.assert(hash1 === hash2, 'Hashes should be stable');
   console.log('✅ Hash stability test passed');
   ```

---

## 📝 Code Changes Summary

### Files Created (New)
- `backend/migrations/008_add_entitlements_ledger.sql` (285 lines)
- `backend/lib/txidHash.js` (32 lines)
- `backend/services/entitlementsLedgerService.js` (217 lines)
- `backend/docs/deletion-and-ledger.md` (459 lines)
- `backend/tests/entitlementsLedger.test.js` (306 lines)

### Files Modified (Minimal, Additive)
- `backend/server.js` (+14 lines) - Env validation
- `backend/routes/subscription.js` (+62 lines) - Receipt hook
- `backend/routes/auth.js` (+40 lines) - Deletion hook
- `backend/env-example.txt` (+8 lines) - Env docs

**Total**: ~1,423 new lines, ~124 modified lines (all additive)

### Files Not Modified
- All existing routes (except 3 small hooks)
- All existing services (completely untouched)
- All existing models/schemas
- All existing tests (no changes, new tests added separately)
- Package.json (no new dependencies)

---

## 🔄 Maintenance

### Scheduled Pruning Job (Optional)

To automatically prune old ledger records:

```javascript
// In your scheduler (cron, node-schedule, etc.)
const { pruneLedger } = require('./services/entitlementsLedgerService');

// Run daily at 2 AM
cron.schedule('0 2 * * *', async () => {
    try {
        const retentionMonths = Number(process.env.RETENTION_MONTHS_ENTITLEMENTS_LEDGER || 24);
        const pruned = await pruneLedger(retentionMonths);
        console.log(`✅ Pruned ${pruned} old ledger records (>${retentionMonths} months)`);
    } catch (error) {
        console.error('❌ Ledger pruning failed:', error);
    }
});
```

### Manual Pruning

```sql
-- View old records
SELECT COUNT(*), MIN(last_seen_at), MAX(last_seen_at) 
FROM entitlements_ledger 
WHERE last_seen_at < NOW() - INTERVAL '24 months';

-- Delete records older than 24 months
DELETE FROM entitlements_ledger 
WHERE last_seen_at < NOW() - INTERVAL '24 months';
```

---

## 🐛 Troubleshooting

### Issue: "Missing required environment variable: LEDGER_SALT"

**Solution**: Generate and set LEDGER_SALT
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
# Add to .env: LEDGER_SALT=<generated-value>
```

### Issue: Migration fails with "table already exists"

**Solution**: Migration is idempotent, safe to re-run
```sql
-- Check if tables exist
\dt entitlements_ledger
\dt user_entitlements

-- If they exist, the migration already ran (OK to skip)
```

### Issue: Ledger upserts failing but receipts validating

**Solution**: This is expected behavior (fail-safe design)
- Check logs for specific error
- Ledger failures don't break receipt validation (wrapped in try/catch)
- Common causes: Missing LEDGER_SALT, database connection issue

### Issue: User complains ledger record still exists after deletion

**Response**: 
1. Confirm PII was deleted (query users/user_entitlements tables)
2. Explain ledger contains no PII (only hashed ID + metadata)
3. Point to privacy policy section on de-identified retention
4. If they insist, manually delete the record (requires hash lookup)

---

## 📊 Metrics & Monitoring

### Key Metrics to Track

```sql
-- Total ledger records
SELECT COUNT(*) FROM entitlements_ledger;

-- Records by status
SELECT status, COUNT(*) 
FROM entitlements_ledger 
GROUP BY status;

-- Records with trials
SELECT COUNT(*) 
FROM entitlements_ledger 
WHERE ever_trial = true;

-- Ledger growth rate (records added this month)
SELECT COUNT(*) 
FROM entitlements_ledger 
WHERE first_seen_at >= DATE_TRUNC('month', NOW());

-- Old records needing pruning
SELECT COUNT(*) 
FROM entitlements_ledger 
WHERE last_seen_at < NOW() - INTERVAL '24 months';
```

### Alerts to Set Up

- ⚠️ Alert if LEDGER_SALT is missing (startup validation fails)
- ⚠️ Alert if ledger upserts fail repeatedly (>5% failure rate)
- ⚠️ Alert if ledger table size exceeds expected growth
- ⚠️ Alert if pruning job fails

---

## ✅ Success Criteria

Your implementation is complete when:

1. ✅ Migration runs successfully (both tables created)
2. ✅ LEDGER_SALT is set in production
3. ✅ Receipt validation logs show "📊 Ledger record upserted"
4. ✅ Account deletion logs show "📊 Mirroring X entitlement(s)"
5. ✅ Unit tests pass
6. ✅ Integration test: Delete account → PII gone, ledger persists
7. ✅ No breaking changes to existing endpoints
8. ✅ Documentation complete

---

## 📧 Support

For questions or issues with this implementation:

1. Check `backend/docs/deletion-and-ledger.md` for detailed privacy/legal info
2. Review test files for usage examples
3. Check logs for specific error messages
4. Contact engineering team

---

**Implementation Date**: October 15, 2025  
**Version**: 1.0  
**Status**: ✅ Complete and Ready for Deployment  
**Breaking Changes**: None  
**Rollback**: Safe to rollback - new tables are isolated from existing system

