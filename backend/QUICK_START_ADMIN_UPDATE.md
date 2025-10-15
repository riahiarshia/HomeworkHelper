# 🚀 QUICK START: Update Admin Password in 3 Steps

## New Admin Credentials
- **Email:** `support_homework@arshia.com`
- **Password:** `A@dMin%f$7`

---

## 📦 Step 1: Get the File Ready

The file you need is already here:
```
backend/update-admin-credentials.js
```

---

## 🌐 Step 2: Upload to Azure (Choose one method)

### 🎯 EASIEST METHOD: Drag & Drop in Kudu

1. **Open Kudu Console:**
   - Go to: https://YOUR-APP-NAME.scm.azurewebsites.net
   - (Replace YOUR-APP-NAME with your Azure App Service name, e.g., `homework-helper-api`)
   
2. **Navigate to folder:**
   - Click **"Debug console"** → **"CMD"**
   - Navigate to: `/site/wwwroot/`

3. **Upload file:**
   - **Drag and drop** `update-admin-credentials.js` into the file browser area
   - Or use the **"+"** button to upload

✅ File uploaded!

---

## ▶️ Step 3: Run the Script

In the same Kudu console (at the bottom command prompt):

```bash
cd /home/site/wwwroot
node update-admin-credentials.js
```

**Expected output:**
```
✅ Admin credentials updated successfully!

📋 Updated Admin Details:
   Username: admin
   Email: support_homework@arshia.com
   Role: super_admin

🔑 New Password: A@dMin%f$7
```

---

## ✅ Step 4: Test Login

Go to: `https://your-app-name.azurewebsites.net/admin/`

Login with:
- **Username:** `admin`
- **Password:** `A@dMin%f$7`

🎉 **Done!**

---

## 📍 Quick Links

### Find Your App Name
Azure Portal → All Resources → Look for your App Service

### Access Kudu Directly
```
https://YOUR-APP-NAME.scm.azurewebsites.net
```

### Access via Azure Portal
Azure Portal → Your App Service → Development Tools → Advanced Tools → Go

---

## ❓ Having Trouble?

**Can't find Kudu?**
- Azure Portal → Your App Service → "Advanced Tools" → Click "Go"

**Upload not working?**
- Try refreshing the page
- Make sure you're in `/site/wwwroot/` folder

**Script error?**
- Check the detailed instructions in `AZURE_CONSOLE_INSTRUCTIONS.md`
- Verify DATABASE_URL is set in App Service Configuration

---

## 🔍 What Does the Script Do?

The script safely:
1. Connects to your Azure PostgreSQL database
2. Hashes the new password using bcrypt (secure)
3. Updates the admin email and password hash
4. Confirms the update

**Security:** Your password is never stored in plain text - only the secure hash!



