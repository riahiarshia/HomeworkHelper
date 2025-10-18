#!/bin/bash

# Production Environment Setup Script
# This script sets up the production GitHub environment with all necessary secrets

set -e

echo "🚀 Setting up Production GitHub Environment..."

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first:"
    echo "   brew install gh"
    echo "   or visit: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub. Please run:"
    echo "   gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is ready"

# Azure credentials JSON (same for both staging and production)
AZURE_CREDENTIALS='{
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
}'

# Production publish profile
PROD_PUBLISH_PROFILE='<publishData><publishProfile profileName="homework-helper-api - Web Deploy" publishMethod="MSDeploy" publishUrl="homework-helper-api.scm.azurewebsites.net:443" msdeploySite="homework-helper-api" userName="$homework-helper-api" userPWD="euxk1NXBDh6daKQYYWnBDvBXFt8rbmyvCBbo898iDokwyetjep2Ab1Tw6fgl" destinationAppUrl="http://homework-helper-api.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-api - FTP" publishMethod="FTP" publishUrl="ftps://waws-prod-dm1-145.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="homework-helper-api\$homework-helper-api" userPWD="euxk1NXBDh6daKQYYWnBDvBXFt8rbmyvCBbo898iDokwyetjep2Ab1Tw6fgl" destinationAppUrl="http://homework-helper-api.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-api - Zip Deploy" publishMethod="ZipDeploy" publishUrl="homework-helper-api.scm.azurewebsites.net:443" userName="$homework-helper-api" userPWD="euxk1NXBDh6daKQYYWnBDvBXFt8rbmyvCBbo898iDokwyetjep2Ab1Tw6fgl" destinationAppUrl="http://homework-helper-api.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-api - ReadOnly - FTP" publishMethod="FTP" publishUrl="ftps://waws-prod-dm1-145dr.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="homework-helper-api\$homework-helper-api" userPWD="euxk1NXBDh6daKQYYWnBDvBXFt8rbmyvCBbo898iDokwyetjep2Ab1Tw6fgl" destinationAppUrl="http://homework-helper-api.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile></publishData>'

echo ""
echo "🔧 Setting up Production Environment..."

# Check if production environment already exists
if gh api repos/:owner/:repo/environments/production &> /dev/null; then
    echo "✅ Production environment already exists"
else
    echo "❌ Production environment does not exist. Creating it manually..."
    echo ""
    echo "📋 MANUAL STEP REQUIRED:"
    echo "1. Go to: https://github.com/riahiarshia/HomeworkHelper/settings/environments"
    echo "2. Click 'New environment'"
    echo "3. Name: production"
    echo "4. Description: Production environment for live application"
    echo "5. Click 'Configure environment'"
    echo ""
    echo "Press Enter when you've created the production environment..."
    read -r
fi

# Add production secrets
echo "Adding production secrets..."
gh secret set AZURE_CREDENTIALS_PROD --body "$AZURE_CREDENTIALS" --env production
gh secret set AZURE_WEBAPP_PUBLISH_PROFILE_PROD --body "$PROD_PUBLISH_PROFILE" --env production

echo "✅ Production environment secrets configured"

echo ""
echo "🔒 Setting up Production Protection Rules..."

# Try to set up protection rules via API
echo "Setting up production protection rules..."

# Get current user for required reviewers
CURRENT_USER=$(gh api user --jq .login)
echo "Current user: $CURRENT_USER"

# Set up protection rules
gh api repos/:owner/:repo/environments/production -X PUT -f protection_rules='[{"type":"required_reviewers","required_reviewers":1,"dismiss_stale_reviews":true},{"type":"wait_timer","wait_timer":5}]' || {
    echo "⚠️  Could not set protection rules via API. Manual setup required:"
    echo ""
    echo "📋 MANUAL PROTECTION RULES SETUP:"
    echo "1. Go to: https://github.com/riahiarshia/HomeworkHelper/settings/environments"
    echo "2. Click on 'production' environment"
    echo "3. Under 'Protection rules', add:"
    echo "   ✅ Required reviewers: 1 (add yourself: $CURRENT_USER)"
    echo "   ✅ Dismiss stale reviews: Yes"
    echo "   ✅ Wait timer: 5 minutes"
    echo "   ✅ Restrict to specific branches: main only"
    echo ""
    echo "Press Enter when you've set up the protection rules..."
    read -r
}

echo "✅ Production protection rules configured"

echo ""
echo "🧪 Testing Production Environment Setup..."

# Test if we can access the production environment
if gh api repos/:owner/:repo/environments/production &> /dev/null; then
    echo "✅ Production environment is accessible"
    
    # Test if secrets are set
    if gh secret list --env production | grep -q "AZURE_CREDENTIALS_PROD"; then
        echo "✅ Production Azure credentials are set"
    else
        echo "❌ Production Azure credentials not found"
    fi
    
    if gh secret list --env production | grep -q "AZURE_WEBAPP_PUBLISH_PROFILE_PROD"; then
        echo "✅ Production publish profile is set"
    else
        echo "❌ Production publish profile not found"
    fi
else
    echo "❌ Production environment not accessible"
fi

echo ""
echo "🎉 Production Environment Setup Complete!"
echo ""
echo "📋 What was configured:"
echo "   ✅ Production environment with Azure credentials"
echo "   ✅ Production publish profile for homework-helper-api"
echo "   ✅ Production protection rules (manual approval required)"
echo ""
echo "🧪 Test your production setup:"
echo "   1. Push to main branch: git checkout main && git push origin main"
echo "   2. Go to Actions tab in GitHub"
echo "   3. Click 'Review deployments' when prompted"
echo "   4. Approve the production deployment"
echo "   5. Check: https://homework-helper-api.azurewebsites.net/api/health"
echo ""
echo "🚀 Your GitHub Environments are now fully functional for both staging and production!"
echo ""
echo "📊 Environment Summary:"
echo "   • Staging: Automatic deployment on push to 'staging' branch"
echo "   • Production: Manual approval required on push to 'main' branch"
echo "   • Protection: Production requires manual review before deployment"
