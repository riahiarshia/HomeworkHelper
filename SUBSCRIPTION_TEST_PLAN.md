# 🧪 Subscription Testing - Step-by-Step Plan

## ✅ Step 1: Backend Fix - COMPLETED!

**Fixed:** Removed `age` column reference that was causing crashes
**Status:** ✅ Committed and pushed to GitHub
**Commit:** `ab7c036 - Fix profile update - remove non-existent age column reference`

**Azure Auto-Deploy:**
- If you have auto-deploy enabled, Azure should deploy automatically in ~3-5 minutes
- Check Azure portal: https://portal.azure.com → App Service → homework-helper-api → Deployment Center
- Wait for deployment to complete before testing

**Manual Deploy (if needed):**
```bash
cd /Users/ar616n/Documents/ios-app/ios-app/backend
az webapp deployment source sync --name homework-helper-api --resource-group <your-resource-group>
```

---

## 📱 Step 2: Xcode - Clear StoreKit Cache

**YOU NEED TO DO THIS IN XCODE:**

1. Open Xcode
2. Run the app: `Cmd + R`
3. Once running: **Debug menu → StoreKit → Manage Transactions**
4. Click **"Delete All"** button
5. Stop the app (red square button)

✅ Check this box when done: [ ]

---

## 🔄 Step 3: Reset StoreKit Configuration

**IN XCODE:**

1. **Product → Scheme → Edit Scheme** (or `Cmd + <`)
2. Click **"Run"** in left sidebar
3. Click **"Options"** tab
4. **StoreKit Configuration:** Change to **"None"**
5. Click **"Close"**
6. **Product → Scheme → Edit Scheme** again
7. **StoreKit Configuration:** Change back to **"Configuration.storekit"**
8. Click **"Close"**

✅ Check this box when done: [ ]

---

## 🧹 Step 4: Clean Build

**IN XCODE:**

1. **Product → Clean Build Folder** (`Cmd + Shift + K`)
2. Wait for it to finish
3. **Close Xcode completely** (Cmd + Q)

**IN TERMINAL:**

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

4. **Reopen Xcode**

✅ Check this box when done: [ ]

---

## 🗑️ Step 5: Fresh App Install

**IN SIMULATOR/DEVICE:**

1. **Delete the app completely** (long press → Remove App → Delete App)

**IN XCODE:**

2. **Build and Run:** `Cmd + R`
3. App installs fresh

✅ Check this box when done: [ ]

---

## 👤 Step 6: Create Brand New Test User

**IN THE APP:**

1. **Create NEW account** with NEW email (not riahiarshia or any previous test users)
   - Email: `test-oct12-v2@example.com` (or similar)
   - Password: (your choice)

2. **Complete onboarding:**
   - Enter username
   - Select grade
   - Complete profile setup

3. **Should see:** "7 days remaining" (backend trial) ✅

✅ Check this box when done: [ ]

---

## 🛒 Step 7: Test Purchase (CRITICAL - Watch Console!)

**IN XCODE:**

1. **Open Console if hidden:** `Cmd + Shift + Y`
2. **Clear console:** Right-click → Clear Console

**IN THE APP:**

3. Navigate to **Settings → Subscription** (or wait for paywall after trial expires)
4. Click **"Subscribe"** or **"Start Free Trial"** button
5. **Sign in with sandbox Apple ID** when prompted
6. Complete the purchase

**IN XCODE CONSOLE - WATCH FOR THESE LINES:**

```
🛒 Purchase() called
🛒 Environment: Sandbox
✅ Purchase successful, verifying transaction...
✅ Transaction verified
✅ Transaction ID: 2000000XXXXXXX
✅ Product ID: com.homeworkhelper.monthly
✅ Purchase Date: 2024-10-12 XX:XX:XX ← NOTE THIS TIME
✅ Expiration Date: 2024-10-12 XX:XX:XX ← NOTE THIS TIME
🍎 Sending receipt for validation to backend...
✅ Receipt validated by backend
✅ Purchase complete!
```

**RECORD THESE:**
- Purchase Date: __________________________
- Expiration Date: __________________________
- Time Difference: _______ minutes

✅ Check this box when done: [ ]

---

## 📊 Step 8: Analyze Results

**Calculate time difference:**
- Expiration Date - Purchase Date = ? minutes

**Expected Results:**

| Time Diff | Meaning | Status |
|-----------|---------|--------|
| ~3 minutes | 7-day trial (intro offer active) | ❌ Bad - intro offer not removed |
| ~5 minutes | 30-day subscription (no intro) | ✅ Good - intro offer removed! |

**If 3 minutes:** The introductory offer is still active (cache issue)
**If 5 minutes:** Success! Subscription working correctly ✅

---

## 💾 Step 9: Check Database

**IN YOUR DATABASE CLIENT:**

```sql
SELECT 
  email,
  subscription_status,
  subscription_start_date,
  subscription_end_date,
  apple_product_id,
  apple_environment,
  EXTRACT(EPOCH FROM (subscription_end_date - subscription_start_date))/60 as minutes_duration,
  EXTRACT(DAY FROM (subscription_end_date - NOW())) as days_remaining_calculation
FROM users 
WHERE email = 'test-oct12-v2@example.com'  -- Your test email
ORDER BY created_at DESC 
LIMIT 1;
```

**RECORD THESE:**
- subscription_status: __________________________
- apple_environment: __________________________
- minutes_duration: _______ minutes (should be ~5)
- days_remaining_calculation: _______ days

✅ Check this box when done: [ ]

---

## ✅ Success Criteria

Your subscription system is working correctly if:

- ✅ Console shows **5 minutes** between purchase and expiration
- ✅ Database `minutes_duration` is **~5 minutes**
- ✅ Database `apple_environment` is **"Sandbox"**
- ✅ Database `subscription_status` is **"active"**
- ✅ App UI shows **"Active"** subscription

---

## ❌ If Still Showing 3 Minutes (7-day trial)

The introductory offer cache is stubborn. Try:

### Nuclear Option: Recreate StoreKit Configuration

1. In Xcode, delete `Configuration.storekit` file
2. **File → New → File → StoreKit Configuration File**
3. Name it: `Configuration.storekit`
4. Add subscription manually:
   - Click **+** → Add Subscription
   - Product ID: `com.homeworkhelper.monthly`
   - Reference Name: `Monthly Premium Subscription`
   - Price: `$9.99`
   - Subscription Duration: `1 month`
   - **DO NOT add introductory offer!**
5. Save file
6. Repeat Steps 2-7 above

---

## 📝 Report Back

After completing all steps, reply with:

1. **Time difference** from Step 8: _______ minutes
2. **Database `minutes_duration`**: _______ minutes
3. **Console logs** (copy/paste the Purchase Date and Expiration Date lines)
4. **Screenshot** of database query results (optional)

---

## 🎯 Understanding Sandbox Time

Remember:
- **3 minutes** in sandbox = **7 days** in production
- **5 minutes** in sandbox = **30 days** (1 month) in production

So if you see "5 minutes" in testing, that means users will get a full **30-day subscription** in production! ✅

---

## 🆘 Troubleshooting

### Issue: Backend still showing "age" error
**Solution:** Wait 3-5 minutes for Azure auto-deploy, or manually deploy

### Issue: Can't find "Manage Transactions" in Debug menu
**Solution:** App must be running in simulator/device first

### Issue: StoreKit Configuration not in scheme options
**Solution:** Make sure Configuration.storekit file is in your project

### Issue: Purchase fails immediately
**Solution:** Make sure you're signed OUT of real App Store in Settings

---

**Current Status:**
- ✅ Backend fix deployed
- ⏳ Waiting for you to complete Xcode steps 2-9

**Start with Step 2 now!** 🚀



