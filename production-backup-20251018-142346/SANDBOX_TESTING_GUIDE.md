# 🧪 Sandbox Subscription Testing Guide

## ✅ Setup Complete!

The iOS app has been updated to enable **real StoreKit sandbox testing**. The DEBUG bypass has been removed so you can now test actual Apple subscription purchases.

---

## 📋 Prerequisites

Before testing, ensure you have:

1. **Sandbox Test Account** - Created in App Store Connect
   - Go to: App Store Connect → Users and Access → Sandbox Testers
   - Create a test account with unique email
   - ⚠️ **NEVER use your real Apple ID for sandbox testing**

2. **StoreKit Configuration** - Verified in Xcode
   - Product ID: `com.homeworkhelper.monthly`
   - Price: $9.99/month
   - Free trial: 1 week
   - File: `HomeworkHelper/Configuration.storekit`

3. **Xcode Scheme Configuration**
   - Scheme: HomeworkHelper
   - Run → Options → StoreKit Configuration: `Configuration.storekit` ✅

---

## 🚀 How to Test Sandbox Subscriptions

### Step 1: Sign Out of App Store

**CRITICAL:** You must sign out of the App Store on your test device/simulator.

1. Open **Settings** app
2. Tap on your name at the top
3. Scroll down and tap **Media & Purchases**
4. Tap **Sign Out**

> ⚠️ **Do NOT sign out of iCloud** - only sign out of Media & Purchases!

### Step 2: Run the App from Xcode

1. Clean build folder: `Cmd + Shift + K`
2. Build and run: `Cmd + R`
3. Watch the console for detailed logs:
   ```
   📦 Loading products...
   📦 Environment: Sandbox/TestFlight
   ✅ Loaded subscription product: Monthly Premium
   🧪 SANDBOX MODE - Ready for testing with sandbox Apple ID
   ```

### Step 3: Trigger the Paywall

You can trigger the paywall in several ways:

1. **New User Flow:**
   - Create a new account or log in
   - Your trial will automatically start
   - Let trial expire (or use admin portal to set trial to 0 days)
   - Open the app → Paywall should appear

2. **Direct Navigation:**
   - Navigate to Settings
   - Tap "Subscription" or "Manage Subscription"
   - View the subscription options

### Step 4: Make a Test Purchase

1. Tap **"Start Free Trial"** or **"Subscribe Now"**
2. Console logs will show:
   ```
   🛒 Purchase() called
   🛒 Environment: Sandbox
   🛒 Product found: Monthly Premium
   🧪 SANDBOX: You should see Apple's sandbox purchase dialog
   ```

3. **Apple's Sandbox Dialog Appears:**
   - Title: **"Confirm Your In-App Purchase"**
   - Subtitle: **"[Sandbox Environment]"** ← This confirms you're in sandbox!
   - Email field: Enter your sandbox test account email
   - Password field: Enter your sandbox password

4. **Confirm Purchase:**
   - Tap **"Buy"**
   - Apple processes the sandbox transaction (no real money!)

5. **Watch Console Logs:**
   ```
   ✅ Purchase successful, verifying transaction...
   ✅ Transaction verified
   ✅ Transaction ID: 2000000123456789
   🧪 SANDBOX: Transaction successful in sandbox environment
   🍎 Sending receipt for validation to backend...
   ✅ Receipt validated by backend
   ✅ Purchase complete!
   ```

---

## 🔍 Expected Behavior

### Successful Purchase Flow:

1. **App:** Loads product from Configuration.storekit
2. **App:** Shows paywall with $9.99/month pricing
3. **User:** Taps subscribe button
4. **Apple:** Shows sandbox purchase dialog (with [Sandbox Environment] label)
5. **User:** Signs in with sandbox account
6. **Apple:** Processes sandbox transaction (instant, no real charge)
7. **App:** Receives transaction, verifies it locally
8. **App:** Sends receipt to backend for validation
9. **Backend:** Validates with Apple's sandbox servers
10. **Backend:** Updates database with subscription status
11. **App:** Updates UI to show active subscription

### Console Log Indicators:

✅ **Success Indicators:**
```
📦 Environment: Sandbox/TestFlight
✅ Loaded subscription product: Monthly Premium
🧪 SANDBOX MODE - Ready for testing
🛒 Product ID: com.homeworkhelper.monthly
✅ Transaction verified
✅ Receipt validated by backend
```

❌ **Error Indicators:**
```
⚠️ No products found for ID: com.homeworkhelper.monthly
❌ Purchase error: ...
❌ Backend receipt validation failed
```

---

## 🐛 Troubleshooting

### Issue 1: "No products found"

**Symptoms:**
```
⚠️ No products found for ID: com.homeworkhelper.monthly
⚠️ Make sure StoreKit Configuration is set in Xcode scheme
```

**Solutions:**
1. Verify `Configuration.storekit` is selected in scheme:
   - Product → Scheme → Edit Scheme → Run → Options
   - StoreKit Configuration: Select `Configuration.storekit`
2. Clean build folder: `Cmd + Shift + K`
3. Restart Xcode
4. Verify product ID in `Configuration.storekit` matches code

### Issue 2: "Cannot connect to iTunes Store"

**Symptoms:**
- Purchase fails immediately
- Error about iTunes Store connection

**Solutions:**
1. **Sign OUT of App Store:**
   - Settings → [Your Name] → Media & Purchases → Sign Out
   - This is the most common issue!
2. Check network connection
3. Try on a different device/simulator
4. Wait a few minutes (Apple's sandbox can be slow)

### Issue 3: "This In-App Purchase has already been bought"

**Symptoms:**
- Can't complete purchase
- Message about already owning the subscription

**Solutions:**
1. **Reset sandbox account:**
   - Settings → App Store → Sandbox Account → Tap account → Manage
   - Delete all test purchases
2. **Or use a different sandbox account**
3. **Or use Xcode's StoreKit testing:**
   - Editor → Manage Transactions
   - Delete all transactions
   - Try again

### Issue 4: "Purchase succeeds but backend validation fails"

**Symptoms:**
```
✅ Purchase successful
❌ Backend receipt validation failed
```

**Solutions:**
1. Check backend is running and accessible
2. Verify `APPLE_SHARED_SECRET` is set in Azure environment variables
3. Check backend logs for detailed error messages
4. Ensure database has proper subscription columns:
   ```sql
   SELECT apple_original_transaction_id, apple_product_id, apple_environment 
   FROM users 
   WHERE user_id = 'your-user-id';
   ```

### Issue 5: Real Apple ID dialog appears instead of sandbox

**Symptoms:**
- Purchase dialog shows your real email
- No "[Sandbox Environment]" label

**Solutions:**
1. **Sign OUT of App Store** (most important!)
   - Settings → Media & Purchases → Sign Out
2. Restart the app
3. Verify Xcode console shows "Environment: Sandbox"

---

## 🧪 Testing Scenarios

### Test 1: New User Free Trial (Recommended First Test)

1. Sign out of App Store
2. Run app from Xcode
3. Create new user account
4. Complete onboarding
5. Check console for trial status
6. Navigate to paywall
7. Tap "Start Free Trial"
8. Complete sandbox purchase
9. Verify subscription is active

**Expected Result:** User gets subscription, no real charge

### Test 2: Expired Trial User

1. Use admin portal to set trial days to 0
2. Log in to app
3. Paywall should appear
4. Tap "Subscribe Now"
5. Complete sandbox purchase
6. Verify subscription is active

**Expected Result:** User can subscribe after trial expires

### Test 3: Restore Purchases

1. Complete a sandbox purchase
2. Delete app
3. Reinstall app
4. Log in with same account
5. Tap "Restore Purchases"
6. Verify subscription is restored

**Expected Result:** Subscription restores without new purchase

### Test 4: Receipt Validation

1. Complete sandbox purchase
2. Watch console logs for backend validation
3. Check backend logs in Azure
4. Verify database updated correctly

**Expected Result:** Backend validates receipt and updates database

---

## 📊 Backend Validation

### What the Backend Does:

1. **Receives Receipt:**
   - App sends base64-encoded receipt
   - Endpoint: `POST /api/subscription/apple/validate-receipt`

2. **Validates with Apple:**
   - Sends receipt to Apple's sandbox servers
   - Apple returns transaction details

3. **Updates Database:**
   ```sql
   UPDATE users SET
     subscription_status = 'active',
     subscription_end_date = '2024-11-10',
     apple_original_transaction_id = '2000000123456789',
     apple_product_id = 'com.homeworkhelper.monthly',
     apple_environment = 'Sandbox'
   WHERE user_id = 'abc123';
   ```

4. **Logs History:**
   ```sql
   INSERT INTO subscription_history (user_id, event_type, new_status, ...)
   VALUES ('abc123', 'apple_receipt_validated', 'active', ...);
   ```

### Check Backend Logs:

```bash
# View Azure App Service logs
az webapp log tail --name homework-helper-api --resource-group your-resource-group

# Look for:
🍎 Validating Apple receipt for user abc123
✅ Apple receipt validated for user abc123 - expires: 2024-11-10
```

---

## 🔐 Security Notes

### Sandbox vs Production:

| Feature | Sandbox | Production |
|---------|---------|------------|
| **Real Money** | ❌ No charges | ✅ Real charges |
| **Apple ID** | Test account | Real Apple ID |
| **Receipt URL** | `sandboxReceipt` | `receipt` |
| **Validation URL** | `sandbox.itunes.apple.com` | `buy.itunes.apple.com` |
| **Testing** | ✅ Safe to test | ⚠️ Use with caution |

### Important Security Practices:

1. **Never use real Apple ID in sandbox**
2. **Always validate receipts server-side** (already implemented ✅)
3. **Never trust client-side subscription status**
4. **Check backend validates with Apple before granting access**

---

## 🎯 Success Criteria

Your sandbox testing is successful when:

- ✅ Products load from Configuration.storekit
- ✅ Sandbox purchase dialog appears with "[Sandbox Environment]" label
- ✅ Transaction completes without errors
- ✅ Receipt validation succeeds on backend
- ✅ Database updates with subscription data
- ✅ App UI reflects active subscription
- ✅ No real money is charged

---

## 📱 Moving to Production

Once sandbox testing is complete:

1. **App Store Connect Setup:**
   - Add real subscription product matching `com.homeworkhelper.monthly`
   - Configure pricing and availability
   - Set up App Store Server Notifications webhook

2. **Azure Configuration:**
   - Set `APPLE_SHARED_SECRET` environment variable
   - Deploy latest backend code
   - Test webhook endpoint

3. **TestFlight Testing:**
   - Upload build to TestFlight
   - Test with sandbox accounts in TestFlight
   - Verify all flows work

4. **App Store Submission:**
   - Submit for review
   - Include test account credentials
   - Provide subscription documentation

---

## 🆘 Getting Help

### Console Logs are Your Friend!

The app now has extensive logging for debugging:

```
📦 Product loading
🛒 Purchase flow
🧪 Sandbox-specific tips
✅ Success indicators
❌ Error details with troubleshooting tips
```

### Common Console Messages:

| Message | Meaning |
|---------|---------|
| `🧪 SANDBOX MODE - Ready for testing` | Products loaded successfully |
| `🛒 Environment: Sandbox` | Using sandbox environment |
| `✅ Transaction verified` | StoreKit verification passed |
| `✅ Receipt validated by backend` | Backend validation successful |
| `❌ Purchase error` | Something went wrong - read the details |

### Still Having Issues?

1. **Check Console Logs:** Most issues are explained in logs
2. **Verify Sign Out:** Make sure you're signed out of App Store
3. **Check Scheme Settings:** Ensure Configuration.storekit is selected
4. **Try Different Device:** Simulator vs real device can behave differently
5. **Wait and Retry:** Apple's sandbox can be slow sometimes

---

## 🎉 You're Ready!

The app is now configured for proper sandbox testing. Follow the steps above, watch the console logs, and test all subscription flows. Good luck! 🚀

**Pro Tip:** Start with Test Scenario 1 (New User Free Trial) for the smoothest first test experience.



