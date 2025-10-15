# 🚀 Deployment Fixes Documentation

## 📋 Issues Fixed During Staging Deployment

### 1. **Missing Dependencies Issue**
**Problem:** App deployed without `node_modules`, causing "Cannot find module 'express'" errors.

**Solution:** Include `node_modules` in deployment package
```bash
# BEFORE (broken):
zip -r ../deployment.zip . -x "node_modules/*" "*.log" ".env*" "deploy*.sh" "*.zip"

# AFTER (fixed):
zip -r ../deployment.zip . -x "*.log" ".env*" "deploy*.sh" "*.zip"
```

### 2. **Azure CLI Authentication Issues**
**Problem:** Multiple Azure CLI authentication and subscription errors.

**Solution:** Use Azure WebApp Deploy action with publish profile instead of CLI commands.

### 3. **Missing Azure Login Step**
**Problem:** "No credentials found. Add an Azure login action before this action."

**Solution:** Add Azure login step before deployment:
```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}
```

### 4. **Database Connection Issues**
**Problem:** Admin login not working due to missing PostgreSQL database.

**Solution:** Created PostgreSQL Flexible Server and configured connection.

---

## ✅ Working Deployment Workflow

### GitHub Actions Workflow (`.github/workflows/deploy-staging.yml`)
```yaml
name: Deploy to Staging

on:
  push:
    branches: [ staging ]
  pull_request:
    branches: [ staging ]
  workflow_dispatch:

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
        cache-dependency-path: backend/package-lock.json
        
    - name: Install dependencies
      working-directory: ./backend
      run: npm ci
      
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
        
    - name: Create deployment package
      run: |
        cd backend
        zip -r ../deployment.zip . -x "*.log" ".env*" "deploy*.sh" "*.zip"
        
    - name: Deploy to Azure App Service
      uses: azure/webapps-deploy@v2
      with:
        app-name: homework-helper-staging
        publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE_STAGING }}
        package: deployment.zip
          
    - name: Verify deployment
      run: |
        echo "Waiting for deployment to stabilize..."
        sleep 30
        curl -f https://homework-helper-staging.azurewebsites.net/api/health || exit 1
        echo "✅ Staging deployment successful!"
```

---

## 🔧 Required GitHub Secrets

### For Staging Environment:
1. **`AZURE_CREDENTIALS`** - Azure service principal credentials (JSON format)
2. **`AZURE_WEBAPP_PUBLISH_PROFILE_STAGING`** - Azure App Service publish profile

### For Production Environment:
1. **`AZURE_CREDENTIALS`** - Azure service principal credentials (JSON format)
2. **`AZURE_WEBAPP_PUBLISH_PROFILE_PRODUCTION`** - Azure App Service publish profile

---

## 🗄️ Database Setup

### PostgreSQL Database Configuration:
- **Server:** `homework-helper-staging-db.postgres.database.azure.com`
- **Database:** `homework_helper_staging`
- **Username:** `homeworkadmin`
- **Password:** `Admin123!Staging`
- **Connection String:** `postgresql://homeworkadmin:Admin123!Staging@homework-helper-staging-db.postgres.database.azure.com:5432/homework_helper_staging?sslmode=require`

### Admin User Setup:
- **Username:** `admin`
- **Email:** `admin@homeworkhelper-staging.com`
- **Password:** `Admin123!Staging` (SHA256 hashed)
- **Role:** `super_admin`

---

## 🚨 Critical Deployment Rules

### ✅ DO:
1. **Include node_modules** in deployment package
2. **Use Azure WebApp Deploy action** with publish profile
3. **Add Azure login step** before deployment
4. **Verify deployment** with health check
5. **Set up database** before deployment
6. **Configure admin user** in database

### ❌ DON'T:
1. **Exclude node_modules** from deployment
2. **Use Azure CLI commands** for deployment (unreliable)
3. **Skip Azure authentication** step
4. **Deploy without database** setup
5. **Use deprecated Azure CLI commands**

---

## 📝 Production Deployment Checklist

Before deploying to production:

- [ ] Create production PostgreSQL database
- [ ] Set up production admin user
- [ ] Configure production GitHub secrets
- [ ] Test staging deployment first
- [ ] Verify all dependencies are included
- [ ] Check health endpoint responds
- [ ] Test admin portal login
- [ ] Document any environment-specific configurations

---

## 🔗 Useful Commands

### Check Deployment Status:
```bash
curl -f https://homework-helper-staging.azurewebsites.net/api/health
```

### Azure CLI Commands (for reference):
```bash
# List app services
az webapp list --resource-group homework-helper-stage-rg-f

# Check app status
az webapp show --resource-group homework-helper-stage-rg-f --name homework-helper-staging --query "state"

# Restart app
az webapp restart --resource-group homework-helper-stage-rg-f --name homework-helper-staging
```

---

## 📅 Last Updated
**Date:** October 15, 2025  
**Version:** 1.0  
**Status:** ✅ Working deployment process documented
