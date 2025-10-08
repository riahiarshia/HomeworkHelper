# 🚀 Deploy Backend via GitHub (Recommended Method)

The `bcrypt` module needs to be compiled on Azure's Linux environment. The best way is to deploy from GitHub so Azure builds it correctly.

## 📋 **Quick Setup (5 minutes)**

### **Step 1: Push Backend to GitHub**

```bash
cd /Users/ar616n/Documents/ios-app/ios-app

# Initialize git in backend folder
cd backend
git init
git add .
git commit -m "Initial backend with subscription system"

# Create a new GitHub repo called "homework-helper-backend"
# Then push:
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/homework-helper-backend.git
git push -u origin main
```

### **Step 2: Connect GitHub to Azure App Service**

#### **Via Azure Portal (Easiest):**

1. Go to https://portal.azure.com
2. Navigate to **homework-helper-api** (your App Service)
3. Click **Deployment Center** (left menu)
4. Source: **GitHub**
5. Sign in to GitHub
6. Select:
   - Organization: Your GitHub username
   - Repository: `homework-helper-backend`
   - Branch: `main`
7. Click **Save**

Azure will now:
- ✅ Pull code from GitHub
- ✅ Run `npm install` on Azure (Linux environment)
- ✅ Build bcrypt with correct binaries
- ✅ Start your server
- ✅ Auto-deploy on every git push

#### **Via Azure CLI:**

```bash
# Set deployment source
az webapp deployment source config \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api \
  --repo-url https://github.com/YOUR_USERNAME/homework-helper-backend \
  --branch main \
  --manual-integration

# Sync deployment
az webapp deployment source sync \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api
```

### **Step 3: Wait for Build (2-3 minutes)**

Watch the deployment:
```bash
az webapp log deployment show \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api
```

### **Step 4: Verify It's Running**

```bash
curl https://homework-helper-api.azurewebsites.net/api/health
```

Should return:
```json
{"status":"ok","timestamp":"...","environment":"production"}
```

---

## 🔄 **Alternative: Use Azure Container**

If GitHub doesn't work, we can use a container approach which pre-builds everything.

Would you like me to:
1. ✅ Help you set up GitHub deployment (recommended)?
2. Create a containerized version?
3. Try a different approach?

---

## ⚡ **FASTEST Option: Local Build Workaround**

Since bcrypt is causing issues, we can temporarily remove it and use a simpler auth method:

### **Quick Fix (5 minutes):**

1. Replace `bcrypt` with built-in crypto
2. Redeploy
3. Get system running now
4. Add bcrypt later

Want me to do this quick fix so you can access the admin dashboard immediately?


