# 🔧 Add Authentication Files to Xcode Project

## ❌ Current Issue

Build error: `cannot find 'AuthenticationService' in scope`

**Cause:** The authentication files exist on disk but haven't been added to the Xcode project.

---

## ✅ Quick Fix (2 Minutes)

### Step 1: Open Project in Xcode
```bash
open HomeworkHelper.xcodeproj
```

### Step 2: Add AuthenticationService.swift

1. In Xcode, right-click on the **"Services"** folder (in the Project Navigator on the left)
2. Select **"Add Files to 'HomeworkHelper'..."**
3. Navigate to: `HomeworkHelper/Services/AuthenticationService.swift`
4. Make sure these are checked:
   - ✅ **"Copy items if needed"**
   - ✅ **"HomeworkHelper"** target
5. Click **"Add"**

### Step 3: Add AuthenticationView.swift

1. Right-click on **"Views"** → **"Authentication"** folder
2. Select **"Add Files to 'HomeworkHelper'..."**
3. Navigate to: `HomeworkHelper/Views/Authentication/AuthenticationView.swift`
4. Make sure these are checked:
   - ✅ **"Copy items if needed"**
   - ✅ **"HomeworkHelper"** target
5. Click **"Add"**

### Step 4: Verify GoogleService-Info.plist

1. Check if `GoogleService-Info.plist` is in the project navigator
2. If NOT:
   - Right-click **"HomeworkHelper"** folder
   - Select **"Add Files to 'HomeworkHelper'..."**
   - Navigate to: `GoogleService-Info.plist` (root of HomeworkHelper folder)
   - ✅ Check **"Copy items if needed"**
   - ✅ Check **"HomeworkHelper"** target
   - Click **"Add"**

### Step 5: Clean and Build

1. **Clean Build Folder**: **⌘ + Shift + K**
2. **Build**: **⌘ + B**

---

## 📝 Files That Need to Be Added

These files already exist on disk and just need to be added to Xcode:

- ✅ `HomeworkHelper/Services/AuthenticationService.swift` (NEW)
- ✅ `HomeworkHelper/Views/Authentication/AuthenticationView.swift` (NEW)  
- ✅ `GoogleService-Info.plist` (if not already added)

These files are already in Xcode:
- ✅ `HomeworkHelper/Models/User.swift` (UPDATED)
- ✅ `HomeworkHelper/Views/ContentView.swift` (UPDATED)
- ✅ `HomeworkHelper/Views/SettingsView.swift` (UPDATED)
- ✅ `HomeworkHelper/HomeworkHelperApp.swift` (UPDATED)
- ✅ `HomeworkHelper/Services/BackendAPIService.swift` (UPDATED)

---

## 🎯 Expected Result

After adding the files and building:
- ✅ Build succeeds
- ✅ App shows authentication screen on launch
- ✅ "Continue with Google" button works

---

## 🐛 If Still Having Issues

### Google Sign-In Package Not Found?

The package is already added (you can see GoogleSignIn v9.0.0 in the build output), but if you need to verify:

1. In Xcode: **File** → **Packages** → **Manage Package Dependencies**
2. Verify `GoogleSignIn-iOS` is listed
3. If not, add it:
   - Click **+**
   - URL: `https://github.com/google/GoogleSignIn-iOS`
   - Version: 9.0.0 or later

### Files Already in Project?

If Xcode says files are already in the project but build still fails:
1. Clean build folder: **⌘ + Shift + K**
2. Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData/HomeworkHelper-*`
3. Restart Xcode
4. Build again: **⌘ + B**

---

## 🚀 After Successful Build

Run the app (**⌘ + R**) and test:
1. Authentication screen should appear
2. Click "Continue with Google"
3. Sign in with your Google account
4. Complete onboarding
5. Check Settings → Account to see your info

---

**Need help?** Check `GOOGLE_AUTH_IMPLEMENTATION.md` for full documentation.

