# ⚡ Quick Fix - Add Files to Xcode (30 seconds)

## ✅ I just opened Xcode for you!

Now follow these simple steps:

---

## Step 1: Add AuthenticationService.swift

1. In Xcode's **left sidebar** (Project Navigator), find the **"Services"** folder
2. **Right-click** on "Services" 
3. Select **"Add Files to 'HomeworkHelper'..."**
4. Navigate to: `HomeworkHelper/Services/`
5. Select **`AuthenticationService.swift`**
6. Make sure these boxes are checked:
   - ✅ **Copy items if needed**
   - ✅ **HomeworkHelper** (under "Add to targets")
7. Click **"Add"**

---

## Step 2: Add AuthenticationView.swift

1. In the **left sidebar**, find **"Views"** → **"Authentication"** folder
2. **Right-click** on "Authentication"
3. Select **"Add Files to 'HomeworkHelper'..."**
4. Navigate to: `HomeworkHelper/Views/Authentication/`
5. Select **`AuthenticationView.swift`**
6. Make sure these boxes are checked:
   - ✅ **Copy items if needed**
   - ✅ **HomeworkHelper** (under "Add to targets")
7. Click **"Add"**

---

## Step 3: Build

Press **⌘ + B** (Command + B) to build

---

## ✅ Done!

The errors should be gone and your app should build successfully!

---

## 🎯 What You Should See After Building:

- ✅ No more "Cannot find 'AuthenticationService'" error
- ✅ No more "Cannot find 'AuthenticationView'" error
- ✅ Build succeeds
- ✅ App shows Google Sign-In screen when you run it

---

## 🔄 Alternative: If You Don't See "Add Files" Option

Try this instead:

1. **Drag and drop** the files:
   - Drag `AuthenticationService.swift` from Finder → into Xcode's "Services" folder
   - Drag `AuthenticationView.swift` from Finder → into Xcode's "Authentication" folder
2. When prompted, make sure:
   - ✅ **Copy items if needed**
   - ✅ **HomeworkHelper** target is checked
3. Click **"Finish"**

---

## 📁 File Locations (if you need to find them):

```
/Users/ar616n/Documents/ios-app/ios-app/HomeworkHelper/Services/AuthenticationService.swift
/Users/ar616n/Documents/ios-app/ios-app/HomeworkHelper/Views/Authentication/AuthenticationView.swift
```

---

That's it! Once you add these two files, everything will work. 🚀

