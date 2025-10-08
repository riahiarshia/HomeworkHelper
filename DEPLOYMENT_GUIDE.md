# Homework Helper Backend Deployment Guide

## Current Status

✅ **App Service Created**: `homework-helper-backend-1759603081`
✅ **Location**: Central US
✅ **Plan**: `homework-helper-plan-f` (B1 Basic)
✅ **URL**: https://homework-helper-backend-1759603081.azurewebsites.net
✅ **Backend Code**: Ready in `backend/` directory

## Issue

Azure CLI deployment commands are not working due to resource access issues. The App Service exists and is running but shows the default "waiting for content" page.

## Solution Options

### Option 1: Azure Portal Deployment (Recommended)

1. **Go to Azure Portal**
   - Navigate to: https://portal.azure.com
   - Search for: `homework-helper-backend-1759603081`
   - Select the App Service

2. **Deployment Center**
   - Click "Deployment Center" in the left menu
   - Select "ZIP Deploy" tab
   - Upload the `backend/deployment.zip` file
   - Click "Deploy"

### Option 2: FTP Deployment

1. **Get FTP Credentials**
   ```bash
   az webapp deployment list-publishing-credentials \
     --name homework-helper-backend-1759603081 \
     --resource-group homework-helper-rg-f
   ```

2. **Upload via FTP**
   - Use FTP client (FileZilla, WinSCP, etc.)
   - Upload all files from `backend/` to `/site/wwwroot/`

### Option 3: Local Git Deployment

1. **Enable Local Git**
   ```bash
   az webapp deployment source config-local-git \
     --name homework-helper-backend-1759603081 \
     --resource-group homework-helper-rg-f
   ```

2. **Deploy**
   ```bash
   cd backend
   git init
   git add .
   git commit -m "Initial deployment"
   git remote add azure <git-url-from-step-1>
   git push azure master
   ```

## After Deployment

### 1. Test the API
```bash
curl https://homework-helper-backend-1759603081.azurewebsites.net/health
curl https://homework-helper-backend-1759603081.azurewebsites.net/
```

### 2. Update iOS App Configuration
Update `BackendAPIService.swift`:
```swift
private let baseURL = "https://homework-helper-backend-1759603081.azurewebsites.net"
```

### 3. Configure App Settings
Set environment variables in Azure Portal:
- `NODE_ENV=production`
- `WEBSITE_NODE_DEFAULT_VERSION=18.17.0`

## API Endpoints

Once deployed, the following endpoints will be available:

- `GET /` - API information
- `GET /health` - Health check
- `POST /api/analyze` - Analyze homework images
- `POST /api/validate-image` - Validate image quality

## Troubleshooting

### Check App Service Logs
```bash
az webapp log tail \
  --name homework-helper-backend-1759603081 \
  --resource-group homework-helper-rg-f
```

### Restart App Service
```bash
az webapp restart \
  --name homework-helper-backend-1759603081 \
  --resource-group homework-helper-rg-f
```

## Next Steps

1. Deploy using one of the methods above
2. Test the API endpoints
3. Update the iOS app to use the new backend URL
4. Test the complete flow: iOS app → Backend API → OpenAI

## Contact

For issues: homework@arshia.com
