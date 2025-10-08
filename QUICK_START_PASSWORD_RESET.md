# 🚀 Password Reset - Quick Start (6 Minutes)

## Status: ✅ 100% Code Complete - Just Needs Deployment

Everything is implemented! Just follow these 4 steps:

---

## Step 1: Sign Up for SendGrid (2 minutes)

1. Go to **https://sendgrid.com/**
2. Click **"Start for Free"**
3. Create account (free - 100 emails/day)
4. Verify your email address
5. Go to **Settings** → **API Keys**
6. Click **"Create API Key"**
7. Name: `HomeworkHelper`
8. Permission: **"Full Access"**
9. **Copy the key** (save it somewhere safe!)

---

## Step 2: Verify Sender Email (1 minute)

1. In SendGrid, go to **Settings** → **Sender Authentication**
2. Click **"Verify a Single Sender"**
3. Fill in:
   - From Name: `HomeworkHelper`
   - From Email: Your email (or `noreply@yourdomain.com`)
   - Reply To: Your support email
4. Click **"Create"**
5. **Check your email** and click verify link
6. ✅ Done!

---

## Step 3: Configure Azure (1 minute)

1. Go to **Azure Portal** → Your App Service
2. Click **Configuration** → **Application settings**
3. Click **"+ New application setting"** for each:

   ```
   Name: SENDGRID_API_KEY
   Value: [paste your API key from Step 1]
   ```

   ```
   Name: SENDGRID_FROM_EMAIL  
   Value: [your verified email from Step 2]
   ```

   ```
   Name: APP_URL
   Value: homeworkhelper://
   ```

4. Click **"Save"** at top
5. Click **"Restart"**

---

## Step 4: Run Database Migration (2 minutes)

**Option A - From Your Computer:**

```bash
cd /Users/ar616n/Documents/ios-app/ios-app/backend
export DATABASE_URL="your_azure_postgresql_url"
./deploy-password-reset.sh
```

**Option B - Azure Cloud Shell:**

```bash
# In Azure Portal, open Cloud Shell
psql "$DATABASE_URL" -f backend/database/password-reset-migration.sql
```

**Option C - Azure Portal:**

1. Go to your **Azure Database for PostgreSQL**
2. Click **Query editor (preview)**
3. Open file: `backend/database/password-reset-migration.sql`
4. Copy all SQL
5. Paste and click **"Run"**
6. ✅ Should see success message

---

## 🧪 Test It!

### Test 1: Request Password Reset

```bash
curl -X POST https://homework-helper-api.azurewebsites.net/api/auth/request-reset \
  -H "Content-Type: application/json" \
  -d '{"email":"YOUR_EMAIL@gmail.com"}'
```

**Expected:** `{"success":true,"message":"If that email exists..."}`

### Test 2: Check Your Email

- ✉️ Should receive email in < 10 seconds
- 📧 Subject: "Reset Your HomeworkHelper Password"
- 🎨 Beautiful blue gradient header
- 🔵 Blue "Reset Password" button

### Test 3: Click Link

- Should open your iOS app
- Should show password reset form
- Enter new password
- Should show success!

### Test 4: Sign In

- Use new password
- Should work! 🎉

---

## ✅ Done!

That's it! Password reset is now live.

**What you have:**
- ✅ Professional email templates
- ✅ Secure 32-byte tokens
- ✅ 1-hour expiration
- ✅ One-time use tokens
- ✅ Beautiful iOS UI
- ✅ Deep linking
- ✅ Free (100 emails/day)

---

## 📊 Monitor Usage

**SendGrid Dashboard:**
https://app.sendgrid.com/

See:
- Emails sent today
- Delivery rate
- Bounces
- Spam reports

---

## 🐛 Troubleshoot

**Email not arriving?**
1. Check spam folder
2. Check SendGrid Activity Feed
3. Check Azure App Service logs

**Token error?**
1. Link expires in 1 hour
2. Can only use once
3. Check database: `SELECT * FROM password_reset_tokens;`

**Deep link not working?**
1. Make sure app is installed
2. Try in Safari: `homeworkhelper://reset-password?token=test`

---

## 📚 Full Documentation

For more details, see:
- `SETUP_PASSWORD_RESET.md` - Detailed setup guide
- `BACKEND_PASSWORD_RESET_COMPLETE.md` - Backend overview  
- `PASSWORD_RESET_IMPLEMENTATION_FINAL.md` - Complete summary

---

## 💰 Cost

**SendGrid Free Tier:**
- 100 emails/day
- Forever free
- Perfect for getting started

**When you grow:**
- $19.95/month = 50,000 emails
- $89.95/month = 100,000 emails

---

## 🎉 Success!

You now have a production-ready password reset system!

**Next time someone forgets their password:**
1. They tap "Forgot Password?"
2. Enter email
3. Receive beautiful email
4. Click link
5. Reset password
6. Sign in!

All in under 2 minutes for your user. ⚡️

---

**Questions?** Check the documentation files or Azure logs!

**Ready to deploy?** Just follow the 4 steps above! 🚀

