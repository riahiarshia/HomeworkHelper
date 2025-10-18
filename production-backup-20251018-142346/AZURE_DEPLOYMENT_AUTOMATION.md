# Azure Staging Deployment Automation

## 🎯 Overview
This document explains the automated deployment process for the Homework Helper backend to Azure App Service staging environment.

## 🚨 Root Cause Analysis

### The Problem
The initial deployment failed with:
```
Error: Cannot find module 'express'
```

### Root Cause
Azure App Service Linux uses a different deployment process than expected:
1. **Dependencies not installed**: Azure expects `npm install` to run during deployment
2. **Build process**: Azure App Service Linux requires specific configuration for Node.js apps
3. **Deployment structure**: The deployment package structure was not optimized for Azure

### The Solution
1. **Proper Azure configuration**: Added `.deployment` file with `SCM_DO_BUILD_DURING_DEPLOYMENT=true`
2. **Correct deployment structure**: Deploy without `node_modules` and let Azure install dependencies
3. **Environment configuration**: Properly configure App Service settings

## 🛠️ Automation Scripts

### 1. `deploy-staging-fixed.sh` (Recommended)
**Location**: `backend/deploy-staging-fixed.sh`

**Features**:
- ✅ Complete automation from resource creation to deployment
- ✅ Proper Azure App Service Linux configuration
- ✅ Environment variable setup
- ✅ Health check validation
- ✅ Error handling and colored output

**Usage**:
```bash
cd backend
chmod +x deploy-staging-fixed.sh
./deploy-staging-fixed.sh
```

### 2. `deploy-staging.sh` (Legacy)
**Location**: `backend/deploy-staging.sh`

**Status**: ⚠️ Has deployment issues - use the fixed version instead

## 🔧 Key Configuration Files

### `.deployment`
```ini
[config]
SCM_DO_BUILD_DURING_DEPLOYMENT=true
```
**Purpose**: Tells Azure to run `npm install` during deployment

### Environment Variables
The script automatically configures:
- `NODE_ENV=staging`
- `PORT=8080`
- `JWT_SECRET` and `ADMIN_JWT_SECRET`
- `APP_URL=https://homework-helper-staging.azurewebsites.net`
- Admin credentials for staging
- Database configuration placeholder

## 📋 Deployment Process

### 1. Prerequisites
- Azure CLI installed and logged in (`az login`)
- Proper permissions to create resources

### 2. Automated Steps
1. **Resource Group**: `homework-helper-stage-rg-f` in Central US
2. **App Service Plan**: `homework-helper-stage-plan` (B1 Linux)
3. **App Service**: `homework-helper-staging`
4. **Configuration**: Node.js runtime, environment variables
5. **Deployment**: Code deployment with automatic dependency installation
6. **Validation**: Health check to confirm successful deployment

### 3. Manual Steps (After Deployment)
1. **PostgreSQL Database**: Create manually in Azure Portal
2. **Database URL**: Update environment variable with actual connection string
3. **API Keys**: Configure OpenAI, Stripe, and other service keys
4. **Testing**: Verify all endpoints are working

## 🌐 Staging Environment URLs

Once deployed successfully:
- **Backend API**: `https://homework-helper-staging.azurewebsites.net`
- **Admin Dashboard**: `https://homework-helper-staging.azurewebsites.net/admin`
- **Health Check**: `https://homework-helper-staging.azurewebsites.net/api/health`

## 🔍 Troubleshooting

### Common Issues

#### 1. "Cannot find module 'express'"
**Cause**: Dependencies not installed during deployment
**Solution**: Use `deploy-staging-fixed.sh` with proper Azure configuration

#### 2. Deployment timeout
**Cause**: First deployment takes longer (10+ minutes)
**Solution**: Wait patiently or check logs with:
```bash
az webapp log tail --resource-group homework-helper-stage-rg-f --name homework-helper-staging
```

#### 3. Resource creation failures
**Cause**: Azure CLI permissions or quota limits
**Solution**: Check Azure Portal for detailed error messages

### Debugging Commands
```bash
# Check deployment status
az webapp deployment list --resource-group homework-helper-stage-rg-f --name homework-helper-staging

# View logs
az webapp log tail --resource-group homework-helper-stage-rg-f --name homework-helper-staging

# Check environment variables
az webapp config appsettings list --resource-group homework-helper-stage-rg-f --name homework-helper-staging

# Restart app
az webapp restart --resource-group homework-helper-stage-rg-f --name homework-helper-staging
```

## 📊 Resource Information

### Resource Group
- **Name**: `homework-helper-stage-rg-f`
- **Location**: Central US
- **Purpose**: Contains all staging environment resources

### App Service Plan
- **Name**: `homework-helper-stage-plan`
- **SKU**: B1 (Basic)
- **OS**: Linux
- **Runtime**: Node.js 18 LTS

### App Service
- **Name**: `homework-helper-staging`
- **URL**: `https://homework-helper-staging.azurewebsites.net`
- **Environment**: Staging
- **Database**: PostgreSQL (to be created manually)

## 🚀 Future Improvements

1. **Database Automation**: Add PostgreSQL creation to the deployment script
2. **CI/CD Integration**: Integrate with GitHub Actions for automatic deployments
3. **Environment Templates**: Create ARM templates for infrastructure as code
4. **Monitoring**: Add Application Insights and monitoring
5. **SSL Certificates**: Configure custom domain and SSL

## 📝 Notes

- The staging environment mirrors production configuration
- No Key Vault integration for staging (uses direct environment variables)
- Database credentials are hardcoded for simplicity (can be moved to Key Vault later)
- Admin credentials are set to simple values for testing purposes
