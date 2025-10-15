# 🚀 Sandbox Testing - Quick Start

## ⚡️ 3-Step Quick Setup

### Step 1: Sign Out of App Store (CRITICAL!)
```
Settings → [Your Name] → Media & Purchases → Sign Out
```
⚠️ **Do NOT sign out of iCloud** - only Media & Purchases!

### Step 2: Run App from Xcode
```
Clean: Cmd + Shift + K
Build: Cmd + R
```

### Step 3: Test Purchase
1. Navigate to subscription/paywall
2. Tap "Subscribe" or "Start Free Trial"
3. When Apple's dialog appears, sign in with your sandbox test account
4. Look for **"[Sandbox Environment]"** label - confirms you're in sandbox mode!

---

## ✅ What Changed?

The app has been updated to enable **real StoreKit sandbox testing**:

### Before:
- ❌ DEBUG mode bypassed StoreKit entirely
- ❌ Product loading skipped in TestFlight
- ❌ Couldn't test real Apple subscription flow

### After:
- ✅ Real StoreKit flow enabled in DEBUG mode
- ✅ Products load from Configuration.storekit
- ✅ Sandbox purchases work properly
- ✅ Detailed logging for debugging
- ✅ Receipt validation with backend

---

## 🔍 Console Logs to Watch For

### Success:
```
📦 Environment: Sandbox/TestFlight
✅ Loaded subscription product: Monthly Premium
🛒 Product ID: com.homeworkhelper.monthly
🛒 Price: $9.99
🧪 SANDBOX: You should see Apple's sandbox purchase dialog
✅ Transaction verified
✅ Receipt validated by backend
```

### Error:
```
❌ Purchase error: ...
⚠️ No products found
```

---

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| No products found | Check Configuration.storekit is selected in scheme settings |
| Real Apple ID appears | Sign OUT of App Store in Settings |
| Already bought error | Delete transactions in Xcode: Editor → Manage Transactions |
| Connection error | Make sure you're signed out of App Store |

---

## 📁 Key Files Modified

1. **PaywallView.swift** - Removed DEBUG bypass, enabled real StoreKit
2. **SubscriptionService.swift** - Enhanced logging, proper sandbox detection
3. **Configuration.storekit** - Verified (already correct)

---

## 📚 Full Documentation

For detailed testing scenarios, troubleshooting, and backend validation:
- See `SANDBOX_TESTING_GUIDE.md`

---

## 🎯 Test Now!

1. Sign out of App Store ✓
2. Run app from Xcode ✓
3. Go to subscription screen ✓
4. Make test purchase ✓
5. Check console for success logs ✓

**Expected Result:** Sandbox purchase completes successfully with detailed console logs showing each step.

---

## 💡 Pro Tips

- **Always check console logs** - They tell you exactly what's happening
- **[Sandbox Environment] label** - This confirms you're not using real money
- **Be patient** - Sandbox can be slower than production
- **Clean build** - When in doubt, clean and rebuild

---

Good luck with testing! 🚀



