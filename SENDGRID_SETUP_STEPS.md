# 📧 SendGrid Setup - Step by Step

## Step 1: Sign Up for SendGrid (2 minutes)

### Go to SendGrid:
🌐 **https://signup.sendgrid.com/**

### Sign Up (FREE):
1. Click **"Start for Free"** or **"Get Started"**
2. Fill in:
   - **Email:** Your email (e.g., a.r@arshia.com)
   - **Password:** Create a password
   - **Company Name:** HomeworkHelper (or your company)
3. Click **"Create Account"**
4. **Verify your email** - Check inbox and click verification link
5. ✅ Account created!

---

## Step 2: Get Your API Key (1 minute)

### In SendGrid Dashboard:

1. After logging in, go to **Settings** (left sidebar)
2. Click **"API Keys"**
3. Click **"Create API Key"** button
4. Fill in:
   - **API Key Name:** `HomeworkHelper Production`
   - **API Key Permissions:** Select **"Full Access"**
5. Click **"Create & View"**
6. **📋 COPY THE KEY NOW!** (You won't see it again!)
7. Save it somewhere safe (e.g., Notes app)

**Your API key will look like:**
```
SG.abc123XYZ...very_long_string...xyz789
```

---

## Step 3: Verify Sender Email (2 minutes)

### Verify support_homework@arshia.com:

1. In SendGrid, go to **Settings** → **Sender Authentication**
2. Click **"Verify a Single Sender"**
3. Fill in the form:

```
From Name: HomeworkHelper
From Email Address: support_homework@arshia.com
Reply To: support_homework@arshia.com

Address: Your address
City: Your city
State/Province: Your state
Zip Code: Your zip
Country: United States (or your country)

Nickname: HomeworkHelper Support
```

4. Click **"Create"**
5. **Check your email** at `support_homework@arshia.com`
6. **Click the verification link** in the email
7. ✅ Email verified!

**Important:** You must have access to the email `support_homework@arshia.com` to verify it!

---

## Step 4: Configure Azure (1 minute)

I'll do this for you! Just provide me with the API key from Step 2.

---

## ⚠️ Important Note

**You need access to `support_homework@arshia.com` email to verify it!**

### Options:

**Option A - If you own arshia.com domain:**
- Set up email forwarding or mailbox for `support_homework@arshia.com`
- Then verify it in SendGrid

**Option B - Use a different email temporarily:**
- Use your personal email for testing
- For example: `your.name@gmail.com`
- I can update the backend to use that instead

**Option C - Use SendGrid's sandbox mode:**
- Can send to verified test emails only
- Good for testing before domain setup

Which option works best for you?

---

## 📋 Checklist

- [ ] Sign up for SendGrid
- [ ] Get API key (save it!)
- [ ] Decide on sender email strategy
- [ ] Verify sender email in SendGrid
- [ ] Provide API key to me
- [ ] I'll configure Azure
- [ ] Test email sending!

---

**Which option do you want for the sender email?**

A) Set up `support_homework@arshia.com` (need domain access)
B) Use your personal email for testing (easiest)
C) Use SendGrid sandbox mode

Let me know and I'll help you proceed! 🚀

