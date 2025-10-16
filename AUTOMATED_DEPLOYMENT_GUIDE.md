# Automated Deployment Guide

## 🚀 **GitHub-Based Automated Deployment**

This guide explains how all deployment fixes are automated through GitHub Actions and will work for both staging and production.

## 📋 **Automated Fixes Included**

### 1. **Auto Fix Deployment Script** (`backend/auto-fix-deployment.js`)
- ✅ Ensures `node_modules` are installed
- ✅ Verifies all critical dependencies (express, pg, bcrypt, etc.)
- ✅ Checks server files are present
- ✅ Validates environment variables
- ✅ Creates startup script
- ✅ Tests server syntax

### 2. **Post Deployment Verification** (`backend/post-deployment-verify.js`)
- ✅ Tests database connection
- ✅ Verifies environment variables
- ✅ Checks all server files
- ✅ Validates dependencies
- ✅ Tests admin API components

### 3. **GitHub Actions Workflow** (`.github/workflows/auto-fix-staging.yml`)
- ✅ Runs on every push to `staging` branch
- ✅ Installs dependencies automatically
- ✅ Runs auto-fix script
- ✅ Verifies deployment structure
- ✅ Tests server files
- ✅ Creates deployment package

## 🔄 **Deployment Process**

### **Automatic (GitHub Actions)**
1. **Push to staging branch** → Triggers GitHub Actions
2. **Auto-fix script runs** → Fixes common issues
3. **Dependencies installed** → Ensures all modules present
4. **Server validated** → Checks syntax and structure
5. **Deployment package created** → Ready for Azure
6. **Azure deploys automatically** → From GitHub Actions

### **Manual Verification (if needed)**
```bash
# Run auto-fix locally
npm run auto-fix

# Run post-deployment verification
npm run post-deploy

# Run both
npm run verify
```

## 🛠️ **What Gets Fixed Automatically**

### **Dependency Issues**
- Missing `node_modules` directory
- Missing critical dependencies (express, pg, bcrypt, etc.)
- Corrupted dependency installations

### **File Structure Issues**
- Missing server files
- Incorrect file permissions
- Broken symlinks

### **Configuration Issues**
- Missing startup scripts
- Invalid server syntax
- Environment variable validation

### **Database Issues**
- Connection string validation
- Database accessibility tests
- Admin API component loading

## 📊 **Deployment Status Monitoring**

### **GitHub Actions Logs**
1. Go to: https://github.com/riahiarshia/HomeworkHelper/actions
2. Click on latest workflow run
3. Check each step for success/failure

### **Azure Deployment Logs**
1. Go to: Azure Portal → App Service → Log stream
2. Look for auto-fix script output
3. Check for successful startup messages

### **Success Indicators**
```
✅ Dependencies installed
✅ Server files validated
✅ Environment variables set
✅ Database connection successful
🚀 Server running on 0.0.0.0:8080
```

## 🔧 **Troubleshooting Automated Fixes**

### **If Auto-Fix Fails**
1. Check GitHub Actions logs for specific errors
2. Verify all required files are in the repository
3. Check if dependencies can be installed
4. Verify Azure App Service configuration

### **If Post-Deployment Verification Fails**
1. Check Azure Portal → Log stream
2. Verify environment variables are set
3. Check database connectivity
4. Restart App Service if needed

## 🚀 **Production Deployment**

### **Same Process for Production**
1. **Push to `main` branch** → Triggers production deployment
2. **All auto-fixes run** → Same automated fixes
3. **Production environment** → Uses production database
4. **Admin portal** → Production admin dashboard

### **Production Environment Variables**
- `DATABASE_URL`: Production database connection
- `NODE_ENV`: `production`
- `JWT_SECRET`: Production JWT secret
- `ADMIN_JWT_SECRET`: Production admin JWT secret
- `LEDGER_SALT`: Production ledger salt

## 📱 **Testing After Deployment**

### **Staging**
- **URL**: https://homework-helper-staging.azurewebsites.net/admin/
- **Login**: `admin` / `Admin123!Staging`
- **Health Check**: https://homework-helper-staging.azurewebsites.net/api/health

### **Production**
- **URL**: https://homework-helper.azurewebsites.net/admin/
- **Login**: `admin` / `Admin123!Production`
- **Health Check**: https://homework-helper.azurewebsites.net/api/health

## 🔄 **Continuous Deployment**

### **Every Push Triggers**
1. **GitHub Actions** → Runs auto-fix script
2. **Azure Deployment** → Deploys fixed code
3. **Post-Deployment** → Verifies everything works
4. **Admin Portal** → Should be accessible

### **No Manual Intervention Required**
- ✅ All fixes are automated
- ✅ Dependencies install automatically
- ✅ Server starts automatically
- ✅ Database connects automatically
- ✅ Admin portal works automatically

## 📋 **Deployment Checklist**

### **Before Deployment**
- [ ] All code committed to GitHub
- [ ] Environment variables set in Azure
- [ ] Database accessible
- [ ] GitHub Actions configured

### **After Deployment**
- [ ] GitHub Actions completed successfully
- [ ] Azure deployment completed
- [ ] Admin portal accessible
- [ ] All tabs working (Users, API Usage, Ledger)
- [ ] Database connection working

## 🎉 **Benefits of Automated Deployment**

1. **Consistent Deployments** → Same process every time
2. **Automatic Fixes** → Common issues resolved automatically
3. **Production Ready** → Same process for staging and production
4. **No Manual Steps** → Everything through GitHub
5. **Easy Troubleshooting** → Clear logs and error messages
6. **Reliable** → Automated verification and testing

## 🔗 **Quick Links**

- **GitHub Repository**: https://github.com/riahiarshia/HomeworkHelper
- **Staging Branch**: `staging`
- **Production Branch**: `main`
- **GitHub Actions**: https://github.com/riahiarshia/HomeworkHelper/actions
- **Azure Portal**: https://portal.azure.com
