#!/bin/bash

# Deploy Admin Credentials Update Script to Azure
# This script uploads the update script to Azure App Service

echo "
╔════════════════════════════════════════════════════╗
║                                                    ║
║   🔐 Deploy Admin Credentials Update              ║
║                                                    ║
╚════════════════════════════════════════════════════╝
"

# App Service name - UPDATE THIS with your Azure App Service name
APP_NAME="homework-helper-api"

echo "📋 App Service: $APP_NAME"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found"
    echo ""
    echo "Please install Azure CLI:"
    echo "  macOS: brew install azure-cli"
    echo "  Or visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    echo ""
    exit 1
fi

# Check if logged in to Azure
echo "🔍 Checking Azure login status..."
az account show &> /dev/null
if [ $? -ne 0 ]; then
    echo "❌ Not logged in to Azure"
    echo ""
    echo "Please login first:"
    echo "  az login"
    echo ""
    exit 1
fi

echo "✅ Azure CLI ready"
echo ""

# Upload the script using Azure CLI
echo "📤 Uploading update-admin-credentials.js to Azure..."
echo ""

# Create a zip with the script
zip -q admin-update.zip update-admin-credentials.js

# Deploy using Kudu API
echo "🚀 Deploying to Azure App Service..."

# Get publishing credentials
CREDS=$(az webapp deployment list-publishing-credentials --name $APP_NAME --resource-group $(az webapp show --name $APP_NAME --query resourceGroup -o tsv) --query "{username:publishingUserName, password:publishingPassword}" -o json)

USERNAME=$(echo $CREDS | jq -r .username)
PASSWORD=$(echo $CREDS | jq -r .password)

# Upload file using Kudu
curl -X PUT \
  -u $USERNAME:$PASSWORD \
  --data-binary @admin-update.zip \
  https://$APP_NAME.scm.azurewebsites.net/api/zip/site/wwwroot/

rm admin-update.zip

echo ""
echo "✅ Script uploaded successfully!"
echo ""
echo "╔════════════════════════════════════════════════════╗"
echo "║  📝 NEXT STEPS - Run in Azure Console             ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "1. Go to Azure Portal: https://portal.azure.com"
echo ""
echo "2. Navigate to your App Service: $APP_NAME"
echo ""
echo "3. Click 'SSH' or 'Advanced Tools' → 'SSH Console'"
echo ""
echo "4. In the console, run:"
echo "   cd /home/site/wwwroot"
echo "   node update-admin-credentials.js"
echo ""
echo "5. You should see: ✅ Admin credentials updated successfully!"
echo ""
echo "╔════════════════════════════════════════════════════╗"
echo "║  🔑 NEW CREDENTIALS                                ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "  Username: admin"
echo "  Email: support_homework@arshia.com"
echo "  Password: A@dMin%f\$7"
echo ""



