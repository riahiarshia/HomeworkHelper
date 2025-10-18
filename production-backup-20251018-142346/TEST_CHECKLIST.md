# ✅ Sandbox Testing Checklist

## Pre-Flight Setup

### 1. Xcode Scheme Configuration
- [ ] Open Xcode
- [ ] Product → Scheme → Edit Scheme
- [ ] Click "Run" in left sidebar
- [ ] Click "Options" tab
- [ ] StoreKit Configuration: Select `Configuration.storekit`
- [ ] Close scheme editor

### 2. Device/Simulator Setup
- [ ] Open Settings app
- [ ] Tap on your name at the top
- [ ] Tap "Media & Purchases"
- [ ] Tap "Sign Out"
- [ ] **Verify you're signed out** (important!)

### 3. Xcode Build
- [ ] Clean build folder: `Cmd + Shift + K`
- [ ] Build and run: `Cmd + R`
- [ ] Open Xcode console to view logs

---

## Test 1: Product Loading ⏱️ 2 minutes

### Steps:
- [ ] App launches successfully
- [ ] Navigate to Settings → Subscription (or trigger paywall)
- [ ] Wait for products to load

### Check Console For:
```
📦 Loading products...
📦 Environment: Sandbox/TestFlight
✅ Loaded subscription product: Monthly Premium
   Price: $9.99
```

### Result:
- [ ] ✅ Product loaded successfully
- [ ] ❌ Product failed to load → See troubleshooting

---

## Test 2: Sandbox Purchase ⏱️ 5 minutes

### Steps:
- [ ] Tap "Subscribe" or "Start Free Trial" button
- [ ] Apple's purchase dialog appears
- [ ] **Verify dialog shows "[Sandbox Environment]"** ← Critical!
- [ ] Enter sandbox test account email
- [ ] Enter sandbox test account password
- [ ] Tap "Buy" or "Confirm"
- [ ] Wait for transaction to process

### Check Console For:
```
🛒 Purchase() called
🛒 Environment: Sandbox
🧪 SANDBOX: You should see Apple's sandbox purchase dialog
✅ Purchase successful, verifying transaction...
✅ Transaction verified
✅ Transaction ID: 2000000XXXXXXXX
🍎 Sending receipt for validation to backend...
✅ Receipt validated by backend
✅ Purchase complete!
```

### Result:
- [ ] ✅ Purchase completed successfully
- [ ] ✅ Paywall dismissed
- [ ] ✅ App shows active subscription
- [ ] ❌ Purchase failed → See troubleshooting

---

## Test 3: Backend Validation ⏱️ 3 minutes

### Steps:
- [ ] After successful purchase, check backend logs
- [ ] Query database for user's subscription data

### Check Backend Logs (Azure):
```bash
az webapp log tail --name homework-helper-api --resource-group your-resource-group
```

Look for:
```
🍎 Validating Apple receipt for user [user-id]
✅ Apple receipt validated for user [user-id] - expires: [date]
```

### Check Database:
```sql
SELECT 
  subscription_status,
  apple_original_transaction_id,
  apple_product_id,
  apple_environment,
  subscription_end_date
FROM users 
WHERE user_id = 'your-user-id';
```

### Expected Results:
- [ ] subscription_status = 'active'
- [ ] apple_original_transaction_id = (long number)
- [ ] apple_product_id = 'com.homeworkhelper.monthly'
- [ ] apple_environment = 'Sandbox'
- [ ] subscription_end_date = (future date)

### Result:
- [ ] ✅ Backend validated receipt
- [ ] ✅ Database updated correctly
- [ ] ❌ Validation failed → Check APPLE_SHARED_SECRET in Azure

---

## Test 4: UI Verification ⏱️ 2 minutes

### Steps:
- [ ] Check main app UI shows subscription is active
- [ ] Navigate to Settings → Subscription
- [ ] Verify subscription status displayed correctly
- [ ] Try using app features (should work)

### Expected:
- [ ] No paywall appears
- [ ] Subscription status shows "Active"
- [ ] All features accessible
- [ ] Days remaining displayed correctly

### Result:
- [ ] ✅ UI reflects active subscription
- [ ] ❌ UI incorrect → Refresh subscription status

---

## Test 5: Restore Purchases ⏱️ 5 minutes

### Steps:
- [ ] Note down your user account email
- [ ] Delete the app from device/simulator
- [ ] Rebuild and run app from Xcode
- [ ] Log in with same account
- [ ] Go to subscription screen
- [ ] Tap "Restore Purchases"
- [ ] Wait for restore to complete

### Check Console For:
```
✅ Purchases restored and subscription status refreshed
```

### Result:
- [ ] ✅ Subscription restored successfully
- [ ] ✅ UI shows active subscription
- [ ] ❌ Restore failed → Try signing out of App Store again

---

## Common Issues & Quick Fixes

### ❌ Issue: No products found

**Quick Fix:**
```
1. Product → Scheme → Edit Scheme → Run → Options
2. StoreKit Configuration: Select Configuration.storekit
3. Cmd + Shift + K (clean)
4. Cmd + R (rebuild)
```

---

### ❌ Issue: Real Apple ID appears in dialog

**Quick Fix:**
```
1. Settings app
2. [Your Name] → Media & Purchases → Sign Out
3. Kill app
4. Restart from Xcode
```

---

### ❌ Issue: "Already bought this subscription"

**Quick Fix:**
```
In Xcode:
1. Debug → StoreKit → Manage Transactions
2. Delete all transactions
3. Try purchase again
```

---

### ❌ Issue: Purchase succeeds but backend validation fails

**Quick Fix:**
```
1. Check Azure environment variables:
   - APPLE_SHARED_SECRET must be set
2. Verify backend is running
3. Check backend logs for detailed error
```

---

### ❌ Issue: Connection error

**Quick Fix:**
```
1. Verify signed OUT of App Store
2. Check internet connection
3. Wait 30 seconds and try again (sandbox can be slow)
4. Try on different device/simulator
```

---

## Success Criteria

All tests pass when:

- ✅ Products load from Configuration.storekit
- ✅ Purchase dialog shows "[Sandbox Environment]"
- ✅ Transaction completes without errors
- ✅ Console shows success logs at each step
- ✅ Backend validates receipt with Apple
- ✅ Database updates with subscription data
- ✅ App UI reflects active subscription
- ✅ Restore purchases works
- ✅ **NO REAL MONEY CHARGED** (sandbox mode)

---

## Time Estimate

| Test | Time | Status |
|------|------|--------|
| Product Loading | 2 min | ⬜ |
| Sandbox Purchase | 5 min | ⬜ |
| Backend Validation | 3 min | ⬜ |
| UI Verification | 2 min | ⬜ |
| Restore Purchases | 5 min | ⬜ |
| **Total** | **~17 min** | |

---

## Notes Section

Use this space to note any issues or observations:

```
Date: _______________
Device/Simulator: _______________
iOS Version: _______________

Test 1 (Product Loading):


Test 2 (Sandbox Purchase):


Test 3 (Backend Validation):


Test 4 (UI Verification):


Test 5 (Restore Purchases):


Overall Notes:


```

---

## 🎯 Ready to Test?

Before starting, verify:
- [x] Code changes applied (already done)
- [ ] Signed out of App Store
- [ ] Configuration.storekit selected in scheme
- [ ] Console visible in Xcode
- [ ] Sandbox test account credentials handy

**Start with Test 1!** ▶️

---

**For detailed help:** See `SANDBOX_TESTING_GUIDE.md`
**For quick reference:** See `SANDBOX_QUICK_START.md`
**For change details:** See `SANDBOX_TESTING_CHANGES.md`



