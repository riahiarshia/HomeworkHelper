# 🧪 Test Password Reset in iOS Simulator

## Test User Credentials

**Email:** `a.r@arshia.com`  
**Current Password:** `testpass123`  
**User ID:** `496e3539-4cdc-48a6-a2c8-8779ebd4afe0`

---

## 🎬 Test Scenario: Password Reset Flow

### Part 1: Request Password Reset (In iOS App)

1. **Build and run** the app in Xcode simulator:
   ```bash
   # From Xcode: Product → Run (⌘R)
   # Or from terminal:
   cd /Users/ar616n/Documents/ios-app/ios-app
   xcodebuild -project HomeworkHelper.xcodeproj -scheme HomeworkHelper -sdk iphonesimulator
   ```

2. **In the app:**
   - Tap "Sign In with Email"
   - Tap "Forgot Password?"
   - Enter email: `a.r@arshia.com`
   - Tap "Send Reset Email"

3. **Expected Result:**
   - ✅ Success message appears
   - ⚠️ Email won't arrive (SendGrid not configured)
   - ✅ Token is saved in database

---

### Part 2: Simulate Email Link (Manual Deep Link Test)

Since emails don't send yet, we'll manually trigger the deep link:

**Your Reset Token:**
```
b782ff89b0f681aaef354861fba9d9e87598785ed944c8814abeec26b6647fd1
```

**Your Deep Link:**
```
homeworkhelper://reset-password?token=b782ff89b0f681aaef354861fba9d9e87598785ed944c8814abeec26b6647fd1
```

#### Option A: Test in Simulator Using Safari

1. **Open Safari in the iOS Simulator**
2. **Paste this URL in the address bar:**
   ```
   homeworkhelper://reset-password?token=b782ff89b0f681aaef354861fba9d9e87598785ed944c8814abeec26b6647fd1
   ```
3. **Press Go**
4. **Simulator will ask:** "Open in HomeworkHelper?"
5. **Tap "Open"**
6. ✅ App should open with password reset form!

#### Option B: Test Using Terminal Command

```bash
# This opens the simulator and triggers the deep link
xcrun simctl openurl booted "homeworkhelper://reset-password?token=b782ff89b0f681aaef354861fba9d9e87598785ed944c8814abeec26b6647fd1"
```

---

### Part 3: Reset Password (In App)

Once the reset form appears:

1. **Enter new password:** `newpass123`
2. **Confirm password:** `newpass123`
3. **Tap "Reset Password"**

**Expected Result:**
- ✅ Loading indicator appears
- ✅ API call to backend
- ✅ Password updated in database
- ✅ Success message appears
- ✅ Form dismisses

---

### Part 4: Sign In with New Password

1. **Return to sign-in screen**
2. **Enter:**
   - Email: `a.r@arshia.com`
   - Password: `newpass123` (your NEW password)
3. **Tap "Sign In"**

**Expected Result:**
- ✅ Successfully signed in!
- ✅ Old password (`testpass123`) no longer works
- ✅ New password (`newpass123`) works!

---

## 🎯 Quick Test Commands

### Terminal Commands to Test in Simulator:

```bash
# 1. Open simulator (if not already open)
open -a Simulator

# 2. Build and run app
cd /Users/ar616n/Documents/ios-app/ios-app
xcodebuild -project HomeworkHelper.xcodeproj \
  -scheme HomeworkHelper \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  clean build

# 3. Trigger deep link (simulates clicking email link)
xcrun simctl openurl booted "homeworkhelper://reset-password?token=b782ff89b0f681aaef354861fba9d9e87598785ed944c8814abeec26b6647fd1"
```

---

## 🧪 Test the Backend Directly

### Test 1: Request Reset
```bash
curl -X POST https://homework-helper-api.azurewebsites.net/api/auth/request-reset \
  -H "Content-Type: application/json" \
  -d '{"email":"a.r@arshia.com"}'
```

**Expected:**
```json
{
  "success": true,
  "message": "If that email exists in our system, a reset link has been sent"
}
```

---

### Test 2: Verify Token
```bash
curl "https://homework-helper-api.azurewebsites.net/api/auth/verify-reset-token?token=b782ff89b0f681aaef354861fba9d9e87598785ed944c8814abeec26b6647fd1"
```

**Expected:**
```json
{
  "valid": true
}
```

---

### Test 3: Reset Password
```bash
curl -X POST https://homework-helper-api.azurewebsites.net/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "token": "b782ff89b0f681aaef354861fba9d9e87598785ed944c8814abeec26b6647fd1",
    "newPassword": "newpass123"
  }'
```

**Expected:**
```json
{
  "success": true,
  "message": "Password successfully reset"
}
```

---

### Test 4: Login with New Password
```bash
curl -X POST https://homework-helper-api.azurewebsites.net/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "a.r@arshia.com",
    "password": "newpass123"
  }'
```

**Expected:**
```json
{
  "userId": "496e3539-4cdc-48a6-a2c8-8779ebd4afe0",
  "email": "a.r@arshia.com",
  "token": "jwt_token...",
  "subscription_status": "trial"
}
```

---

## 📱 Full iOS Simulator Test Flow

### Step-by-Step:

**1. Build & Run App**
```bash
cd /Users/ar616n/Documents/ios-app/ios-app
open -a Xcode HomeworkHelper.xcodeproj
# Press ⌘R to run
```

**2. Request Password Reset in App**
- Tap "Sign In with Email"
- Tap "Forgot Password?"
- Enter: `a.r@arshia.com`
- Tap "Send Reset Email"
- ✅ Should see success (but no email arrives yet)

**3. Manually Trigger Deep Link**

Open Terminal and run:
```bash
xcrun simctl openurl booted "homeworkhelper://reset-password?token=b782ff89b0f681aaef354861fba9d9e87598785ed944c8814abeec26b6647fd1"
```

**4. Reset Password in App**
- App should open reset form automatically
- Enter new password: `newpass123`
- Confirm: `newpass123`
- Tap "Reset Password"
- ✅ Should see success!

**5. Sign In with New Password**
- Return to sign-in
- Email: `a.r@arshia.com`
- Password: `newpass123`
- ✅ Successfully signed in!

---

## 🔄 Reset the Test (Start Over)

To test again with a fresh token:

```bash
# 1. Request new reset token
curl -X POST https://homework-helper-api.azurewebsites.net/api/auth/request-reset \
  -H "Content-Type: application/json" \
  -d '{"email":"a.r@arshia.com"}'

# 2. Get the new token
node -e "
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: 'postgres://dbadmin:HomeworkHelper2025SecurePass@homework-helper-db.postgres.database.azure.com/homework_helper?sslmode=require'
});
pool.query(\`
  SELECT token FROM password_reset_tokens 
  WHERE user_id = '496e3539-4cdc-48a6-a2c8-8779ebd4afe0'
  AND used = FALSE AND expires_at > NOW()
  ORDER BY created_at DESC LIMIT 1
\`).then(r => {
  if (r.rows[0]) {
    console.log('New token:', r.rows[0].token);
    console.log('Deep link: homeworkhelper://reset-password?token=' + r.rows[0].token);
  }
  process.exit(0);
});
"

# 3. Use the new token in the deep link
```

---

## 🎥 What You Should See

### In the iOS Simulator:

1. **Forgot Password Screen:**
   - Text field with "a.r@arshia.com"
   - "Send Reset Email" button
   - When tapped → Success message or error

2. **After Deep Link:**
   - App opens to reset password form
   - Shows lock icon
   - "Reset Your Password" title
   - New password field
   - Confirm password field
   - Password requirements
   - Blue "Reset Password" button

3. **After Reset:**
   - Success alert!
   - "Your password has been successfully reset"
   - Form dismisses automatically
   - Can sign in with new password

---

## 🐛 Troubleshooting

**App doesn't open from deep link?**
```bash
# Make sure app is installed and running
xcrun simctl list | grep "Booted"

# Try this format:
xcrun simctl openurl booted "homeworkhelper://reset-password?token=YOUR_TOKEN"
```

**"Invalid token" error?**
- Token expires in 1 hour
- Can only be used once
- Request a new token with curl command above

**App crashes?**
- Check Xcode console for errors
- Make sure `ResetPasswordView.swift` is in project
- Rebuild: ⌘⇧K then ⌘R

---

## ✅ Success Indicators

When working correctly:

✅ Forgot password → Success message (no 404!)  
✅ Deep link → Opens reset password form  
✅ Reset password → Success alert  
✅ Sign in → Works with new password  
✅ Old password → Rejected  

---

## 📊 Test Results Verification

After testing, check:

```bash
# Check tokens in database
node -e "
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: 'postgres://dbadmin:HomeworkHelper2025SecurePass@homework-helper-db.postgres.database.azure.com/homework_helper?sslmode=require'
});
pool.query(\`
  SELECT token, used, used_at, expires_at 
  FROM password_reset_tokens 
  WHERE user_id = '496e3539-4cdc-48a6-a2c8-8779ebd4afe0'
  ORDER BY created_at DESC
\`).then(r => {
  console.log('Password Reset Tokens for a.r@arshia.com:');
  r.rows.forEach(t => {
    console.log('- Token:', t.token.substring(0, 20) + '...');
    console.log('  Used:', t.used);
    console.log('  Used at:', t.used_at || 'Not used');
    console.log('  Expires:', t.expires_at);
    console.log('');
  });
  process.exit(0);
});
"
```

---

## 🎯 Ready to Test?

**Just run this command to trigger the reset form:**

```bash
xcrun simctl openurl booted "homeworkhelper://reset-password?token=b782ff89b0f681aaef354861fba9d9e87598785ed944c8814abeec26b6647fd1"
```

The app will open the password reset screen! 🚀

---

**Test User:**
- Email: `a.r@arshia.com`
- Old Password: `testpass123`
- New Password: `newpass123` (or whatever you choose)

**Token Valid For:** 1 hour  
**Token Expires:** 2025-10-07 07:23:25 UTC

Go ahead and test! 🎉

