# 📧 SendGrid Quick Setup (5 Minutes)

## 🚀 Let's Get Email Working!

Follow these steps EXACTLY and emails will work in 5 minutes:

---

## Step 1: Sign Up (2 minutes)

### Go Here:
**🌐 https://signup.sendgrid.com/**

### Fill In:
- **Email:** a.r@arshia.com (or your email)
- **Password:** (create one)
- Click **"Create Account"**

### Verify Email:
- Check your inbox
- Click verification link
- ✅ Done!

---

## Step 2: Get API Key (1 minute)

### In SendGrid Dashboard:

1. Click **"Settings"** (left sidebar, near bottom)
2. Click **"API Keys"**
3. Click blue **"Create API Key"** button
4. Enter:
   - Name: `HomeworkHelper`
   - Permissions: **"Full Access"** (select from dropdown)
5. Click **"Create & View"**
6. **📋 COPY THE KEY!** (looks like `SG.abc123...`)
7. **SAVE IT!** (paste in Notes app - you won't see it again!)

✅ API Key obtained!

---

## Step 3: Verify Sender Email (2 minutes)

### Option A: Use Your Personal Email (Easiest for Testing)

1. In SendGrid, go to **Settings** → **Sender Authentication**
2. Click **"Verify a Single Sender"**
3. Fill in:
   ```
   From Name: HomeworkHelper
   From Email: a.r@arshia.com (your email)
   Reply To: a.r@arshia.com
   
   Address: 123 Main St
   City: Phoenix
   State: AZ
   Zip: 85001
   Country: United States
   
   Nickname: HomeworkHelper
   ```
4. Click **"Create"**
5. Check email at `a.r@arshia.com`
6. Click verification link
7. ✅ Verified!

### Option B: Use support_homework@arshia.com (If You Own the Domain)

Only if you have access to emails at `@arshia.com` domain:
1. Same as above but use `support_homework@arshia.com`
2. You'll need to receive the verification email

**Which email should we use?** 
- For testing: Use `a.r@arshia.com` (easiest)
- For production: Use `support_homework@arshia.com` (if you have domain)

---

## Step 4: I'll Configure Azure for You!

**Once you have:**
- ✅ SendGrid API Key
- ✅ Verified sender email address

**Give them to me and I'll:**
- Add them to Azure App Service configuration
- Restart the backend
- Test that emails send!

---

## 📝 What I Need From You

Paste here:
```
API Key: SG.abc123... (your key from Step 2)
Sender Email: (the email you verified in Step 3)
```

Then I'll configure Azure automatically! 🚀

---

## 🎯 After Setup

Once configured, when users request password reset:
- ✅ Token generated
- ✅ Email sent via SendGrid
- ✅ Beautiful email arrives in inbox
- ✅ User clicks link
- ✅ Opens app and resets password!

---

**Ready? Go to https://signup.sendgrid.com/ and start Step 1!** 📧

When you have the API key, paste it here and I'll do the rest!

