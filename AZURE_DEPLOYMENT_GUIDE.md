# 🌐 Azure Deployment Guide - Homework Helper

## 📋 **Architecture Overview**

We'll use Azure's managed services (no VMs needed):

1. **Azure Database for PostgreSQL** - Managed database
2. **Azure App Service** - Host backend + admin dashboard
3. **Azure Static Web Apps** (optional) - For admin dashboard CDN
4. **Stripe** - Payment processing (external)

**Total Monthly Cost:** ~$25-85 (scales with usage)

---

## 🗄️ **Step 1: Create PostgreSQL Database**

### **Option A: Via Azure Portal (Easy)**

1. Go to https://portal.azure.com
2. Click "**Create a resource**"
3. Search for "**Azure Database for PostgreSQL Flexible Server**"
4. Click "Create"

**Configuration:**
```
Resource Group: homework-helper-rg (create new)
Server name: homework-helper-db
Region: East US (or closest to you)
PostgreSQL version: 15
Workload type: Development

Compute + Storage:
  Tier: Burstable
  Compute: B1ms (1 vCore, 2 GB RAM)
  Storage: 32 GB
  
Admin username: dbadmin
Admin password: [Create strong password]

Networking:
  ✅ Allow public access
  ✅ Add current client IP address
  
Backup:
  Retention: 7 days
```

5. Click "Review + Create"
6. Click "Create" (takes ~5 minutes)

**Cost:** ~$12-20/month

### **Option B: Via Azure CLI (Fast)**

```bash
# Login to Azure
az login

# Create resource group
az group create \
  --name homework-helper-rg \
  --location eastus

# Create PostgreSQL server
az postgres flexible-server create \
  --resource-group homework-helper-rg \
  --name homework-helper-db \
  --location eastus \
  --admin-user dbadmin \
  --admin-password "YourStrongPassword123!" \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32 \
  --version 15 \
  --public-access 0.0.0.0

# Create database
az postgres flexible-server db create \
  --resource-group homework-helper-rg \
  --server-name homework-helper-db \
  --database-name homework_helper
```

### **Get Connection String**

After creation:
1. Go to your PostgreSQL resource
2. Click "**Connection strings**" (left menu)
3. Copy the **Node.js** connection string

It will look like:
```
postgres://dbadmin@homework-helper-db:YourPassword@homework-helper-db.postgres.database.azure.com/homework_helper?ssl=true
```

**Save this - you'll need it!**

---

## 🖥️ **Step 2: Deploy Backend to Azure App Service**

### **Option A: Via Azure Portal + GitHub (Recommended)**

#### **2.1: Create GitHub Repository**

```bash
# In your project folder
cd backend
git init
git add .
git commit -m "Initial commit - subscription backend"

# Create repo on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/homework-helper-backend.git
git push -u origin main
```

#### **2.2: Create App Service**

1. Go to https://portal.azure.com
2. "**Create a resource**" → "**Web App**"

**Configuration:**
```
Resource Group: homework-helper-rg (same as database)
Name: homework-helper-api (must be globally unique)
Publish: Code
Runtime stack: Node 20 LTS
Operating System: Linux
Region: East US (same as database)

App Service Plan:
  Linux Plan: Create new
  Sku: Basic B1 (1 Core, 1.75 GB RAM)
```

3. Click "Review + Create"
4. Click "Create" (takes ~2 minutes)

**Cost:** ~$13-55/month

#### **2.3: Configure Deployment**

1. Go to your App Service resource
2. Click "**Deployment Center**" (left menu)
3. Source: **GitHub**
4. Sign in to GitHub
5. Select:
   - Organization: Your username
   - Repository: homework-helper-backend
   - Branch: main
6. Click "Save"

**Azure will now auto-deploy from GitHub!**

#### **2.4: Add Environment Variables**

1. In App Service, click "**Configuration**" (left menu)
2. Click "**+ New application setting**" for each:

```
PORT = 8080 (App Service uses this)

# Database
DATABASE_URL = postgres://dbadmin@homework-helper-db:PASSWORD@homework-helper-db.postgres.database.azure.com/homework_helper?ssl=true

# JWT Secrets (generate new ones!)
JWT_SECRET = [paste from your .env]
ADMIN_JWT_SECRET = [paste from your .env]

# Stripe
STRIPE_SECRET_KEY = sk_live_your_live_key
STRIPE_WEBHOOK_SECRET = whsec_your_webhook_secret
STRIPE_PRICE_ID = price_your_price_id

# App URL
APP_URL = https://homework-helper-api.azurewebsites.net

NODE_ENV = production
```

3. Click "**Save**"
4. Click "**Continue**" to restart app

#### **2.5: Update server.js**

Your `server-subscription.js` needs a small change for Azure:

```javascript
const PORT = process.env.PORT || 3000;  // Already correct!
```

Make sure to use `DATABASE_URL` in your database connection:

```javascript
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: {
        rejectUnauthorized: false  // Azure PostgreSQL requires SSL
    }
});
```

Push changes:
```bash
git add .
git commit -m "Configure for Azure deployment"
git push
```

Azure will auto-deploy in ~2 minutes!

---

## 📊 **Step 3: Setup Database Tables**

### **Option A: Via Azure Cloud Shell**

1. Go to https://portal.azure.com
2. Click "**Cloud Shell**" icon (top right)
3. Select "Bash"

```bash
# Download your migration file
curl -o migration.sql https://raw.githubusercontent.com/YOUR_USERNAME/homework-helper-backend/main/database/migration.sql

# Run migration
psql "postgres://dbadmin@homework-helper-db:PASSWORD@homework-helper-db.postgres.database.azure.com/homework_helper?sslmode=require" -f migration.sql
```

### **Option B: From Your Computer**

```bash
# Make sure psql is installed
brew install postgresql

# Run migration
psql "postgres://dbadmin@homework-helper-db:PASSWORD@homework-helper-db.postgres.database.azure.com/homework_helper?sslmode=require" -f backend/database/migration.sql
```

---

## 🌐 **Step 4: Access Your Admin Dashboard**

Your backend is now live at:
```
https://homework-helper-api.azurewebsites.net
```

**Admin Dashboard:**
```
https://homework-helper-api.azurewebsites.net/admin
```

**Login:**
- Username: `admin`
- Password: `admin123`

⚠️ **IMPORTANT:** Change the admin password immediately!

---

## 📱 **Step 5: Update iOS App**

In `BackendAPIService.swift`, update the base URL:

```swift
private let baseURL = "https://homework-helper-api.azurewebsites.net"
```

Rebuild and test your app!

---

## 💳 **Step 6: Configure Stripe Webhooks**

1. Go to https://dashboard.stripe.com
2. Developers → Webhooks
3. "Add endpoint"
4. Endpoint URL: `https://homework-helper-api.azurewebsites.net/api/payment/webhook`
5. Events to send:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
6. Copy the **Signing secret**
7. Add to Azure App Service Configuration as `STRIPE_WEBHOOK_SECRET`

---

## 📊 **Monitoring & Logs**

### **View Logs**

1. Go to App Service
2. Click "**Log stream**" (left menu)
3. See real-time logs

### **Or via CLI:**

```bash
az webapp log tail \
  --resource-group homework-helper-rg \
  --name homework-helper-api
```

### **Monitor Database**

1. Go to PostgreSQL resource
2. Click "**Metrics**" (left menu)
3. View connections, CPU, storage

---

## 💰 **Cost Breakdown**

| Service | Tier | Monthly Cost |
|---------|------|--------------|
| PostgreSQL (Burstable B1ms) | 32 GB storage | ~$12-20 |
| App Service (Basic B1) | 1.75 GB RAM | ~$13-55 |
| **TOTAL** | | **~$25-75** |

### **Cost Optimization Tips:**

1. **Start small**: Use Basic/Burstable tiers
2. **Scale up** only when you have users
3. **Auto-shutdown**: Enable for non-production databases
4. **Reserved instances**: Save 30-50% if you commit 1-3 years

---

## 🔒 **Security Checklist**

Before going live:

- [ ] Change default admin password
- [ ] Use strong database password
- [ ] Enable Azure Firewall rules (restrict database access)
- [ ] Use Stripe live keys (not test keys)
- [ ] Enable HTTPS only (App Service does this by default)
- [ ] Set up Azure Key Vault for secrets
- [ ] Enable database backups
- [ ] Configure CORS properly
- [ ] Review App Service authentication

---

## 🚀 **Alternative: Cheaper Option**

If you want to minimize costs initially:

### **Use Free/Cheap Alternatives:**

1. **Database:** Supabase Free Tier (500 MB)
   - https://supabase.com
   - Free forever
   - Get PostgreSQL connection string

2. **Backend:** Azure App Service Free Tier
   - Limited to 60 minutes/day
   - OR use Render.com free tier

3. **Total Cost:** $0-10/month

---

## 📈 **Scaling Strategy**

### **Phase 1: 0-100 users**
- PostgreSQL: Burstable B1ms
- App Service: Basic B1
- Cost: ~$25/month

### **Phase 2: 100-1,000 users**
- PostgreSQL: General Purpose GP_Gen5_2
- App Service: Standard S1
- Cost: ~$100/month

### **Phase 3: 1,000+ users**
- PostgreSQL: General Purpose GP_Gen5_4
- App Service: Premium P1V2
- Add Azure Redis Cache
- Cost: ~$300+/month

---

## 🔧 **Troubleshooting**

### **Problem: Can't connect to database**

```bash
# Test connection
psql "postgres://dbadmin@homework-helper-db:PASSWORD@homework-helper-db.postgres.database.azure.com/homework_helper?sslmode=require" -c "SELECT version();"
```

**Solution:** Check firewall rules in PostgreSQL → Networking

### **Problem: App Service won't start**

Check logs:
```bash
az webapp log tail --name homework-helper-api --resource-group homework-helper-rg
```

Common issues:
- Missing environment variables
- Wrong PORT (should be 8080)
- Database connection failed

### **Problem: Admin dashboard shows 404**

Make sure `public/admin/` folder is in your repo and deployed.

---

## 🎯 **Quick Deploy Checklist**

- [ ] Created PostgreSQL database on Azure
- [ ] Ran migration.sql
- [ ] Created App Service on Azure
- [ ] Connected GitHub for auto-deployment
- [ ] Added all environment variables
- [ ] Updated iOS app with new URL
- [ ] Tested admin dashboard login
- [ ] Configured Stripe webhooks
- [ ] Changed default admin password

---

## 📞 **Support Resources**

- **Azure Portal:** https://portal.azure.com
- **Azure Documentation:** https://docs.microsoft.com/azure
- **Azure Status:** https://status.azure.com
- **Pricing Calculator:** https://azure.microsoft.com/pricing/calculator/

---

**Your production-ready subscription system on Azure! 🎉**


