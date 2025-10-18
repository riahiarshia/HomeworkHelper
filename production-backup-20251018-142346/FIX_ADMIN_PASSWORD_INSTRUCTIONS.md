# 🔧 Fix Admin Password - Production Database

## 🎯 Problem Solved
Your admin password was using **bcrypt** hashing, but your system expects **SHA256** hashing. This mismatch caused login failures.

## ✅ Solution
I've created a fixed script that uses the correct SHA256 hashing method.

---

## 🚀 How to Apply the Fix

### **Step 1: Access Azure Kudu Console**

1. **Go to Azure Portal:**
   - Navigate to: https://portal.azure.com
   - Find your App Service: `homework-helper-api`

2. **Open Kudu Console:**
   - In your App Service, go to **Development Tools** → **Advanced Tools**
   - Click **"Go"** to open Kudu
   - Or go directly to: https://homework-helper-api.scm.azurewebsites.net

### **Step 2: Upload the Fix Script**

1. **Navigate to your app folder:**
   - Click **"Debug console"** → **"CMD"**
   - Navigate to: `/site/wwwroot/`

2. **Upload the script:**
   - **Drag and drop** the file `backend/fix-admin-production.js` into the file browser
   - Or click the **"+"** button and select the file

### **Step 3: Run the Fix**

In the Kudu console command prompt:

```bash
cd /home/site/wwwroot
node fix-admin-production.js
```

### **Step 4: Verify Success**

You should see output like:
```
✅ Admin credentials updated successfully!

📋 Updated Admin Details:
   Username: admin
   Email: support_homework@arshia.com
   Role: super_admin

🔑 Login Credentials:
   Username: admin
   Password: A@dMin%f$7

🌐 Admin Portal URL:
   https://homework-helper-api.azurewebsites.net/admin/
```

---

## 🔑 Your New Admin Credentials

- **Username:** `admin`
- **Password:** `A@dMin%f$7`
- **Email:** `support_homework@arshia.com`
- **Admin Portal:** `https://homework-helper-api.azurewebsites.net/admin/`

---

## ✅ Test the Fix

1. **Go to admin portal:**
   ```
   https://homework-helper-api.azurewebsites.net/admin/
   ```

2. **Login with:**
   - Username: `admin`
   - Password: `A@dMin%f$7`

3. **If successful:** You'll see the admin dashboard

---

## 🔒 Security Recommendations

1. **Change the password immediately** after logging in
2. **Delete the fix script** from the server for security
3. **Use a strong, unique password** for production
4. **Enable 2FA** if available

---

## 🆘 Troubleshooting

### **"DATABASE_URL not set" Error**
- The script must be run on the Azure server where DATABASE_URL is configured
- Make sure you're in the Kudu console, not running locally

### **"Connection refused" Error**
- Check if your Azure App Service is running
- Verify the database server is accessible

### **"Admin user not found"**
- The script will create a new admin user automatically
- This is normal if the admin was deleted during the restore

### **Still can't login?**
- Clear your browser cache and cookies
- Try incognito/private browsing mode
- Check if the admin portal URL is correct

---

## 📞 Need Help?

If you encounter issues:
1. Check the script output for specific error messages
2. Verify you're using the correct admin portal URL
3. Make sure the script ran successfully on Azure
4. Try creating a new admin user if needed

---

**🎉 Once fixed, you'll have full access to your production admin portal!**
