# 📱 Test Password Reset NOW in Your Simulator

## ✅ Current Status

The password reset form should be **OPEN RIGHT NOW** in your simulator!

---

## 🎯 What to Do in the Simulator

### Step 1: Check the Reset Form
Look for:
- 🔒 Lock rotation icon at top
- "Reset Your Password" title
- "New Password" field
- "Confirm Password" field
- Password requirements text
- Blue "Reset Password" button

### Step 2: Reset the Password

1. **Tap** in "New Password" field
2. **Type:** `newpass123`
3. **Tap** in "Confirm Password" field  
4. **Type:** `newpass123`
5. **Tap** "Reset Password" button

### Step 3: Wait for Success

You should see:
- ✅ Loading indicator appears
- ✅ Success alert: "Your password has been successfully reset"
- ✅ Form automatically dismisses after 2 seconds

### Step 4: Sign In with New Password

1. App returns to auth screen
2. **Tap** "Sign In with Email"
3. **Enter:**
   - Email: `a.r@arshia.com`
   - Password: `newpass123` (NEW password)
4. **Tap** "Sign In"

**Expected Result:** ✅ Successfully signed in!

---

## 🔄 If Form Isn't Open

Run this command to open it:

```bash
xcrun simctl openurl booted "homeworkhelper://reset-password?token=b782ff89b0f681aaef354861fba9d9e87598785ed944c8814abeec26b6647fd1"
```

---

## 🧪 Testing Different Scenarios

### Scenario 1: Valid Password Reset ✅
- Enter matching passwords (6+ characters)
- Button enabled
- Reset works
- Can sign in with new password

### Scenario 2: Passwords Don't Match ❌
- Enter different passwords
- Button stays disabled (gray)
- Can't tap it

### Scenario 3: Password Too Short ❌
- Enter password < 6 characters
- Button stays disabled
- See requirement: "Be at least 6 characters"

### Scenario 4: Old Password No Longer Works ✅
- Try signing in with `testpass123` (old password)
- Should fail: "Invalid credentials"
- New password `newpass123` works

---

## 🎬 Complete Test Flow

```
1. App opens with Auth screen
   ↓
2. Run deep link command
   ↓
3. Reset form appears
   ↓
4. Enter: newpass123 / newpass123
   ↓
5. Tap "Reset Password"
   ↓
6. Loading... then Success!
   ↓
7. Form dismisses
   ↓
8. Sign in with a.r@arshia.com / newpass123
   ↓
9. SUCCESS - You're in! 🎉
```

---

## 🔍 Verify Backend

Check that the token gets marked as used:

```bash
node -e "
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: 'postgres://dbadmin:HomeworkHelper2025SecurePass@homework-helper-db.postgres.database.azure.com/homework_helper?sslmode=require'
});
pool.query(\`
  SELECT token, used, used_at 
  FROM password_reset_tokens 
  WHERE user_id = '496e3539-4cdc-48a6-a2c8-8779ebd4afe0'
  ORDER BY created_at DESC LIMIT 1
\`).then(r => {
  console.log('Latest token status:');
  console.log('Used:', r.rows[0].used);
  console.log('Used at:', r.rows[0].used_at);
  process.exit(0);
});
"
```

**Before reset:** `used: false, used_at: null`  
**After reset:** `used: true, used_at: 2025-10-06 ...`

---

## 🎉 Expected Test Results

When everything works:

✅ Deep link opens reset form  
✅ Form validates password requirements  
✅ Reset button sends request to backend  
✅ Backend updates password in database  
✅ Backend marks token as used  
✅ Success alert appears  
✅ Can sign in with new password  
✅ Old password rejected  

---

## 🐛 Troubleshooting

**Form doesn't open?**
```bash
# Check if app is running
xcrun simctl list | grep Booted

# Try deep link again
xcrun simctl openurl booted "homeworkhelper://reset-password?token=b782ff89b0f681aaef354861fba9d9e87598785ed944c8814abeec26b6647fd1"
```

**"Invalid token" error?**
- Token expires in 1 hour (valid until 2025-10-07 07:23 UTC)
- Can only be used once
- Request new token:
```bash
curl -X POST https://homework-helper-api.azurewebsites.net/api/auth/request-reset \
  -H "Content-Type: application/json" \
  -d '{"email":"a.r@arshia.com"}'
```

**Reset fails?**
- Check Xcode console for errors
- Check backend is responding
- Try logging backend response

---

## 📊 Your Test Token

**Token:** `b782ff89b0f681aaef354861fba9d9e87598785ed944c8814abeec26b6647fd1`  
**Expires:** 2025-10-07 07:23:25 UTC (1 hour)  
**User:** a.r@arshia.com  
**Status:** Ready to use!

---

## 🎯 GO TEST IT NOW!

**The reset form is waiting in your simulator!** 

Just:
1. Look at the simulator
2. Enter new password
3. Tap "Reset Password"
4. Done! 🎉

---

**Test Credentials:**
- Email: `a.r@arshia.com`
- Old: `testpass123`
- New: `newpass123` (or any password you want)

**Token Valid For:** 57 minutes remaining

GO! 🚀

