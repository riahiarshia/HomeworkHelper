# GitHub Actions Deployment Setup

## 🎯 Overview
This guide sets up automated deployments to Azure using GitHub Actions with proper safety measures to prevent accidental production deployments.

## 🔐 Required GitHub Secrets

### For Staging Environment:
1. **`AZURE_CREDENTIALS`** - Azure service principal credentials
2. **`AZURE_WEBAPP_PUBLISH_PROFILE`** - Staging app publish profile

### For Production Environment:
1. **`AZURE_CREDENTIALS_PROD`** - Production Azure service principal credentials
2. **`AZURE_WEBAPP_PUBLISH_PROFILE_PROD`** - Production app publish profile

## 🛠️ Setup Instructions

### Step 1: Create Azure Service Principal

#### For Staging:
```bash
# Create service principal for staging
az ad sp create-for-rbac --name "homework-helper-staging-github" \
  --role contributor \
  --scopes /subscriptions/f4eeb4ad-0461-480f-a5cf-5dff05e536b5/resourceGroups/homework-helper-stage-rg-f \
  --sdk-auth
```

#### For Production:
```bash
# Create service principal for production
az ad sp create-for-rbac --name "homework-helper-prod-github" \
  --role contributor \
  --scopes /subscriptions/f4eeb4ad-0461-480f-a5cf-5dff05e536b5/resourceGroups/homework-helper-rg-f \
  --sdk-auth
```

### Step 2: Get Publish Profiles

#### Staging:
```bash
az webapp deployment list-publishing-profiles \
  --resource-group homework-helper-stage-rg-f \
  --name homework-helper-staging \
  --xml
```

#### Production:
```bash
az webapp deployment list-publishing-profiles \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api \
  --xml
```

### Step 3: Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Add the following secrets:

#### Staging Secrets:
- **`AZURE_CREDENTIALS`**: Output from staging service principal creation
- **`AZURE_WEBAPP_PUBLISH_PROFILE`**: XML content from staging publish profile

#### Production Secrets:
- **`AZURE_CREDENTIALS_PROD`**: Output from production service principal creation
- **`AZURE_WEBAPP_PUBLISH_PROFILE_PROD`**: XML content from production publish profile

### Step 4: Set Up Production Environment Protection

1. Go to **Settings** → **Environments**
2. Create a new environment called **`production`**
3. Configure protection rules:
   - ✅ **Required reviewers**: Add yourself and team members
   - ✅ **Wait timer**: Set to 5 minutes (optional)
   - ✅ **Deployment branches**: Restrict to `main` branch only

## 🚀 Deployment Workflows

### Staging Deployment
- **Trigger**: Push to `staging` or `develop` branches
- **Manual trigger**: Available via GitHub Actions tab
- **Safety**: No manual approval required

### Production Deployment
- **Trigger**: Push to `main` branch
- **Manual trigger**: Available with additional confirmation
- **Safety**: Requires manual approval from configured reviewers

## 📋 Branch Strategy

### Recommended Git Flow:
```
main (production) ←─── staging ←─── develop ←─── feature branches
```

### Deployment Triggers:
- **`feature-branch`** → No deployment (development only)
- **`develop`** → Deploy to staging
- **`staging`** → Deploy to staging (testing)
- **`main`** → Deploy to production (with approval)

## 🔒 Safety Measures

### Staging Environment:
- ✅ Automatic deployment on push
- ✅ No manual approval required
- ✅ Safe for testing and development

### Production Environment:
- ✅ **Manual approval required** from configured reviewers
- ✅ **Branch protection** (only `main` branch)
- ✅ **Environment protection** rules
- ✅ **Deployment verification** with health checks
- ✅ **Clear warnings** in deployment logs

## 🧪 Testing the Setup

### Test Staging Deployment:
1. Create a feature branch
2. Make a small change
3. Merge to `staging` branch
4. Watch GitHub Actions deploy to staging
5. Verify: https://homework-helper-staging.azurewebsites.net/api/health

### Test Production Deployment:
1. Merge staging changes to `main`
2. GitHub will request approval
3. Approve the deployment
4. Watch deployment progress
5. Verify: https://homework-helper-api.azurewebsites.net/api/health

## 🚨 Emergency Procedures

### Rollback Production:
```bash
# Option 1: Revert commit and push
git revert <commit-hash>
git push origin main

# Option 2: Use Azure Portal
# Go to Azure Portal → App Service → Deployment Center → History
```

### Disable Automatic Deployments:
1. Go to **Settings** → **Actions** → **General**
2. Disable workflows temporarily
3. Or disable specific workflow files

## 📊 Monitoring

### GitHub Actions:
- View deployment history in **Actions** tab
- Monitor deployment logs and status
- Set up notifications for failures

### Azure Monitoring:
- Application Insights (if configured)
- Azure Monitor alerts
- Health check endpoints

## 🔧 Troubleshooting

### Common Issues:

#### 1. Authentication Failures
- Verify service principal credentials
- Check resource group permissions
- Ensure secrets are correctly set

#### 2. Deployment Failures
- Check build logs in GitHub Actions
- Verify Node.js version compatibility
- Check Azure App Service logs

#### 3. Environment Variable Issues
- Verify environment variables are set in Azure
- Check for typos in variable names
- Ensure proper JSON formatting in secrets

### Debug Commands:
```bash
# Check service principal permissions
az role assignment list --assignee <service-principal-id>

# Check App Service configuration
az webapp config appsettings list --resource-group <rg> --name <app>

# Check deployment status
az webapp deployment list --resource-group <rg> --name <app>
```

## 📝 Best Practices

1. **Always test in staging first**
2. **Use feature branches for development**
3. **Review all changes before production**
4. **Keep staging and production environments in sync**
5. **Monitor deployments and set up alerts**
6. **Regular backup of production data**
7. **Document any manual configuration changes**

## 🎉 Benefits

- ✅ **Automated deployments** - No more manual CLI commands
- ✅ **Safety measures** - Prevents accidental production deployments
- ✅ **Audit trail** - Full deployment history in GitHub
- ✅ **Team collaboration** - Multiple reviewers for production
- ✅ **Rollback capability** - Easy to revert changes
- ✅ **Environment consistency** - Same deployment process for all environments
