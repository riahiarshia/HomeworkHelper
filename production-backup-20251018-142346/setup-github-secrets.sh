#!/bin/bash

# GitHub Environment Secrets Setup Script
# This script automates the creation of GitHub environment secrets

set -e

echo "🚀 Setting up GitHub Environment Secrets..."

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

# Staging publish profile
STAGING_PUBLISH_PROFILE='<publishData><publishProfile profileName="homework-helper-staging - Web Deploy" publishMethod="MSDeploy" publishUrl="homework-helper-staging.scm.azurewebsites.net:443" msdeploySite="homework-helper-staging" userName="$homework-helper-staging" userPWD="q6RLBHb8h1pkqjbtmtacj2bjBMFaJ3CNxXq554QFWgRGXNvGwvxBg8mHtkDa" destinationAppUrl="http://homework-helper-staging.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-staging - FTP" publishMethod="FTP" publishUrl="ftps://waws-prod-dm1-081.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="homework-helper-staging\$homework-helper-staging" userPWD="q6RLBHb8h1pkqjbtmtacj2bjBMFaJ3CNxXq554QFWgRGXNvGwvxBg8mHtkDa" destinationAppUrl="http://homework-helper-staging.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-staging - Zip Deploy" publishMethod="ZipDeploy" publishUrl="homework-helper-staging.scm.azurewebsites.net:443" userName="$homework-helper-staging" userPWD="q6RLBHb8h1pkqjbtmtacj2bjBMFaJ3CNxXq554QFWgRGXNvGwvxBg8mHtkDa" destinationAppUrl="http://homework-helper-staging.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-staging - ReadOnly - FTP" publishMethod="FTP" publishUrl="ftps://waws-prod-dm1-081dr.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="homework-helper-staging\$homework-helper-staging" userPWD="q6RLBHb8h1pkqjbtmtacj2bjBMFaJ3CNxXq554QFWgRGXNvGwvxBg8mHtkDa" destinationAppUrl="http://homework-helper-staging.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile></publishData>'

# Production publish profile
PROD_PUBLISH_PROFILE='<publishData><publishProfile profileName="homework-helper-api - Web Deploy" publishMethod="MSDeploy" publishUrl="homework-helper-api.scm.azurewebsites.net:443" msdeploySite="homework-helper-api" userName="$homework-helper-api" userPWD="euxk1NXBDh6daKQYYWnBDvBXFt8rbmyvCBbo898iDokwyetjep2Ab1Tw6fgl" destinationAppUrl="http://homework-helper-api.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-api - FTP" publishMethod="FTP" publishUrl="ftps://waws-prod-dm1-145.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="homework-helper-api\$homework-helper-api" userPWD="euxk1NXBDh6daKQYYWnBDvBXFt8rbmyvCBbo898iDokwyetjep2Ab1Tw6fgl" destinationAppUrl="http://homework-helper-api.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-api - Zip Deploy" publishMethod="ZipDeploy" publishUrl="homework-helper-api.scm.azurewebsites.net:443" userName="$homework-helper-api" userPWD="euxk1NXBDh6daKQYYWnBDvBXFt8rbmyvCBbo898iDokwyetjep2Ab1Tw6fgl" destinationAppUrl="http://homework-helper-api.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile><publishProfile profileName="homework-helper-api - ReadOnly - FTP" publishMethod="FTP" publishUrl="ftps://waws-prod-dm1-145dr.ftp.azurewebsites.windows.net/site/wwwroot" ftpPassiveMode="True" userName="homework-helper-api\$homework-helper-api" userPWD="euxk1NXBDh6daKQYYWnBDvBXFt8rbmyvCBbo898iDokwyetjep2Ab1Tw6fgl" destinationAppUrl="http://homework-helper-api.azurewebsites.net" SQLServerDBConnectionString="" mySQLDBConnectionString="" hostingProviderForumLink="" controlPanelLink="https://portal.azure.com" webSystem="WebSites"><databases /></publishProfile></publishData>'

echo ""
echo "🔧 Setting up Staging Environment..."

# Create staging environment if it doesn't exist
if ! gh api repos/:owner/:repo/environments/staging &> /dev/null; then
    echo "Creating staging environment..."
    gh api repos/:owner/:repo/environments -X POST -f name=staging -f description="Staging environment for testing and development"
else
    echo "✅ Staging environment already exists"
fi

# Add staging secrets
echo "Adding staging secrets..."
gh secret set AZURE_CREDENTIALS --body "$AZURE_CREDENTIALS" --env staging
gh secret set AZURE_WEBAPP_PUBLISH_PROFILE --body "$STAGING_PUBLISH_PROFILE" --env staging

echo "✅ Staging environment configured"

echo ""
echo "🔧 Setting up Production Environment..."

# Create production environment if it doesn't exist
if ! gh api repos/:owner/:repo/environments/production &> /dev/null; then
    echo "Creating production environment..."
    gh api repos/:owner/:repo/environments -X POST -f name=production -f description="Production environment for live application"
else
    echo "✅ Production environment already exists"
fi

# Add production secrets
echo "Adding production secrets..."
gh secret set AZURE_CREDENTIALS_PROD --body "$AZURE_CREDENTIALS" --env production
gh secret set AZURE_WEBAPP_PUBLISH_PROFILE_PROD --body "$PROD_PUBLISH_PROFILE" --env production

echo "✅ Production environment configured"

echo ""
echo "🔒 Setting up Production Protection Rules..."

# Set up production protection rules
gh api repos/:owner/:repo/environments/production -X PUT -f protection_rules='[{"type":"required_reviewers","required_reviewers":1,"dismiss_stale_reviews":true},{"type":"wait_timer","wait_timer":5}]'

echo "✅ Production protection rules configured"

echo ""
echo "🎉 GitHub Environment Secrets Setup Complete!"
echo ""
echo "📋 What was configured:"
echo "   ✅ Staging environment with Azure credentials"
echo "   ✅ Production environment with Azure credentials"
echo "   ✅ Production protection rules (manual approval required)"
echo ""
echo "🧪 Test your setup:"
echo "   1. Push to staging branch → Should deploy automatically"
echo "   2. Push to main branch → Should require manual approval"
echo "   3. Check: https://homework-helper-staging.azurewebsites.net/api/health"
echo "   4. Check: https://homework-helper-api.azurewebsites.net/api/health"
echo ""
echo "🚀 Your GitHub Environments are now fully functional!"
