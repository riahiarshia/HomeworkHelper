# Apple Sign-In Name Behavior

## 🍎 **How Apple Sign-In Works with Names**

### **Important: Apple Privacy Design**

Apple **only provides the user's full name on the FIRST sign-in ever**. After that:
- ✅ **First time**: Full name provided (e.g., "John Smith")
- ❌ **All subsequent times**: Name is `null`

This is by design for user privacy.

## 📧 **Email Behavior**

Users can choose:
- **Share My Email**: Real email (e.g., `john@gmail.com`)
- **Hide My Email**: Private relay (e.g., `xyz123@privaterelay.appleid.com`)

## 🧪 **Testing Fresh Sign-In**

To test with a real name again:

### **Method 1: Delete Apple Sign-In Authorization (Simulator)**
1. **Settings** → **Apple ID** → **Password & Security**
2. **Apps Using Your Apple ID** → Find your app
3. **Stop Using Apple ID**
4. **Sign in again** → Name will be provided

### **Method 2: Reset Simulator**
1. **Simulator** → **Device** → **Erase All Content and Settings**
2. **Sign into Apple ID** again
3. **Test app** → Name will be provided

### **Method 3: Test User Accounts**
Use Apple's test accounts (sandbox):
- Create in App Store Connect
- These can be reset easily

## 🔧 **Current Behavior in Your App**

### **First Sign-In:**
```
✅ Name provided: "John Smith"
✅ Database stores: username = "John Smith"
```

### **Subsequent Sign-Ins:**
```
❌ Name = null (Apple doesn't send it)
✅ Database keeps: username = "John Smith" (unchanged)
```

### **If Username is Generic:**
The backend now updates username if:
- Current username is "Apple User", OR
- Current username contains "@privaterelay", OR
- Username is empty

AND a real name is provided in the current login.

## 📊 **Your Current User**

Email: `000757.afd07240d1514dfaa8b019bb4f89d2fe.2209@privaterelay.appleid.com`
Username: `Apple User`

**This happened because:**
1. This is a subsequent login (not the first time ever)
2. Apple didn't send the real name
3. Our code used the fallback "Apple User"

## ✅ **Solutions**

### **Option 1: Ask User for Name in Onboarding**
After Apple Sign-In, show onboarding:
```swift
"What should we call you?"
[Text Input: Enter your name]
```

This is what most apps do (including Twitter, Instagram, etc.)

### **Option 2: Test with Fresh Account**
Delete the app from "Apps Using Your Apple ID" in Settings and sign in again.

### **Option 3: Manual Database Update**
For this specific user:
```sql
UPDATE users 
SET username = 'Real Name Here' 
WHERE email = '000757.afd07240d1514dfaa8b019bb4f89d2fe.2209@privaterelay.appleid.com';
```

## 🎯 **Recommendation**

**Use onboarding to collect the name** - This is the standard approach because:
- ✅ Works every time (not just first sign-in)
- ✅ User can choose their display name
- ✅ Works with Apple's privacy model
- ✅ Better UX than relying on Apple's name

**Your app already has onboarding!** Just make sure it asks for name even after Apple Sign-In.

