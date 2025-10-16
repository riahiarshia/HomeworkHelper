# Azure App Service Troubleshooting Guide

## 🚨 Current Issue: Portal Not Responding

### Step 1: Check Azure Logs
1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to your App Service: `homework-helper-staging`
3. Go to **Monitoring** → **Log stream**
4. Look for these error patterns:

#### Common Error Patterns:
```
Error: Cannot find module 'express'
Error: Cannot find module 'pg'
Error: listen EADDRINUSE :::8080
Error: connect ECONNREFUSED
```

### Step 2: Check Application Settings
1. In Azure Portal → App Service → **Configuration** → **Application settings**
2. Verify these are set:
   - `DATABASE_URL`: `postgresql://homeworkadmin:Admin123!Staging@homework-helper-staging-db.postgres.database.azure.com:5432/homework_helper_staging?sslmode=require`
   - `NODE_ENV`: `staging`
   - `JWT_SECRET`: `staging-super-secret-jwt-key-minimum-32-characters-long`
   - `ADMIN_JWT_SECRET`: `staging-admin-jwt-secret-key-minimum-32-characters-long`
   - `LEDGER_SALT`: `staging-ledger-salt-minimum-32-characters-long`

### Step 3: Check Deployment Status
1. Go to **Deployment Center** in Azure Portal
2. Check if the latest deployment succeeded
3. Look for any deployment errors

### Step 4: Restart App Service
1. Go to **Overview** in Azure Portal
2. Click **Restart** button
3. Wait 2-3 minutes for restart

### Step 5: Check Process Status
1. Go to **Advanced Tools** → **Kudu Console**
2. Navigate to `/home/site/wwwroot`
3. Run: `ls -la` to see files
4. Run: `ps aux` to see running processes
5. Run: `node server.js` to test startup

## 🔧 Quick Fixes

### Fix 1: Missing Dependencies
If you see "Cannot find module" errors:
```bash
# In Kudu Console
cd /home/site/wwwroot
npm install
```

### Fix 2: Port Binding Issues
If you see "EADDRINUSE" errors:
```bash
# Check what's using port 8080
netstat -tulpn | grep :8080
# Kill the process if needed
kill -9 <PID>
```

### Fix 3: Environment Variables
If environment variables are missing:
1. Go to **Configuration** → **Application settings**
2. Add each missing variable
3. Click **Save**
4. Restart the App Service

## 📋 Diagnostic Commands

### Check Server Files:
```bash
ls -la /home/site/wwwroot/
ls -la /home/site/wwwroot/routes/
ls -la /home/site/wwwroot/middleware/
ls -la /home/site/wwwroot/public/
```

### Check Dependencies:
```bash
ls -la /home/site/wwwroot/node_modules/
ls -la /home/site/wwwroot/node_modules/express/
ls -la /home/site/wwwroot/node_modules/pg/
```

### Test Database Connection:
```bash
node -e "
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});
pool.query('SELECT NOW()').then(r => console.log('DB OK:', r.rows[0])).catch(e => console.error('DB Error:', e.message));
"
```

### Test Server Startup:
```bash
cd /home/site/wwwroot
node server.js
```

## 🚨 Emergency Fixes

### Complete Reset:
1. Stop the App Service
2. Delete all files in `/home/site/wwwroot`
3. Redeploy from GitHub
4. Restart App Service

### Manual Dependency Install:
```bash
cd /home/site/wwwroot
rm -rf node_modules package-lock.json
npm install --production
```

## 📞 Support Information

- **App Service URL**: https://homework-helper-staging.azurewebsites.net
- **Admin Portal**: https://homework-helper-staging.azurewebsites.net/admin/
- **Health Check**: https://homework-helper-staging.azurewebsites.net/api/health
- **GitHub Repository**: https://github.com/riahiarshia/HomeworkHelper
- **Branch**: staging

## 🔍 What to Look For

### Successful Startup Logs:
```
✅ Environment variables validated
🚧 STAGING ENVIRONMENT - Using staging admin dashboard
🚀 Server running on 0.0.0.0:8080
```

### Failed Startup Logs:
```
❌ Error: Cannot find module 'express'
❌ Error: listen EADDRINUSE :::8080
❌ Error: connect ECONNREFUSED
```

## 📱 Test the Portal

Once the server is running:
1. Go to: https://homework-helper-staging.azurewebsites.net/admin/
2. Login with: `admin` / `Admin123!Staging`
3. Check if dashboard shows data
4. Test all tabs: Users, API Usage, Ledger, etc.
