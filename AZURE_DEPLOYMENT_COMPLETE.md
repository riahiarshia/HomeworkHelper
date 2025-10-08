# ✅ Azure Deployment Complete!

**Deployment Date:** October 6, 2025  
**Resource Group:** `homework-helper-rg-f`  
**Location:** Central US

---

## 🎉 **YOUR LIVE SYSTEM IS READY!**

### 🌐 **Admin Dashboard** (Web Browser)
```
https://homework-helper-api.azurewebsites.net/admin
```

**Login Credentials:**
- Username: `admin`
- Password: `admin123`

⚠️ **IMPORTANT:** Change this password immediately after first login!

---

## 📊 **What's Running on Azure**

### 1. **PostgreSQL Database**
- **Server Name:** `homework-helper-db`
- **Full Host:** `homework-helper-db.postgres.database.azure.com`
- **Database:** `homework_helper`
- **Admin User:** `dbadmin`
- **Password:** `HomeworkHelper2025SecurePass`

**Connection String:**
```
postgres://dbadmin:HomeworkHelper2025SecurePass@homework-helper-db.postgres.database.azure.com/homework_helper?sslmode=require
```

**Tables Created:**
- ✅ users
- ✅ promo_codes (with 3 sample codes: WELCOME2025, STUDENT50, EARLYBIRD)
- ✅ promo_code_usage
- ✅ subscription_history
- ✅ admin_users

**Tier:** Burstable B1ms  
**Cost:** ~$12-20/month

---

### 2. **App Service (Backend API)**
- **Name:** `homework-helper-api`
- **URL:** `https://homework-helper-api.azurewebsites.net`

**API Endpoints:**
- Health Check: `https://homework-helper-api.azurewebsites.net/api/health`
- Auth: `https://homework-helper-api.azurewebsites.net/api/auth`
- Subscription: `https://homework-helper-api.azurewebsites.net/api/subscription`
- Admin: `https://homework-helper-api.azurewebsites.net/api/admin`
- Payment: `https://homework-helper-api.azurewebsites.net/api/payment`

**Tier:** Basic B1  
**Cost:** ~$13-55/month

---

## 🎟️ **Sample Promo Codes (Already Created)**

| Code | Duration | Uses | Description |
|------|----------|------|-------------|
| `WELCOME2025` | 90 days (3 months) | 100 | Welcome promo |
| `STUDENT50` | 30 days (1 month) | 50 | Student discount |
| `EARLYBIRD` | 180 days (6 months) | 20 | Early adopters |

You can create more codes in the admin dashboard!

---

## 🚀 **How to Use the Admin Dashboard**

### **Step 1: Access the Dashboard**
Open in your browser:
```
https://homework-helper-api.azurewebsites.net/admin
```

### **Step 2: Login**
- Username: `admin`
- Password: `admin123`

### **Step 3: Dashboard Features**

**📊 Dashboard Tab:**
- View total users
- Active subscriptions
- Trial users  
- Expired subscriptions

**👥 Users Tab:**
- View all users
- Search by email or ID
- Filter by subscription status
- Actions:
  - View user details
  - Activate/Deactivate access
  - Ban/Unban users
  - Extend subscriptions (+30 days, +90 days)

**🎟️ Promo Codes Tab:**
- View all promo codes
- Create new codes
- Activate/Deactivate codes
- See usage statistics

---

## 📱 **Update Your iOS App**

### **Update Backend URL:**

In `HomeworkHelper/Services/BackendAPIService.swift`, change:

```swift
private let baseURL = "https://homework-helper-api.azurewebsites.net"
```

### **Add SubscriptionService to Xcode:**

1. Right-click `Services` folder in Xcode
2. "Add Files to HomeworkHelper..."
3. Select `SubscriptionService.swift`
4. ✅ Check "Copy items if needed"
5. ✅ Check "HomeworkHelper" target

### **Test the Integration:**

Run your app and:
1. Sign in with Google/Apple
2. User automatically gets 14-day free trial
3. After 14 days, paywall appears
4. User can enter promo code (e.g., `WELCOME2025`)
5. User gets 90 more days!

---

## 💳 **Setting Up Stripe (For Paid Subscriptions)**

### **Step 1: Get Stripe Keys**

1. Go to https://stripe.com and sign up
2. Dashboard → Developers → API keys
3. Copy **Secret key** (starts with `sk_test_...`)

### **Step 2: Update Azure App Service**

```bash
az webapp config appsettings set \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api \
  --settings STRIPE_SECRET_KEY="sk_live_YOUR_LIVE_KEY"
```

### **Step 3: Create Subscription Product**

1. In Stripe: Products → Create Product
2. Name: "Homework Helper Premium"
3. Price: $9.99/month
4. Copy **Price ID** (starts with `price_...`)

```bash
az webapp config appsettings set \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api \
  --settings STRIPE_PRICE_ID="price_YOUR_PRICE_ID"
```

### **Step 4: Setup Stripe Webhook**

1. Stripe: Developers → Webhooks → Add endpoint
2. URL: `https://homework-helper-api.azurewebsites.net/api/payment/webhook`
3. Events:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
4. Copy **Signing secret** (starts with `whsec_...`)

```bash
az webapp config appsettings set \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api \
  --settings STRIPE_WEBHOOK_SECRET="whsec_YOUR_SECRET"
```

---

## 🗄️ **Direct Database Access**

### **Connect from Your Computer:**

```bash
psql "postgres://dbadmin:HomeworkHelper2025SecurePass@homework-helper-db.postgres.database.azure.com/homework_helper?sslmode=require"
```

### **Common Database Commands:**

```sql
-- View all users
SELECT user_id, email, subscription_status, subscription_end_date 
FROM users ORDER BY created_at DESC;

-- View promo codes
SELECT code, duration_days, uses_remaining, active 
FROM promo_codes;

-- Extend a user's subscription by 30 days
UPDATE users 
SET subscription_end_date = subscription_end_date + INTERVAL '30 days'
WHERE email = 'user@example.com';

-- Create a new promo code
INSERT INTO promo_codes (code, duration_days, uses_total, uses_remaining, description)
VALUES ('NEWCODE', 60, 10, 10, 'Custom promo code');
```

---

## 📊 **Monitoring**

### **View Live Logs:**

```bash
az webapp log tail \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api
```

### **View Application Insights:**

1. Go to https://portal.azure.com
2. Navigate to: homework-helper-api
3. Click "Application Insights" (left menu)
4. View performance, errors, and usage

---

## 💰 **Monthly Costs**

| Resource | Tier | Monthly Cost |
|----------|------|--------------|
| PostgreSQL Burstable B1ms | 32 GB storage | $12-20 |
| App Service Basic B1 | 1.75 GB RAM | $13-55 |
| **TOTAL** | | **$25-75** |

Free tier usage:
- App Service: First month might be free (check Azure free tier)
- PostgreSQL: No free tier, starts at ~$12/month

---

## 🎯 **Quick Reference**

### **Your URLs:**
| Service | URL |
|---------|-----|
| Admin Dashboard | https://homework-helper-api.azurewebsites.net/admin |
| API Health Check | https://homework-helper-api.azurewebsites.net/api/health |
| Root Endpoint | https://homework-helper-api.azurewebsites.net |

### **Database:**
| Setting | Value |
|---------|-------|
| Server | homework-helper-db.postgres.database.azure.com |
| Database | homework_helper |
| Username | dbadmin |
| Password | HomeworkHelper2025SecurePass |

### **Admin Credentials (DEFAULT):**
| Field | Value |
|-------|-------|
| Username | admin |
| Password | admin123 |

**⚠️ CHANGE PASSWORD IMMEDIATELY!**

---

## 🔒 **Security Checklist**

Before launching to users:

- [ ] Change admin password in dashboard
- [ ] Update Stripe to live keys (not test)
- [ ] Review Azure firewall rules
- [ ] Enable HTTPS only (already enabled)
- [ ] Set up Azure Key Vault for secrets
- [ ] Configure custom domain (optional)
- [ ] Set up monitoring alerts
- [ ] Test backup/restore

---

## 🆘 **Troubleshooting**

### **Can't access admin dashboard?**
Try: https://homework-helper-api.azurewebsites.net/admin/

### **Database connection error?**
Check firewall rules:
```bash
az postgres flexible-server firewall-rule list \
  --resource-group homework-helper-rg-f \
  --name homework-helper-db
```

### **App not starting?**
View logs:
```bash
az webapp log tail \
  --resource-group homework-helper-rg-f \
  --name homework-helper-api
```

---

## 🎉 **YOU'RE LIVE!**

Your complete subscription system is now running on Azure:

✅ PostgreSQL database with all tables created  
✅ Backend API serving requests  
✅ Admin dashboard accessible via web browser  
✅ 14-day free trial system ready  
✅ Promo code system ready (3 codes already created)  
✅ Payment integration ready (just add Stripe keys)  

**Next:** Open the admin dashboard and start managing users!

**Admin Dashboard:** https://homework-helper-api.azurewebsites.net/admin

---

**Database Server Name:** `homework-helper-db`  
**App Service Name:** `homework-helper-api`  
**Resource Group:** `homework-helper-rg-f`

🚀 Ready for production!


