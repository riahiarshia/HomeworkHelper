# ⚡ Quick Start - Subscription System

## 🚀 **Get Running in 5 Minutes**

### **1. Setup Database (1 min)**
```bash
# Create database
createdb homework_helper

# Run migration
cd backend
psql homework_helper -f database/migration.sql
```

### **2. Start Backend (1 min)**
```bash
cd backend
npm install
cp env-example.txt .env

# Edit .env with your database password
nano .env

npm start
```

### **3. Access Admin Dashboard (1 min)**
```
Open: http://localhost:3000/admin
Login: admin / admin123
```

### **4. Create Your First Promo Code (1 min)**
1. Click "Promo Codes" tab
2. Click "+ Create Promo Code"
3. Code: `WELCOME2025`
4. Duration: `90` (3 months)
5. Click "Create"

### **5. Test in iOS App (1 min)**
- User signs in → Gets 14-day trial automatically
- User enters `WELCOME2025` → Gets 90 more days
- After expiry → Paywall appears

---

## 📋 **Common Tasks**

### **Give User 3 Months Free**
```sql
UPDATE users 
SET subscription_end_date = NOW() + INTERVAL '90 days'
WHERE email = 'user@example.com';
```

### **Create Promo Code for 1 Year**
Admin Dashboard → Promo Codes → Create:
- Code: `YEARLONG`
- Duration: `365`

### **Ban a User**
Admin Dashboard → Users → Search → View → Ban

### **Check Stats**
Admin Dashboard → Dashboard tab shows all stats

---

## 🔑 **Environment Variables You Need**

```env
# Database
DB_PASSWORD=your_postgres_password

# JWT Secrets (generate with: node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
JWT_SECRET=random_64_char_string
ADMIN_JWT_SECRET=random_64_char_string

# Stripe (from stripe.com dashboard)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PRICE_ID=price_...
```

---

## 📱 **iOS Integration**

1. Add `SubscriptionService.swift` to Xcode project
2. Update backend URL in `BackendAPIService.swift`
3. Check subscription on app launch:
```swift
Task {
    await SubscriptionService.shared.checkSubscriptionStatus(userId: userId)
}
```

---

## 🌐 **Deploy to Production**

### **Render (Free)**
1. Push to GitHub
2. render.com → New Web Service
3. Connect repo
4. Add environment variables
5. Deploy

### **Database (Free)**
- Supabase.com → New Project → Copy DATABASE_URL

---

## 🆘 **Help**

- Full Guide: `SUBSCRIPTION_SYSTEM_GUIDE.md`
- Can't login? Default is `admin/admin123`
- Backend not starting? Check `.env` file
- iOS app can't connect? Check backend URL

---

**Admin Dashboard:** http://localhost:3000/admin  
**API Health Check:** http://localhost:3000/api/health

🎉 **Done! Your subscription system is live!**


