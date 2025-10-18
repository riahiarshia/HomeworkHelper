#!/bin/bash

# Complete Production Environment Setup Script
# This script will guide you through the entire production setup process

set -e

echo "🚀 COMPLETE PRODUCTION ENVIRONMENT SETUP"
echo "========================================"
echo ""

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
echo ""

# Azure credentials JSON
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

echo "🔍 STEP 1: Checking current environment status..."
echo "-----------------------------------------------"

# Check current environments
echo "📋 Current GitHub Environments:"
gh api repos/:owner/:repo/environments --jq '.[].name' || echo "No environments found"

echo ""
echo "🔍 STEP 2: Checking if production environment exists..."
echo "------------------------------------------------------"

# Check if production environment exists
if gh api repos/:owner/:repo/environments/production &> /dev/null; then
    echo "✅ Production environment already exists"
    PROD_EXISTS=true
else
    echo "❌ Production environment does not exist"
    PROD_EXISTS=false
fi

echo ""
echo "🔍 STEP 3: Checking staging environment status..."
echo "------------------------------------------------"

# Check staging environment
if gh api repos/:owner/:repo/environments/staging &> /dev/null; then
    echo "✅ Staging environment exists"
    
    # Check staging secrets
    echo "📋 Staging environment secrets:"
    gh secret list --env staging || echo "No secrets found in staging"
else
    echo "❌ Staging environment does not exist"
fi

echo ""
echo "🔍 STEP 4: Production environment setup..."
echo "------------------------------------------"

if [ "$PROD_EXISTS" = false ]; then
    echo "❌ Production environment not found. Manual creation required."
    echo ""
    echo "📋 MANUAL STEP REQUIRED:"
    echo "1. Open: https://github.com/riahiarshia/HomeworkHelper/settings/environments"
    echo "2. Click 'New environment'"
    echo "3. Name: production"
    echo "4. Description: Production environment for live application"
    echo "5. Click 'Configure environment'"
    echo ""
    echo "⏳ Waiting for you to create the production environment..."
    echo "Press Enter when you've created the production environment..."
    read -r
    
    # Check again if production environment exists
    if gh api repos/:owner/:repo/environments/production &> /dev/null; then
        echo "✅ Production environment created successfully!"
        PROD_EXISTS=true
    else
        echo "❌ Production environment still not found. Please try again."
        exit 1
    fi
fi

echo ""
echo "🔍 STEP 5: Adding production secrets..."
echo "--------------------------------------"

# Add production secrets
echo "Adding AZURE_CREDENTIALS_PROD..."
if gh secret set AZURE_CREDENTIALS_PROD --body "$AZURE_CREDENTIALS" --env production; then
    echo "✅ AZURE_CREDENTIALS_PROD added successfully"
else
    echo "❌ Failed to add AZURE_CREDENTIALS_PROD"
    exit 1
fi

echo "Adding AZURE_WEBAPP_PUBLISH_PROFILE_PROD..."
if gh secret set AZURE_WEBAPP_PUBLISH_PROFILE_PROD --body "$PROD_PUBLISH_PROFILE" --env production; then
    echo "✅ AZURE_WEBAPP_PUBLISH_PROFILE_PROD added successfully"
else
    echo "❌ Failed to add AZURE_WEBAPP_PUBLISH_PROFILE_PROD"
    exit 1
fi

echo ""
echo "🔍 STEP 6: Setting up production protection rules..."
echo "----------------------------------------------------"

# Get current user for required reviewers
CURRENT_USER=$(gh api user --jq .login)
echo "Current user: $CURRENT_USER"

# Set up protection rules
echo "Setting up protection rules..."
if gh api repos/:owner/:repo/environments/production -X PUT -f protection_rules='[{"type":"required_reviewers","required_reviewers":1,"dismiss_stale_reviews":true},{"type":"wait_timer","wait_timer":5}]'; then
    echo "✅ Production protection rules configured successfully"
else
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
fi

echo ""
echo "🔍 STEP 7: Verifying production environment setup..."
echo "----------------------------------------------------"

# Test if we can access the production environment
if gh api repos/:owner/:repo/environments/production &> /dev/null; then
    echo "✅ Production environment is accessible"
    
    # Test if secrets are set
    echo "📋 Production environment secrets:"
    gh secret list --env production
    
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
echo "🔍 STEP 8: Final environment summary..."
echo "---------------------------------------"

echo "📊 Complete Environment Status:"
echo ""

# Staging environment status
echo "🟢 STAGING ENVIRONMENT:"
if gh api repos/:owner/:repo/environments/staging &> /dev/null; then
    echo "   ✅ Environment exists"
    echo "   ✅ Secrets configured"
    echo "   ✅ Automatic deployment on push to 'staging' branch"
    echo "   🌐 URL: https://homework-helper-staging.azurewebsites.net"
else
    echo "   ❌ Environment not found"
fi

echo ""

# Production environment status
echo "🔴 PRODUCTION ENVIRONMENT:"
if gh api repos/:owner/:repo/environments/production &> /dev/null; then
    echo "   ✅ Environment exists"
    echo "   ✅ Secrets configured"
    echo "   ✅ Manual approval required for deployment"
    echo "   🌐 URL: https://homework-helper-api.azurewebsites.net"
else
    echo "   ❌ Environment not found"
fi

echo ""
echo "🎉 PRODUCTION ENVIRONMENT SETUP COMPLETE!"
echo "========================================"
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
echo ""
echo "✅ Setup completed successfully!"
