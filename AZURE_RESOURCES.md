# 🌐 Azure Resources - Homework Helper

## 📋 **Your Azure Resources**

All resources are in: **`homework-helper-rg-f`** (Central US)

---

## 🗄️ **1. PostgreSQL Database**

**Server Name:** `homework-helper-db`  
**Full Host:** `homework-helper-db.postgres.database.azure.com`  
**Database Name:** `homework_helper`  
**Admin Username:** `dbadmin`  
**Admin Password:** `HomeworkHelper2025SecurePass`  

**Connection String:**
```
postgres://dbadmin:HomeworkHelper2025SecurePass@homework-helper-db.postgres.database.azure.com/homework_helper?sslmode=require
```

**Tier:** Burstable B1ms (1 vCore, 2 GB RAM, 32 GB storage)  
**Cost:** ~$12-20/month

### **How to Connect:**

#### **Via psql (from your computer):**
```bash
psql "postgres://dbadmin:HomeworkHelper2025SecurePass@homework-helper-db.postgres.database.azure.com/homework_helper?sslmode=require"
```

#### **Via Azure Portal:**
1. Go to https://portal.azure.com
2. Navigate to: homework-helper-rg-f → homework-helper-db
3. Click "Connect" for connection instructions

---

## 🖥️ **2. App Service (Backend + Admin Dashboard)**

**App Name:** `homework-helper-api`  
**URL:** `https://homework-helper-api.azurewebsites.net`  
**Plan:** `homework-helper-plan` (Basic B1)  
**Runtime:** Node.js 20 LTS  

**Tier:** Basic B1 (1.75 GB RAM)  
**Cost:** ~$13-55/month

### **URLs:**

**Admin Dashboard:**  
```
https://homework-helper-api.azurewebsites.net/admin
```

**API Endpoint:**  
```
https://homework-helper-api.azurewebsites.net/api
```

**Health Check:**  
```
https://homework-helper-api.azurewebsites.net/api/health
```

### **Admin Login (Default):**
- **Username:** `admin`
- **Password:** `admin123`
- ⚠️ **CHANGE THIS IMMEDIATELY!**

---

## 🔑 **3. Environment Variables (Configured)**

The following are already set in your App Service:

```env
PORT=8080
NODE_ENV=production
APP_URL=https://homework-helper-api.azurewebsites.net

JWT_SECRET=[auto-generated secure key]
ADMIN_JWT_SECRET=[auto-generated secure key]

# Stripe - UPDATE THESE WITH YOUR KEYS
STRIPE_SECRET_KEY=sk_test_REPLACE_WITH_YOUR_KEY
STRIPE_WEBHOOK_SECRET=whsec_REPLACE_WITH_YOUR_SECRET
STRIPE_PRICE_ID=price_REPLACE_WITH_YOUR_PRICE_ID
```

### **To Update Stripe Keys:**

1. Go to https://portal.azure.com
2. Navigate to: homework-helper-api → Configuration
3. Update the Stripe values with your real keys from stripe.com
4. Click Save

---

## 📊 **4. Database Tables (To Be Created)**

Once the PostgreSQL server is ready, run the migration:

```bash
psql "postgres://dbadmin:HomeworkHelper2025SecurePass@homework-helper-db.postgres.database.azure.com/homework_helper?sslmode=require" -f backend/database/migration.sql
```

This creates:
- ✅ `users` table
- ✅ `promo_codes` table (with 3 sample codes)
- ✅ `promo_code_usage` table
- ✅ `subscription_history` table
- ✅ `admin_users` table (with default admin)

---

## 🚀 **Next Steps**

### **1. Wait for Database Creation (5-10 minutes)**

Check status:
```bash
az postgres flexible-server show \
  --resource-group homework-helper-rg-f \
  --name homework-helper-db \
  --query "{Name:name,State:state}"
```

### **2. Create Database**

```bash
az postgres flexible-server db create \
  --resource-group homework-helper-rg-f \
  --server-name homework-helper-db \
  --database-name homework_helper
```

### **3. Run Migration**

```bash
psql "postgres://dbadmin:HomeworkHelper2025SecurePass@homework-helper-db.postgres.database.azure.com/homework_helper?sslmode=require" -f backend/database/migration.sql
```

### **4. Update App Service with Database Connection**

```bash
az webapp config appsettings set \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api \
  --settings DATABASE_URL="postgres://dbadmin:HomeworkHelper2025SecurePass@homework-helper-db.postgres.database.azure.com/homework_helper?sslmode=require"
```

### **5. Deploy Backend Code**

```bash
cd backend
zip -r deploy.zip . -x "*.git*" -x "node_modules/*" -x ".env"
az webapp deployment source config-zip \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api \
  --src deploy.zip
```

### **6. Access Admin Dashboard**

Open: **https://homework-helper-api.azurewebsites.net/admin**

Login:
- Username: `admin`
- Password: `admin123`

### **7. Update iOS App**

In `BackendAPIService.swift`, change:
```swift
private let baseURL = "https://homework-helper-api.azurewebsites.net"
```

---

## 💰 **Monthly Costs**

| Resource | Tier | Cost |
|----------|------|------|
| PostgreSQL B1ms | Burstable, 32 GB | ~$12-20 |
| App Service B1 | Basic, 1.75 GB RAM | ~$13-55 |
| **TOTAL** | | **~$25-75/month** |

---

## 🔧 **Management**

### **View Logs:**
```bash
az webapp log tail \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api
```

### **Restart App Service:**
```bash
az webapp restart \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api
```

### **List All Resources:**
```bash
az resource list \
  --resource-group homework-helper-rg-f \
  --output table
```

---

## 🎯 **Summary**

✅ **Created:**
- Azure App Service: `homework-helper-api`
- App Service Plan: `homework-helper-plan`
- PostgreSQL Server: `homework-helper-db` (in progress)

**Status:** Database creating (5-10 min), backend code ready to deploy once DB is ready

**Admin Dashboard URL:** https://homework-helper-api.azurewebsites.net/admin


