# Account Deletion & Entitlements Ledger

## Overview

This document explains our approach to account deletion, data retention, and the entitlements ledger system.

## Account Deletion (GDPR/CCPA Compliant)

### What Gets Deleted

When a user deletes their account via `/api/auth/delete-account`:

- ✅ User profile (name, email, username)
- ✅ User entitlements (subscription records with PII)
- ✅ Subscription history
- ✅ Password reset tokens
- ✅ Device associations
- ✅ API usage records
- ✅ All personally identifiable information (PII)

### What We Retain (De-Identified)

For fraud prevention and legal compliance (Apple 5.1.1(v)), we retain **minimal, de-identified transaction data** in the `entitlements_ledger` table:

| Data Point | Purpose | PII? |
|------------|---------|------|
| `original_transaction_id_hash` | SHA-256 hash of Apple's transaction ID (salted) | ❌ No |
| `product_id` | Product identifier (e.g., "com.homeworkhelper.monthly") | ❌ No |
| `subscription_group_id` | Subscription group identifier | ❌ No |
| `ever_trial` | Boolean flag: did this transaction ever use a trial | ❌ No |
| `status` | Current status (active/expired/canceled) | ❌ No |
| `first_seen_at` | Timestamp of first transaction | ❌ No |
| `last_seen_at` | Timestamp of last update | ❌ No |

**No user_id, email, name, or other PII is retained in the ledger.**

---

## Entitlements Ledger System

### Purpose

The entitlements ledger serves three purposes:

1. **Fraud Prevention**: Detect trial abuse (users deleting accounts to get infinite free trials)
2. **Accounting Compliance**: Maintain transaction records for financial audits
3. **Business Analytics**: Understand subscription patterns (aggregate, anonymized)

### How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                      User Lifecycle                             │
└─────────────────────────────────────────────────────────────────┘

1. User signs up
   └─ No subscription initially

2. User purchases subscription
   ├─ Receipt validated with Apple
   ├─ user_entitlements created (has PII while account exists)
   └─ entitlements_ledger upserted (de-identified, persists forever)

3. User deletes account
   ├─ BEFORE deletion: Mirror user_entitlements → entitlements_ledger
   ├─ Delete user_entitlements (contains PII)
   ├─ Delete all other user data
   └─ entitlements_ledger remains (no PII, only hash + metadata)

4. Same user tries to abuse trial
   ├─ Signs up again with new account
   ├─ Attempts to get free trial through Apple IAP
   └─ Apple blocks trial (tied to Apple ID, not our app account)
       └─ Our ledger provides additional audit trail
```

### Two-Table Architecture

#### 1. `user_entitlements` (User-linked, ephemeral)
- Contains PII: user_id, plain original_transaction_id
- Deleted when user deletes account
- Used for active subscription management
- Can be queried by user_id for admin dashboard

#### 2. `entitlements_ledger` (De-identified, permanent)
- Contains NO PII: only hashed transaction ID and metadata
- Persists after account deletion
- Used for fraud detection and compliance
- Cannot be linked back to individuals

### Hashing Strategy

Transaction IDs are hashed using:
```javascript
SHA-256(LEDGER_SALT + original_transaction_id)
```

- **LEDGER_SALT**: Server-side secret, never exposed
- **Purpose**: Prevents rainbow table attacks
- **Result**: Stable hash (same txid = same hash) but not reversible
- **Compliance**: Hash is not considered PII under GDPR/CCPA

---

## Legal Basis for Retention

### GDPR (EU)

**Legal Basis**: Legitimate Interest (Article 6(1)(f))

- **Purpose**: Fraud prevention and financial compliance
- **Necessity Test**: Minimal data required to prevent service abuse
- **Balancing Test**: Business need outweighs minimal privacy impact (no PII retained)

**Right to Erasure Exception**: Article 17(3)(e) - data necessary for legal claims or compliance

### CCPA (California)

**Legal Basis**: Business Purpose Exception

- **Purpose**: Detecting security incidents, protecting against fraud
- **Data Minimization**: Only non-personal identifiers retained
- **Consumer Rights**: Right to deletion satisfied (PII deleted, only de-identified data remains)

### Apple App Store

**Compliance**: Apple Developer Program License Agreement 5.1.1(v)

- Developers may retain minimal transaction data for fraud prevention
- Must not retain unnecessary PII
- De-identified ledger complies with Apple's requirements

---

## Data Retention Policy

### user_entitlements
- **Retention**: While user account exists
- **Deletion**: Immediately upon account deletion
- **Purpose**: Active subscription management

### entitlements_ledger
- **Retention**: 24 months from `last_seen_at` (configurable via `RETENTION_MONTHS_ENTITLEMENTS_LEDGER`)
- **Deletion**: Automated pruning via scheduled job
- **Purpose**: Fraud prevention, legal compliance, business analytics

### Database Backups

- **Retention**: 30-day rolling window
- **Scope**: Full backups include both tables
- **Deletion**: Backups older than 30 days are automatically purged
- **Purpose**: Disaster recovery, not long-term archival

---

## Privacy Policy Disclosure

Include this in your privacy policy:

```markdown
### Transaction Data Retention

When you subscribe through the App Store, we validate your purchase with Apple 
and record minimal subscription information. If you delete your account:

**What We Delete:**
- Your name, email, and profile information
- Your subscription details linked to your account
- All personally identifiable information

**What We Retain (De-Identified):**
We retain a minimal, de-identified record of your subscription for:
- Fraud prevention (preventing abuse of free trials)
- Financial compliance (accounting and audit requirements)
- Business analytics (aggregate, anonymized metrics)

This record contains:
- A cryptographic hash of your Apple transaction ID (cannot identify you)
- Product identifier (what you subscribed to)
- Trial usage flag (whether you used a free trial)
- Status and timestamps

This data cannot be linked back to you personally and is retained for 24 months 
for fraud prevention purposes, as permitted by GDPR Article 6(1)(f) and CCPA 
business purpose exceptions.

**Legal Basis:** Fraud prevention, financial compliance, business analytics.
```

---

## Technical Implementation

### Environment Variables Required

```bash
# Required in production
DATABASE_URL=postgresql://...
LEDGER_SALT=<random-256-bit-hex-string>

# Optional (defaults shown)
RETENTION_MONTHS_ENTITLEMENTS_LEDGER=24
```

### Generate LEDGER_SALT

```bash
# Generate a secure random salt (do this once, store securely)
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### Scheduled Pruning Job

Add to your cron/scheduler:

```javascript
const { pruneLedger } = require('./services/entitlementsLedgerService');

// Run daily at 2 AM
cron.schedule('0 2 * * *', async () => {
    const retentionMonths = Number(process.env.RETENTION_MONTHS_ENTITLEMENTS_LEDGER || 24);
    const pruned = await pruneLedger(retentionMonths);
    console.log(`Pruned ${pruned} old ledger records`);
});
```

---

## Audit & Compliance

### Proving Compliance

To demonstrate GDPR/CCPA compliance:

1. **Account Deletion Test**:
   ```sql
   -- Before deletion
   SELECT * FROM users WHERE user_id = '<test-user-id>';
   SELECT * FROM user_entitlements WHERE user_id = '<test-user-id>';
   
   -- After deletion (via API)
   SELECT * FROM users WHERE user_id = '<test-user-id>';  -- Empty
   SELECT * FROM user_entitlements WHERE user_id = '<test-user-id>';  -- Empty
   SELECT * FROM entitlements_ledger WHERE user_id = '<test-user-id>';  -- No user_id column!
   ```

2. **Ledger Inspection**:
   ```sql
   SELECT * FROM entitlements_ledger LIMIT 10;
   -- Shows: No user_id, no email, no name - only hashes and metadata
   ```

3. **Data Subject Access Request**:
   ```sql
   -- Query for user's data
   SELECT * FROM users WHERE email = 'user@example.com';
   SELECT * FROM user_entitlements WHERE user_id = '<user-id>';
   
   -- Ledger cannot be queried by user info (no PII)
   -- Hash cannot be reversed to identify user
   ```

### Regular Audits

Perform quarterly:
- [ ] Verify `entitlements_ledger` contains no PII columns
- [ ] Test account deletion flow (PII removed, ledger retained)
- [ ] Review pruning job logs (old records being deleted)
- [ ] Validate `LEDGER_SALT` is securely stored and not exposed

---

## FAQ

**Q: Can we identify a user from the ledger hash?**  
A: No. The hash is one-way and salted. Without the `LEDGER_SALT` and the original transaction ID from Apple (which we delete), the hash cannot be reversed.

**Q: What if Apple requests transaction data?**  
A: Apple already has the transaction data (it's their system). We only hash their IDs for our own fraud prevention.

**Q: Does this violate GDPR's right to erasure?**  
A: No. GDPR allows retention of de-identified data for legitimate purposes (fraud prevention, compliance). Since the ledger contains no PII, it doesn't fall under erasure requirements.

**Q: What if a user wants their ledger record deleted?**  
A: Explain that:
1. The record contains no personal information
2. It cannot be linked back to them
3. It's retained for fraud prevention (protecting all users)
4. It will be automatically purged after 24 months

If they insist, manually delete the record (you'll need to know the hash, which requires the original transaction ID they once had).

**Q: How do we handle Apple ID changes?**  
A: Apple's `original_transaction_id` is stable per Apple ID. If a user changes their Apple ID, they get a new original_transaction_id, which generates a new hash in our ledger.

---

## Contact

For questions about this system, contact the engineering team.

**Last Updated**: October 15, 2025  
**Policy Version**: 1.0

