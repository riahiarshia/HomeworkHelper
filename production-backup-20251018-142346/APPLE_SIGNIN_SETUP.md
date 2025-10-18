# Apple Sign-In Setup Guide

## ✅ What's Already Done
- ✅ Apple Sign-In button added to AuthenticationView
- ✅ Backend endpoint ready (`/api/auth/apple`)
- ✅ Entitlements file created (`HomeworkHelper.entitlements`)

## 🔧 Required Setup in Xcode

### Step 1: Add Entitlements File to Xcode
1. **Open** `HomeworkHelper.xcodeproj` in Xcode
2. **Find** the `HomeworkHelper.entitlements` file in Finder (it's in the HomeworkHelper folder)
3. **Drag** it into Xcode's Project Navigator (left sidebar)
4. **Make sure** "Copy items if needed" is checked
5. **Click** "Finish"

### Step 2: Enable Sign in with Apple Capability
1. **Select** the `HomeworkHelper` project in Project Navigator
2. **Select** the `HomeworkHelper` target
3. **Go to** the "Signing & Capabilities" tab
4. **Click** the "+ Capability" button
5. **Search** for "Sign in with Apple"
6. **Double-click** to add it

### Step 3: Verify Entitlements Are Linked
1. **Stay in** "Signing & Capabilities" tab
2. **Check** that you see "Sign in with Apple" capability listed
3. **Scroll down** in the same tab
4. **Look for** "Code Signing Entitlements" field
5. **It should show**: `HomeworkHelper/HomeworkHelper.entitlements`
6. **If it doesn't**, manually set it:
   - Under "Build Settings" tab
   - Search for "Code Signing Entitlements"
   - Set value to: `HomeworkHelper/HomeworkHelper.entitlements`

### Step 4: Test in Simulator
1. **Build and Run** (⌘ + R)
2. **Tap** "Sign in with Apple" button
3. **Should see** Apple Sign-In dialog

## 🐛 Troubleshooting

### Error Code 1000
This means one of:
- ✅ **FIXED**: Missing entitlements file
- User canceled the sign-in
- Simulator not signed into iCloud

### Error Code 1001
- Missing capability in Xcode
- Follow Step 2 above

### Simulator Issues
- Make sure simulator is signed into Apple ID:
  - **Settings** → **Apple ID** → Sign in
  - Use any Apple ID (can be test account)

## 📱 Production Setup (Later)

When ready for App Store:
1. **Go to** Apple Developer Portal
2. **Select** your app
3. **Enable** "Sign in with Apple" capability
4. **Regenerate** provisioning profile
5. **Download and install** new profile in Xcode

## 🧪 Testing Now

**Quick Test:**
1. Follow Steps 1-3 above
2. Run app in simulator
3. Try Apple Sign-In
4. It should work!

**Test Account:**
- Use your own Apple ID in simulator
- Or create a test Apple ID
- The app will connect to the live backend on Azure

## ✅ Success Indicators

When working, you should see:
```
✅ Apple Sign-In successful: [userIdentifier]
   Email: [email or private relay]
   Name: [name]
📤 Sending Apple authentication request to backend...
📥 Backend Apple response: {...}
✅ Apple authentication successful!
```

If you see these logs, Apple Sign-In is working! 🎉

