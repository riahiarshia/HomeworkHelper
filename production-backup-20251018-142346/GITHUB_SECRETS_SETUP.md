# GitHub Environment Secrets Setup

## 🎯 Required Secrets for GitHub Environments

You need to add these secrets to your GitHub repository's environment settings.

## 📋 Step-by-Step Setup

### 1. Go to GitHub Repository Settings
1. Navigate to your GitHub repository: `https://github.com/riahiarshia/HomeworkHelper`
2. Click **Settings** tab
3. Click **Environments** in the left sidebar

### 2. Create Staging Environment
1. Click **New environment**
2. **Name**: `staging`
3. **Description**: `Staging environment for testing and development`
4. Click **Configure environment**

### 3. Add Staging Environment Secrets
In the staging environment, add these secrets:

#### **AZURE_CREDENTIALS** (for staging):
```json
{
  "clientId": "YOUR_AZURE_CLIENT_ID",
  "clientSecret": "YOUR_AZURE_CLIENT_SECRET",
  "subscriptionId": "YOUR_AZURE_SUBSCRIPTION_ID",
  "tenantId": "YOUR_AZURE_TENANT_ID",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

#### **AZURE_WEBAPP_PUBLISH_PROFILE** (for staging):
```xml
<publishData><publishProfile profileName="homework-helper-staging - Web Deploy" publishMethod="MSDeploy" publishUrl="homework-helper-staging.scm.azurewebsites.net:443" msdeploySite="homework-helper-staging" userName="$homework-helper-staging" userPWD="q6RLBHb8h1pkqjbtmtacj2bjBMFaJ3CNxXq554QFWgRGXNvGwvxBg8mHtkDa" destinationAppUrl="http://homework-helper-staging.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-staging - FTP" publishMethod="FTP" publishUrl="ftps://waws-prod-dm1-081.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="homework-helper-staging\$homework-helper-staging" userPWD="q6RLBHb8h1pkqjbtmtacj2bjBMFaJ3CNxXq554QFWgRGXNvGwvxBg8mHtkDa" destinationAppUrl="http://homework-helper-staging.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-staging - Zip Deploy" publishMethod="ZipDeploy" publishUrl="homework-helper-staging.scm.azurewebsites.net:443" userName="$homework-helper-staging" userPWD="q6RLBHb8h1pkqjbtmtacj2bjBMFaJ3CNxXq554QFWgRGXNvGwvxBg8mHtkDa" destinationAppUrl="http://homework-helper-staging.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-staging - ReadOnly - FTP" publishMethod="FTP" publishUrl="ftps://waws-prod-dm1-081dr.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="homework-helper-staging\$homework-helper-staging" userPWD="q6RLBHb8h1pkqjbtmtacj2bjBMFaJ3CNxXq554QFWgRGXNvGwvxBg8mHtkDa" destinationAppUrl="http://homework-helper-staging.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile></publishData>
```

### 4. Create Production Environment
1. Click **New environment**
2. **Name**: `production`
3. **Description**: `Production environment for live application`
4. Click **Configure environment**

### 5. Configure Production Environment Protection
In the production environment settings:

#### **Protection Rules**:
- ✅ **Required reviewers**: Add your GitHub username
- ✅ **Wait timer**: 5 minutes
- ✅ **Deployment branches**: Restrict to `main` branch only

#### **Environment Variables**:
- `NODE_ENV` = `production`
- `APP_URL` = `https://homework-helper-api.azurewebsites.net`

### 6. Add Production Environment Secrets
In the production environment, add these secrets:

#### **AZURE_CREDENTIALS_PROD** (for production):
```json
{
  "clientId": "YOUR_AZURE_CLIENT_ID",
  "clientSecret": "YOUR_AZURE_CLIENT_SECRET",
  "subscriptionId": "YOUR_AZURE_SUBSCRIPTION_ID",
  "tenantId": "YOUR_AZURE_TENANT_ID",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

#### **AZURE_WEBAPP_PUBLISH_PROFILE_PROD** (for production):
```xml
<publishData><publishProfile profileName="homework-helper-api - Web Deploy" publishMethod="MSDeploy" publishUrl="homework-helper-api.scm.azurewebsites.net:443" msdeploySite="homework-helper-api" userName="$homework-helper-api" userPWD="euxk1NXBDh6daKQYYWnBDvBXFt8rbmyvCBbo898iDokwyetjep2Ab1Tw6fgl" destinationAppUrl="http://homework-helper-api.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-api - FTP" publishMethod="FTP" publishUrl="ftps://waws-prod-dm1-145.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="homework-helper-api\$homework-helper-api" userPWD="euxk1NXBDh6daKQYYWnBDvBXFt8rbmyvCBbo898iDokwyetjep2Ab1Tw6fgl" destinationAppUrl="http://homework-helper-api.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-api - Zip Deploy" publishMethod="ZipDeploy" publishUrl="homework-helper-api.scm.azurewebsites.net:443" userName="$homework-helper-api" userPWD="euxk1NXBDh6daKQYYWnBDvBXFt8rbmyvCBbo898iDokwyetjep2Ab1Tw6fgl" destinationAppUrl="http://homework-helper-api.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-api - ReadOnly - FTP" publishMethod="FTP" publishUrl="ftps://waws-prod-dm1-145dr.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="homework-helper-api\$homework-helper-api" userPWD="euxk1NXBDh6daKQYYWnBDvBXFt8rbmyvCBbo898iDokwyetjep2Ab1Tw6fgl" destinationAppUrl="http://homework-helper-api.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile></publishData>
```

## 🧪 Testing the Setup

### Test Staging Deployment:
1. Push to `staging` branch
2. Go to **Actions** tab in GitHub
3. Watch the deployment workflow
4. Check: https://homework-helper-staging.azurewebsites.net/api/health

### Test Production Deployment:
1. Push to `main` branch
2. Go to **Actions** tab in GitHub
3. Click **Review deployments** when prompted
4. Approve the deployment
5. Check: https://homework-helper-api.azurewebsites.net/api/health

## 🎉 Benefits After Setup

- ✅ **Automatic staging deployments** on push to staging branch
- ✅ **Controlled production deployments** with manual approval
- ✅ **Environment isolation** with separate secrets
- ✅ **Deployment history** and audit trail
- ✅ **Rollback capability** through GitHub
- ✅ **Team collaboration** with reviewer controls

## 🔧 Troubleshooting

### If deployment fails:
1. Check GitHub Actions logs
2. Verify secrets are correctly added
3. Ensure environment names match exactly
4. Check Azure App Service logs

### If staging doesn't work:
- Verify `AZURE_CREDENTIALS` and `AZURE_WEBAPP_PUBLISH_PROFILE` are set
- Check that staging environment exists

### If production doesn't work:
- Verify `AZURE_CREDENTIALS_PROD` and `AZURE_WEBAPP_PUBLISH_PROFILE_PROD` are set
- Check that production environment exists and has protection rules

---

**🎯 Once you've added these secrets, your GitHub Environments will be fully functional!**
