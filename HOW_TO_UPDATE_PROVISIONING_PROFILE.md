# How to Update Your Provisioning Profile

## 📱 What is a Provisioning Profile?

A provisioning profile is a file that links:
- Your developer certificate
- Your App ID (com.homeworkhelper.app)
- Your device(s)
- The capabilities your app uses (like Sign In with Apple)

When you enable a new capability (like Apple Sign In), the provisioning profile needs to be updated to include that capability.

---

## ✅ EASIEST METHOD: Let Xcode Do It Automatically

### Step 1: Enable Apple Sign In Capability in Xcode
1. Open your project in Xcode
2. Select the "HomeworkHelper" project in the navigator
3. Select the "HomeworkHelper" target
4. Click on the "Signing & Capabilities" tab
5. Click the "+ Capability" button
6. Search for and add "Sign In with Apple"

### Step 2: Let Xcode Update the Profile Automatically
**If you're using "Automatically manage signing" (recommended for development):**

1. In the "Signing & Capabilities" tab, make sure **"Automatically manage signing"** is checked
2. Select your Team from the dropdown
3. Xcode will automatically:
   - ✅ Register the App ID on Apple Developer Portal (if needed)
   - ✅ Enable "Sign In with Apple" for your App ID
   - ✅ Create/update the provisioning profile
   - ✅ Download and install the new profile

**You'll see a message like:** "Successfully registered bundle identifier" or "Provisioning profile updated"

**That's it!** Xcode handles everything automatically. ✨

---

## 🔧 MANUAL METHOD: Update on Apple Developer Console

**Only do this if you're NOT using automatic signing, or if automatic fails.**

### Step 1: Enable Sign In with Apple for Your App ID

1. Go to [developer.apple.com](https://developer.apple.com)
2. Sign in with your Apple Developer account
3. Go to: **Certificates, Identifiers & Profiles**
4. Click **Identifiers** in the left sidebar
5. Find and click your App ID: `com.homeworkhelper.app`
   - If it doesn't exist, create it:
     - Click the "+" button
     - Select "App IDs"
     - Fill in:
       - Description: "Homework Helper"
       - Bundle ID: `com.homeworkhelper.app`
     - Click "Continue" and "Register"
6. In the Capabilities list, find **"Sign In with Apple"**
7. Check the box to enable it
8. Click **"Save"** at the top right

### Step 2: Update or Create Provisioning Profile

1. Still in **Certificates, Identifiers & Profiles**
2. Click **Profiles** in the left sidebar
3. Find your existing profile for `com.homeworkhelper.app`
   - Look for "iOS App Development" or "iOS App Distribution" profile
4. **Option A - Edit Existing Profile:**
   - Click on the profile name
   - Click "Edit"
   - The new capability (Sign In with Apple) should now be included
   - Click "Generate" or "Save"
   - Download the updated profile
5. **Option B - Create New Profile:**
   - Click the "+" button
   - Select profile type:
     - **For Testing/Development:** iOS App Development
     - **For TestFlight/App Store:** App Store Distribution
   - Select your App ID: `com.homeworkhelper.app`
   - Select your certificate
   - Select devices (for development profiles)
   - Give it a name (e.g., "HomeworkHelper Development")
   - Click "Generate"
   - Download the profile

### Step 3: Install the Profile in Xcode

1. **Option A - Double-click the downloaded profile**
   - Just double-click the `.mobileprovision` file
   - Xcode will import it automatically

2. **Option B - Manual import:**
   - Open Xcode
   - Go to: Xcode > Settings (or Preferences)
   - Click on "Accounts" tab
   - Select your Apple ID
   - Click "Download Manual Profiles"

3. **Verify it's installed:**
   - In your project's "Signing & Capabilities" tab
   - Under "Provisioning Profile", you should see the new/updated profile
   - The status should show "Xcode Managed Profile" or your custom profile name

---

## 🧪 How to Verify It Worked

### Check 1: In Xcode
1. Go to "Signing & Capabilities" tab
2. You should see **"Sign In with Apple"** listed as a capability
3. Under "Signing", there should be NO errors or warnings
4. You should see:
   - ✅ Team: [Your Team Name]
   - ✅ Provisioning Profile: [Profile Name]
   - ✅ Signing Certificate: [Your Certificate]

### Check 2: Check the Entitlements File
1. Your `HomeworkHelper.entitlements` file should contain:
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```
✅ This is already in your project!

### Check 3: Build and Run
1. Build your project (⌘+B)
2. Should build without signing errors
3. Run on a simulator or device
4. Apple Sign In should work with real authentication (not the fallback)

---

## ⚠️ Common Issues and Solutions

### Issue 1: "Failed to register bundle identifier"
**Solution:**
- Your Apple Developer account might not have permission
- Make sure you're signed in with an account that has "Admin" or "App Manager" role
- Contact your team admin if you're part of a team

### Issue 2: "No signing certificate found"
**Solution:**
- You need a valid development certificate
- Go to Xcode > Settings > Accounts
- Select your Apple ID
- Click "Manage Certificates"
- Click "+" and create an "Apple Development" certificate

### Issue 3: "Provisioning profile doesn't include Sign In with Apple"
**Solution:**
- Delete the old provisioning profile:
  - Go to ~/Library/MobileDevice/Provisioning Profiles/
  - Delete old profiles
- In Xcode, uncheck "Automatically manage signing"
- Check it again - Xcode will generate a fresh profile

### Issue 4: "The operation couldn't be completed. (error 1000)"
**This is the error you were seeing!**

**Solution:**
- The provisioning profile doesn't have Sign In with Apple capability
- Follow the steps above to enable it
- Make sure to download and install the updated profile

---

## 🎯 Recommended Approach for Your Project

Since you're developing and testing, I recommend:

### ✅ Use Automatic Signing (Easiest)

1. **In Xcode:**
   - Signing & Capabilities tab
   - ✅ Check "Automatically manage signing"
   - Select your Team
   - Add "Sign In with Apple" capability
   - **Xcode handles everything else automatically!**

2. **Build and test:**
   - No need to manually download or install profiles
   - Xcode keeps everything in sync

### If Automatic Signing Fails:

Only then use the manual method above. But 95% of the time, automatic signing works perfectly for development.

---

## 📝 Quick Checklist

**Before testing Apple Sign In:**

- [ ] Apple Developer account is active
- [ ] Signed in to Xcode with Apple ID (Xcode > Settings > Accounts)
- [ ] Team selected in project settings
- [ ] "Automatically manage signing" is checked (recommended)
- [ ] "Sign In with Apple" capability added in Xcode
- [ ] No signing errors in "Signing & Capabilities" tab
- [ ] Project builds successfully
- [ ] Entitlements file has Apple Sign In capability
- [ ] Testing on a real device OR simulator with signed-in iCloud account

**Note:** Apple Sign In works in the simulator if you're signed in to iCloud in the simulator. Go to Settings > Sign in to your Apple Account in the simulator.

---

## 🚀 TL;DR - Fastest Path

**For Development/Testing:**

1. Open Xcode
2. Signing & Capabilities tab
3. ✅ Check "Automatically manage signing"
4. Select your Team
5. Click "+ Capability"
6. Add "Sign In with Apple"
7. **Done!** Xcode updates the provisioning profile automatically

**That's literally it.** No need to manually download or update anything. Xcode handles it all. ✨

---

## 💡 Fun Fact

Every time you:
- Add a capability in Xcode
- Change your bundle ID
- Add a device
- Update your certificate

Xcode automatically updates your provisioning profile if you have "Automatically manage signing" enabled. It's magic! 🪄

---

**Next Steps:** Just enable the capability in Xcode, and you're ready to test Apple Sign In with your real Apple ID! 🎉


