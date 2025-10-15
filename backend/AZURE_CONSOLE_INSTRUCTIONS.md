# 🚀 Run Admin Update Script in Azure Web App Console

## 📋 Quick Overview

You'll upload the `update-admin-credentials.js` file to your Azure Web App and run it from the Azure SSH console.

---

## ✅ Option 1: Manual Upload via Azure Portal (Easiest)

### Step 1: Access Kudu Console

1. Go to **Azure Portal**: https://portal.azure.com
2. Navigate to your **App Service** (e.g., `homework-helper-api`)
3. In the left menu, find **"Development Tools"** section
4. Click **"Advanced Tools"** (or search for "Kudu")
5. Click **"Go →"** button

This opens the Kudu console in a new tab.

### Step 2: Upload the Script

In the Kudu console:

1. Click the **"Debug console"** menu at the top
2. Choose **"CMD"** or **"PowerShell"**
3. Navigate to: `/site/wwwroot/`
4. You'll see a file browser at the top
5. **Drag and drop** the file `update-admin-credentials.js` into the browser window
   - Or click the **"+"** button to upload

### Step 3: Run the Script

In the same Kudu console, in the command prompt at the bottom:

```bash
cd /home/site/wwwroot
node update-admin-credentials.js
```

You should see:
```
🔐 Updating admin credentials...
⏳ Hashing password...
⏳ Updating database...

✅ Admin credentials updated successfully!

📋 Updated Admin Details:
   Username: admin
   Email: support_homework@arshia.com
   Role: super_admin

🔑 New Password: A@dMin%f$7
```

✅ **Done!** You can now login to the admin portal with the new credentials.

---

## ✅ Option 2: Use Azure SSH Console

### Step 1: Open SSH Console

1. Go to **Azure Portal**: https://portal.azure.com
2. Navigate to your **App Service**
3. In the left menu, click **"SSH"** or **"Console"**
4. Wait for the terminal to load

### Step 2: Upload Script via Portal

You can upload the file first:

**Method A - Via Kudu (see Option 1 above)**

**Method B - Via FTP:**
1. In Azure Portal → App Service → **"Deployment Center"**
2. Note your **FTP credentials**
3. Use any FTP client (FileZilla, Cyberduck, etc.) to upload `update-admin-credentials.js` to `/site/wwwroot/`

### Step 3: Run in SSH Console

```bash
cd /home/site/wwwroot
ls -la update-admin-credentials.js   # Verify file exists
node update-admin-credentials.js
```

---

## ✅ Option 3: Deploy via Azure CLI (For Developers)

If you have Azure CLI installed:

### Step 1: Login to Azure
```bash
az login
```

### Step 2: Run Deployment Script

Update the APP_NAME in `deploy-admin-update.sh` and run:

```bash
chmod +x deploy-admin-update.sh
./deploy-admin-update.sh
```

Then follow the on-screen instructions to run the script in Azure console.

---

## ✅ Option 4: Deploy via Git (If using Git deployment)

If your App Service is connected to a Git repository:

1. **Commit the script:**
   ```bash
   git add update-admin-credentials.js
   git commit -m "Add admin credentials update script"
   git push azure main
   ```

2. **Wait for deployment** to complete

3. **Run in Azure SSH console:**
   ```bash
   cd /home/site/wwwroot
   node update-admin-credentials.js
   ```

---

## 🎯 Quick Reference - File Location

Your file needs to be at:
```
/home/site/wwwroot/update-admin-credentials.js
```

Or on Windows containers:
```
D:\home\site\wwwroot\update-admin-credentials.js
```

---

## 🔧 Troubleshooting

### Error: "Cannot find module 'bcrypt'"

The script needs the `bcrypt` package. It should already be installed since your app uses it. If not:

```bash
cd /home/site/wwwroot
npm install bcrypt
node update-admin-credentials.js
```

### Error: "DATABASE_URL not set"

This should not happen in Azure since it's configured. If you see this:

```bash
# Check if DATABASE_URL exists
printenv | grep DATABASE_URL

# If missing, your App Service configuration needs the DATABASE_URL
```

Go to Azure Portal → App Service → **Configuration** → **Application settings** and verify `DATABASE_URL` is set.

### File doesn't upload

- Make sure you're in the correct directory: `/site/wwwroot/`
- Check file permissions
- Try refreshing the Kudu console

### Script runs but nothing happens

Check the database connection:
1. Verify `DATABASE_URL` in App Service Configuration
2. Check if PostgreSQL server allows connections from Azure
3. Verify the `admin_users` table exists

---

## ✅ After Success

Test your new credentials:

1. **Login URL:** `https://your-app-name.azurewebsites.net/admin/`
2. **Username:** `admin`
3. **Email:** `support_homework@arshia.com`
4. **Password:** `A@dMin%f$7`

---

## 🧹 Cleanup (Optional)

After successfully updating, you can delete the script:

```bash
cd /home/site/wwwroot
rm update-admin-credentials.js
```

Or keep it for future password resets.

---

## 📞 Need More Help?

**Kudu Console URL Format:**
```
https://YOUR-APP-NAME.scm.azurewebsites.net
```

**SSH Console Access:**
```
Azure Portal → App Service → SSH → Go
```

**Where to find your App Service name:**
- Azure Portal → All Resources
- Look for type: "App Service"
- Common format: `homework-helper-api`



