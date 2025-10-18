#!/bin/bash

echo "🚀 Setting up Homework Helper Backend API..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    echo "   Download from: https://nodejs.org/"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js version 18+ is required. Current version: $(node --version)"
    exit 1
fi

echo "✅ Node.js $(node --version) detected"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed successfully"

# Check Azure configuration
echo "🔍 Checking Azure configuration..."

if [ ! -f "config.js" ]; then
    echo "❌ config.js not found"
    exit 1
fi

# Extract Azure configuration for validation
AZURE_KEY_VAULT=$(grep -o "keyVaultName: '[^']*'" config.js | cut -d"'" -f2)
AZURE_TENANT=$(grep -o "tenantId: '[^']*'" config.js | cut -d"'" -f2)
AZURE_CLIENT=$(grep -o "clientId: '[^']*'" config.js | cut -d"'" -f2)

if [ -z "$AZURE_KEY_VAULT" ] || [ -z "$AZURE_TENANT" ] || [ -z "$AZURE_CLIENT" ]; then
    echo "⚠️  Azure configuration appears incomplete in config.js"
    echo "   Please verify your Azure Key Vault settings"
else
    echo "✅ Azure configuration found:"
    echo "   Key Vault: $AZURE_KEY_VAULT"
    echo "   Tenant ID: $AZURE_TENANT"
    echo "   Client ID: $AZURE_CLIENT"
fi

# Create logs directory
mkdir -p logs

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Verify your Azure Key Vault configuration in config.js"
echo "2. Ensure your OpenAI API key is stored in Azure Key Vault"
echo "3. Start the server: npm start"
echo "4. Test the API: curl http://localhost:3000/health"
echo ""
echo "📚 For more information, see README.md"
echo "🔧 For troubleshooting, check the logs directory"
