# 🚀 TestFlight Setup - Complete Guide

## 🎯 Overview

TestFlight lets you distribute beta versions of your app to testers before App Store release. For subscription testing, you'll use **sandbox mode** with real devices.

---

## ✅ Step 1: Prepare App for TestFlight

### A. Update Version & Build Number

**In Xcode:**
1. Select project in navigator
2. Select "HomeworkHelper" target
3. Go to "General" tab
4. Update:
   - **Version:** 1.0 (or current version)
   - **Build:** Increment by 1 each upload (e.g., 1, 2, 3...)

### B. Set Up Signing & Capabilities

1. In Xcode: Target → "Signing & Capabilities"
2. **Automatically manage signing:** ✅ Checked
3. **Team:** Select your Apple Developer team
4. **Bundle Identifier:** Should match App Store Connect

### C. Select Archive Scheme

1. **Product → Scheme → Edit Scheme**
2. **Run** → Build Configuration: **Release** (not Debug!)
3. **Archive** → Build Configuration: **Release**
4. Click "Close"

---

## 📦 Step 2: Archive the App

### A. Select "Any iOS Device"

**In Xcode toolbar:**
```
HomeworkHelper > [Any iOS Device (arm64)]
```
(Not a specific simulator!)

### B. Archive

**Menu:** Product → Archive

This will:
- Build your app in Release mode
- Create an `.xcarchive` file
- Open the Organizer window when complete

**Time:** ~2-5 minutes

---

## 🌐 Step 3: Upload to App Store Connect

### In Xcode Organizer Window:

1. Select your archive
2. Click **"Distribute App"**
3. Select **"App Store Connect"**
4. Click **"Next"**
5. Select **"Upload"**
6. Click **"Next"**
7. **Distribution options:**
   - ✅ Upload your app's symbols
   - ✅ Manage Version and Build Number (if needed)
8. Click **"Next"**
9. **Signing:** Automatically manage signing
10. Click **"Upload"**

**Wait:** Upload takes 5-10 minutes

### After Upload:

You'll see: "Upload Successful"
- The build will process on App Store Connect (10-30 minutes)
- You'll get an email when processing is complete

---

## 🎮 Step 4: App Store Connect Configuration

### A. Go to App Store Connect

**URL:** https://appstoreconnect.apple.com

### B. Select Your App

1. Click **"My Apps"**
2. Click **"HomeworkHelper"** (or your app name)

### C. Go to TestFlight Tab

1. Click **"TestFlight"** tab at top
2. Wait for build to appear under "Builds" (if just uploaded)

### D. Add What to Test Info

1. Click on your build number
2. **"What to Test"** section:
   ```
   Version 1.0 - Build X
   
   New Features:
   - Subscription system with 7-day trial
   - Monthly subscription ($9.99/month)
   - Full homework helper functionality
   
   Testing Focus:
   - Please test the subscription purchase flow
   - Verify trial period works correctly
   - Test all app features after subscribing
   ```

3. Click **"Save"**

---

## 👥 Step 5: Add TestFlight Testers

### Option 1: Internal Testing (Up to 100 people)

**Best for:** Your team, friends, family

1. **TestFlight tab** → **Internal Testing** section
2. Click **"+"** next to groups
3. Create group: "Beta Testers"
4. Click **"+"** to add testers
5. Add by Apple ID email (they must have Apple ID)
6. Click **"Add"**
7. **Important:** Enable all builds for this group

**Testers will receive email invitation instantly!**

### Option 2: External Testing (Up to 10,000 people)

**Note:** Requires Beta App Review (1-2 days)

1. **TestFlight tab** → **External Testing** section
2. Click **"+"** to create group
3. Add testers (requires email only, not Apple ID)
4. Submit for Beta App Review
5. Wait for approval

**For now, use Internal Testing!**

---

## 🔐 Step 6: Set Up Subscription Products (Critical!)

### A. Navigate to Subscriptions

**App Store Connect:**
1. Your App → **In-App Purchases** (left sidebar)
2. Click **"Manage"** next to Subscriptions

### B. Create Subscription Group

1. Click **"+"** (if no group exists)
2. **Reference Name:** Premium Subscription
3. Click **"Create"**

### C. Create Monthly Subscription

1. Inside the group, click **"+"** to add subscription
2. **Product ID:** `com.homeworkhelper.monthly` (must match your code!)
3. **Reference Name:** Monthly Premium Subscription
4. **Subscription Duration:** 1 month
5. **Price:** $9.99
6. Click **"Create"**

### D. Add Subscription Information

1. **Display Name:** Monthly Premium
2. **Description:** Unlimited AI tutoring with step-by-step guidance
3. **Add Localization** (English - United States)
4. Click **"Save"**

### E. Add Subscription Pricing

1. Click **"Subscription Pricing"**
2. **Price:** $9.99 (Tier 10)
3. **Select Countries:** All or specific countries
4. Click **"Next"**
5. Review and click **"Create"**

### F. Review Information (Optional Free Trial)

If you want to offer a free trial through Apple (not just backend):
1. Click **"Subscription Offers"**
2. Add introductory offer:
   - **Duration:** 7 days
   - **Type:** Free
3. Click **"Save"**

**Note:** We removed this from Configuration.storekit, but you can add it here for production if wanted.

### G. Submit for Review

1. Click **"Submit for Review"** (blue button)
2. Fill in required info:
   - Screenshot of subscription UI
   - Description of what users get
3. Submit

**Review time:** Usually 1-2 days

---

## 📱 Step 7: Testers Install TestFlight

### A. Testers Receive Email

Apple sends invitation email with:
- Link to install TestFlight app
- Code to redeem your app

### B. Tester Setup

1. Install **TestFlight** app from App Store
2. Open invitation email
3. Tap **"View in TestFlight"** link
4. Install your app from TestFlight

---

## 🧪 Step 8: Testing Subscriptions in TestFlight

### CRITICAL: TestFlight Uses SANDBOX Mode!

**For testers to test purchases:**

1. **Sign OUT of real App Store:**
   ```
   Settings → [Name] → Media & Purchases → Sign Out
   ```

2. **Open your app from TestFlight**

3. **Navigate to subscription screen**

4. **Tap "Subscribe"**

5. **When prompted, sign in with SANDBOX test account**
   - Use the sandbox tester you created in App Store Connect
   - NOT their real Apple ID!

6. **Complete purchase** (no real charge in sandbox!)

---

## 📊 Step 9: Monitor TestFlight Analytics

**App Store Connect → TestFlight tab → Testers:**

You can see:
- ✅ Who installed the app
- ✅ Which builds they're testing
- ✅ Crash reports
- ✅ Feedback from testers

---

## 🔍 Step 10: Verify Subscriptions Work

### Check Backend:

```sql
SELECT 
  email,
  subscription_status,
  apple_environment,
  apple_product_id,
  subscription_end_date
FROM users 
WHERE apple_environment = 'Sandbox'
ORDER BY created_at DESC;
```

**Expected for TestFlight testers:**
- `apple_environment` = "Sandbox" ✅
- `subscription_status` = "active" ✅
- `apple_product_id` = "com.homeworkhelper.monthly" ✅

---

## ⚠️ Common Issues & Solutions

### Issue 1: "No products found"

**Cause:** Subscription not approved yet or product ID mismatch

**Solution:**
- Wait for subscription approval in App Store Connect
- Verify product ID matches exactly: `com.homeworkhelper.monthly`
- Check subscription is available in all countries

### Issue 2: "Cannot connect to iTunes Store"

**Cause:** Tester using real Apple ID instead of sandbox

**Solution:**
- Sign OUT of real App Store
- Use sandbox test account when purchasing

### Issue 3: Build not appearing in TestFlight

**Cause:** Processing takes time or build didn't meet requirements

**Solution:**
- Wait up to 30 minutes
- Check email for processing errors
- Ensure all required capabilities are enabled

### Issue 4: Subscription shows as "Sandbox" but should be "Production"

**This is CORRECT!** TestFlight always uses sandbox mode for subscriptions!

---

## 🚀 Step 11: Iterate & Update

### When you make changes:

1. **Increment build number** in Xcode
2. **Archive** again
3. **Upload** to App Store Connect
4. **Wait for processing**
5. **Testers automatically get update** notification

---

## 📋 Quick Checklist

Before uploading to TestFlight:

- [ ] Version and build number updated
- [ ] Signing set to Release mode
- [ ] Archive created successfully
- [ ] Upload to App Store Connect complete
- [ ] Build processed (received email)
- [ ] Internal testers added
- [ ] Subscription products created in App Store Connect
- [ ] Subscriptions submitted for review
- [ ] Testers know to use sandbox accounts
- [ ] Backend ready to handle sandbox receipts

---

## 🎯 Success Criteria

TestFlight is working when:

- ✅ Testers can install app from TestFlight
- ✅ Testers can purchase subscription (with sandbox account)
- ✅ Backend validates sandbox receipts
- ✅ Database shows `apple_environment = 'Sandbox'`
- ✅ App functions correctly with active subscription
- ✅ No crashes or major issues reported

---

## 📞 Need Help?

### TestFlight Issues:
- Apple Developer Forums: https://developer.apple.com/forums/
- App Store Connect Help: https://help.apple.com/app-store-connect/

### Subscription Issues:
- Check backend logs
- Verify database has correct data
- Test with sandbox account (not real Apple ID)

---

## 🚀 Next Steps After TestFlight

Once testing is successful:

1. **Fix any reported bugs**
2. **Upload new builds as needed**
3. **Get feedback from testers**
4. **Prepare for App Store submission**
5. **Submit for App Store Review**

---

**Ready to start?** Follow Step 1! 🎯



