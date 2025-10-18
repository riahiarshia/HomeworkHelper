#!/bin/bash

# Deploy Device Tracking Migration to Azure
# This script runs the migration on Azure App Service

echo "🚀 Deploying Device Tracking Migration to Azure..."

# Set environment variables for Azure
export NODE_ENV=production

# Run the migration script on Azure
echo "📋 Running device tracking migration..."
node apply-device-tracking-migration.js

echo "✅ Device tracking migration completed!"
echo "🎉 The device tracking system is now live on Azure!"
