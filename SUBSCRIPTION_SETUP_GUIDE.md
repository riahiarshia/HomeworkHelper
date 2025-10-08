# Subscription System Setup Guide

## ✅ What's Been Implemented

I've created a comprehensive subscription system following Apple App Store best practices:

### 1. **iOS App Components**

#### New Files Created:
- `HomeworkHelper/Services/SubscriptionService.swift` - StoreKit 2 integration
- `HomeworkHelper/Views/PaywallView.swift` - Beautiful subscription screen
- `HomeworkHelper/Configuration.storekit` - Testing configuration

#### Modified Files:
- `HomeworkHelper/Views/ContentView.swift` - Shows paywall when trial expires
- `HomeworkHelper/Views/HomeView.swift` - Subscription status banner
- `HomeworkHelper/Views/SettingsView.swift` - Subscription management

### 2. **Backend Components**

#### New Files:
- `backend/routes/subscription.js` - Subscription API endpoints

#### Features:
- Sync subscription status between iOS and database
- Admin trial extension/reduction
- Subscription validation

### 3. **Admin Portal**

#### Enhanced Features:
- "Trial" button on each user row
- Modal to extend/reduce trial period
- Supports positive (extend) and negative (reduce) days

---

## 🚀 Setup Instructions

### Step 1: Add Files to Xcode Project

**IMPORTANT**: The new Swift files need to be added to your Xcode project:

1. Open `HomeworkHelper.xcodeproj` in Xcode
2. Right-click on the `Services` folder → "Add Files to HomeworkHelper"
3. Select `HomeworkHelper/Services/SubscriptionService.swift`
4. Make sure "Copy items if needed" is checked
5. Click "Add"

6. Right-click on the `Views` folder → "Add Files to HomeworkHelper"
7. Select `HomeworkHelper/Views/PaywallView.swift`
8. Make sure "Copy items if needed" is checked
9. Click "Add"

10. Right-click on the project root → "Add Files to HomeworkHelper"
11. Select `HomeworkHelper/Configuration.storekit`
12. Make sure "Copy items if needed" is checked
13. Click "Add"

### Step 2: Configure StoreKit Testing

1. In Xcode, go to **Product** → **Scheme** → **Edit Scheme**
2. Select **Run** in the left sidebar
3. Go to the **Options** tab
4. Under **StoreKit Configuration**, select `Configuration.storekit`
5. Click **Close**

### Step 3: Configure App Store Connect (For Production)

When you're ready to publish:

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **Features** → **In-App Purchases**
4. Click **+** to create a new subscription
5. Configure:
   - **Product ID**: `com.homeworkhelper.monthly`
   - **Name**: Monthly Premium Subscription
   - **Price**: $9.99/month
   - **Free Trial**: 7 days
   - **Description**: Unlimited AI tutoring with step-by-step guidance

### Step 4: Update Backend Environment Variables

Add to your `.env` file (or Azure App Settings):

```
ADMIN_SECRET=your-secure-admin-secret-here
```

This is used for admin API calls to extend/reduce trials.

### Step 5: Deploy Backend Changes

```bash
cd backend
git add .
git commit -m "Add subscription management system"
git push origin main
```

Azure will auto-deploy the changes.

---

## 📱 How It Works

### For Users:

1. **New Users**: Get a 7-day free trial automatically
2. **Trial Ending**: See a warning banner when 3 days or less remain
3. **Trial Expired**: Shown a paywall to subscribe
4. **Subscription Active**: See "Premium Active" status with renewal date
5. **Payment Issues**: Grace period with warning to update payment

### For Admins:

1. Go to admin portal: `https://your-backend.azurewebsites.net/admin`
2. Find a user in the user list
3. Click the **"Trial"** button
4. Enter days to add (positive) or remove (negative)
   - Example: `7` adds 7 days
   - Example: `-3` removes 3 days
5. Click **"Apply"**

---

## 🎨 UI/UX Features

### Paywall View:
- Beautiful gradient background (purple to blue)
- Feature list with icons
- Prominent "7-DAY FREE TRIAL" badge
- $9.99/month pricing
- "Start Free Trial" CTA button
- "Restore Purchases" option
- Terms and Privacy links

### Home Screen Banner:
- **Trial (3 days left)**: Orange/red gradient warning
- **Active**: Green success banner with renewal date
- **Expired**: Purple/blue gradient with "Renew" button
- **Grace Period**: Orange warning with "Fix" button

### Settings Screen:
- Subscription status card
- Days remaining counter
- "Upgrade to Premium" button (trial)
- "Manage Subscription" link (active)
- "Restore Purchases" button

---

## 🔧 Testing in Simulator

### Test the 7-Day Trial:

1. Build and run the app
2. Sign in with a new account
3. You'll automatically get a 7-day trial
4. The database will show `subscription_status = 'trial'`

### Test Trial Expiration:

1. Go to admin portal
2. Find your test user
3. Click "Trial" button
4. Enter `-7` to remove all trial days
5. Relaunch the app
6. You should see the paywall

### Test Subscription Purchase:

1. In simulator, the StoreKit Configuration will simulate purchases
2. Click "Start Free Trial" on the paywall
3. StoreKit will show a mock purchase dialog
4. Confirm the purchase
5. You'll get "Premium Active" status

### Test Restore Purchases:

1. Delete and reinstall the app
2. Sign in with the same account
3. Go to Settings → Subscription
4. Click "Restore Purchases"
5. Your subscription should be restored

---

## 🔐 Security Notes

1. **StoreKit 2**: Uses cryptographic verification of transactions
2. **Backend Sync**: All subscriptions synced to your database
3. **Admin Token**: Required for trial management endpoints
4. **JWT Auth**: All subscription endpoints require user authentication

---

## 📊 Database Schema

The `users` table already has these columns:
- `subscription_status` (VARCHAR) - 'trial', 'active', 'expired'
- `subscription_end_date` (TIMESTAMP) - When subscription expires
- `days_remaining` (calculated) - Days until expiration

---

## 🎯 Best Practices Implemented

✅ **7-Day Free Trial** - Industry standard for education apps
✅ **Clear Pricing** - $9.99/month prominently displayed
✅ **Auto-Renewable** - Subscription continues until cancelled
✅ **Restore Purchases** - Users can restore on new devices
✅ **Grace Period** - Payment issues don't immediately block access
✅ **Admin Control** - Extend trials for customer support
✅ **Beautiful UI** - Modern, professional design
✅ **Status Indicators** - Always show subscription status
✅ **Easy Cancellation** - Link to App Store subscription management

---

## 🚨 Important Notes

1. **StoreKit Configuration**: Only works in simulator/TestFlight, not production
2. **Real Purchases**: Require App Store Connect configuration
3. **Sandbox Testing**: Use sandbox Apple ID for testing real purchases
4. **Production**: Update product IDs if needed in `SubscriptionService.swift`

---

## 📞 Support

If users contact support about subscriptions:

1. Ask for their **User ID** (they can copy it from Settings)
2. Look up the user in admin portal
3. Check `subscription_status` and `subscription_end_date`
4. Use "Trial" button to extend if needed
5. Direct them to App Store for payment issues

---

## 🎉 You're All Set!

Once you add the files to Xcode and build, you'll have a fully functional subscription system that:

- ✅ Gives new users a 7-day trial
- ✅ Shows beautiful paywall when trial expires
- ✅ Handles Apple In-App Purchases
- ✅ Syncs with your database
- ✅ Allows admin trial management
- ✅ Follows Apple's best practices

**Next Steps:**
1. Add the Swift files to Xcode (see Step 1 above)
2. Build and test in simulator
3. Configure App Store Connect when ready to publish
4. Deploy backend changes to Azure

