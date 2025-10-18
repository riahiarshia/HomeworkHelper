# GitHub Environments Setup Guide

## 🎯 Overview
This guide sets up GitHub Environments to provide controlled deployment access to Azure for both production and staging environments. GitHub Environments add an extra layer of security and control over your deployments.

## 🔐 What GitHub Environments Provide

### Production Environment
- ✅ **Manual approval required** - No accidental production deployments
- ✅ **Branch protection** - Only deploy from `main` branch
- ✅ **Reviewer requirements** - Team members must approve deployments
- ✅ **Wait timer** - 5-minute delay before deployment starts
- ✅ **Deployment history** - Track all production deployments
- ✅ **Environment secrets** - Separate secrets for production

### Staging Environment
- ✅ **Automatic deployment** - No manual approval needed
- ✅ **Multiple branch support** - Deploy from `staging`, `develop`, and feature branches
- ✅ **Quick testing** - Fast deployment for development
- ✅ **Environment secrets** - Separate secrets for staging

## 🛠️ Manual Setup Steps (Required)

### Step 1: Create GitHub Environments

1. **Go to your GitHub repository**
2. **Navigate to Settings → Environments**
3. **Click "New environment"**

#### Create Production Environment:
- **Name**: `production`
- **Display name**: `Production Environment`
- **Description**: `Live production environment for homework-helper-api`

#### Create Staging Environment:
- **Name**: `staging`
- **Display name**: `Staging Environment`
- **Description**: `Staging environment for testing and development`

### Step 2: Configure Production Environment Protection

#### Required Reviewers:
1. In the production environment settings
2. **Check "Required reviewers"**
3. **Add reviewers**: Add your GitHub username and team members
4. **Minimum reviewers**: 1 (or more for team safety)

#### Deployment Branch Rules:
1. **Check "Restrict to specific branches"**
2. **Add branch**: `main`
3. **Add branch**: `master` (if you use both)

#### Wait Timer:
1. **Check "Wait timer"**
2. **Set to**: 5 minutes
3. **Purpose**: Gives time to cancel if needed

### Step 3: Configure Environment Secrets

#### Production Secrets:
Navigate to **Settings → Environments → production → Environment secrets**

Add these secrets:
- `AZURE_CREDENTIALS_PROD` - Production Azure service principal
- `AZURE_WEBAPP_PUBLISH_PROFILE_PROD` - Production publish profile
- `DATABASE_URL_PROD` - Production database connection string
- `JWT_SECRET_PROD` - Production JWT secret
- `ADMIN_JWT_SECRET_PROD` - Production admin JWT secret
- `OPENAI_API_KEY_PROD` - Production OpenAI API key
- `STRIPE_SECRET_KEY_PROD` - Production Stripe secret key

#### Staging Secrets:
Navigate to **Settings → Environments → staging → Environment secrets**

Add these secrets:
- `AZURE_CREDENTIALS` - Staging Azure service principal
- `AZURE_WEBAPP_PUBLISH_PROFILE` - Staging publish profile
- `DATABASE_URL_STAGING` - Staging database connection string
- `JWT_SECRET_STAGING` - Staging JWT secret
- `ADMIN_JWT_SECRET_STAGING` - Staging admin JWT secret
- `OPENAI_API_KEY_STAGING` - Staging OpenAI API key
- `STRIPE_SECRET_KEY_STAGING` - Staging Stripe secret key

### Step 4: Configure Environment Variables

#### Production Variables:
Navigate to **Settings → Environments → production → Environment variables**

Add these variables:
- `NODE_ENV` = `production`
- `APP_URL` = `https://homework-helper-api.azurewebsites.net`
- `AZURE_WEBAPP_NAME` = `homework-helper-api`
- `AZURE_RESOURCE_GROUP` = `homework-helper-rg-f`

#### Staging Variables:
Navigate to **Settings → Environments → staging → Environment variables**

Add these variables:
- `NODE_ENV` = `staging`
- `APP_URL` = `https://homework-helper-staging.azurewebsites.net`
- `AZURE_WEBAPP_NAME` = `homework-helper-staging`
- `AZURE_RESOURCE_GROUP` = `homework-helper-stage-rg-f`

## 🚀 How Deployments Work Now

### Staging Deployments
**Triggers:**
- Push to `staging` branch → Automatic deployment
- Push to `develop` branch → Automatic deployment
- Manual trigger from GitHub Actions tab

**Process:**
1. Code is pushed to staging/develop branch
2. GitHub Actions workflow starts automatically
3. No approval required
4. Deploys to `homework-helper-staging.azurewebsites.net`
5. Health check verifies deployment

### Production Deployments
**Triggers:**
- Push to `main` branch → Requires approval
- Manual trigger from GitHub Actions tab → Requires approval

**Process:**
1. Code is pushed to `main` branch
2. GitHub Actions workflow starts
3. **WAITS FOR MANUAL APPROVAL** ⏳
4. Reviewer receives notification
5. Reviewer clicks "Approve" in GitHub
6. 5-minute wait timer starts
7. Deployment proceeds to `homework-helper-api.azurewebsites.net`
8. Health check verifies deployment

## 🔒 Security Benefits

### Production Protection:
- **No accidental deployments** - Manual approval always required
- **Branch restrictions** - Only `main` branch can deploy to production
- **Team oversight** - Multiple reviewers can be required
- **Audit trail** - All approvals are logged
- **Rollback capability** - Easy to revert deployments

### Staging Flexibility:
- **Fast iteration** - No approval delays for testing
- **Feature branch testing** - Test individual features
- **Safe experimentation** - Staging is isolated from production

## 📊 Monitoring and Management

### View Deployment History:
1. Go to **Actions** tab in GitHub
2. Click on any workflow run
3. See detailed logs and status
4. View environment-specific deployments

### Environment Status:
1. Go to **Settings → Environments**
2. See deployment history for each environment
3. View pending deployments waiting for approval
4. Manage environment settings

### Approve Production Deployments:
1. Go to **Actions** tab
2. Find the production workflow run
3. Click "Review deployments"
4. Review the changes
5. Click "Approve" or "Reject"

## 🧪 Testing the Setup

### Test Staging Deployment:
1. Create a feature branch: `git checkout -b test-staging-deploy`
2. Make a small change (add a comment)
3. Push to staging: `git push origin staging`
4. Watch GitHub Actions deploy automatically
5. Verify: https://homework-helper-staging.azurewebsites.net/api/health

### Test Production Deployment:
1. Merge staging changes to main: `git checkout main && git merge staging`
2. Push to main: `git push origin main`
3. Go to GitHub Actions tab
4. Find the production workflow
5. Click "Review deployments"
6. Approve the deployment
7. Wait for 5-minute timer
8. Watch deployment proceed
9. Verify: https://homework-helper-api.azurewebsites.net/api/health

## 🚨 Emergency Procedures

### Cancel Production Deployment:
1. Go to **Actions** tab
2. Find the running production workflow
3. Click "Cancel workflow"
4. Deployment will stop immediately

### Rollback Production:
1. Revert the last commit: `git revert HEAD`
2. Push to main: `git push origin main`
3. This will trigger a new production deployment
4. Approve the rollback deployment

### Disable Environments:
1. Go to **Settings → Environments**
2. Click on the environment
3. Click "Delete environment"
4. Or disable protection rules temporarily

## 📝 Best Practices

### Development Workflow:
1. **Feature branches** → No deployment (development only)
2. **Develop branch** → Deploy to staging (testing)
3. **Staging branch** → Deploy to staging (final testing)
4. **Main branch** → Deploy to production (with approval)

### Team Collaboration:
1. **Always test in staging first**
2. **Review all changes before production**
3. **Use descriptive commit messages**
4. **Document any manual configuration changes**
5. **Set up notifications for deployment failures**

### Security:
1. **Rotate secrets regularly**
2. **Use different secrets for each environment**
3. **Limit production access to trusted team members**
4. **Monitor deployment logs for suspicious activity**
5. **Keep staging and production environments in sync**

## 🎉 Benefits Summary

- ✅ **Controlled deployments** - No more accidental production pushes
- ✅ **Team oversight** - Multiple reviewers for production
- ✅ **Audit trail** - Complete deployment history
- ✅ **Environment isolation** - Separate secrets and configs
- ✅ **Flexible testing** - Easy staging deployments
- ✅ **Emergency controls** - Cancel and rollback capabilities
- ✅ **Professional workflow** - Industry-standard deployment practices

## 🔧 Troubleshooting

### Common Issues:

#### 1. "Environment not found" error
**Solution**: Make sure you've created the environments in GitHub Settings

#### 2. "Secrets not found" error
**Solution**: Verify secrets are added to the correct environment

#### 3. "Approval required" but no notification
**Solution**: Check your GitHub notification settings

#### 4. Deployment fails after approval
**Solution**: Check the workflow logs for specific error messages

### Debug Commands:
```bash
# Check current branch
git branch --show-current

# Check recent commits
git log --oneline -5

# Check GitHub Actions status
gh run list --limit 10
```

## 📞 Support

If you encounter issues:
1. Check the GitHub Actions logs
2. Verify environment settings
3. Ensure all secrets are configured
4. Test with a simple change first
5. Contact your team lead for production issues

---

**🎯 You now have full control over your Azure deployments with GitHub Environments!**
