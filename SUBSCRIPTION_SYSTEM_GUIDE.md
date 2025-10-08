# 📚 Homework Helper - Complete Subscription System Guide

## 🎉 **System Overview**

You now have a complete subscription management system with:
- ✅ 14-day free trial for new users
- ✅ Paid subscriptions via Stripe
- ✅ Promo code system (for 3-month, 6-month codes, etc.)
- ✅ Web-based admin dashboard to manage everything
- ✅ iOS app integration
- ✅ Full database tracking

---

## 📂 **What Was Created**

### **iOS App (Swift)**
- `HomeworkHelper/Services/SubscriptionService.swift` - Manages subscriptions in the app

### **Backend (Node.js)**
- `backend/routes/subscription.js` - Subscription API endpoints
- `backend/routes/admin.js` - Admin management endpoints
- `backend/routes/auth.js` - Authentication endpoints
- `backend/routes/payment.js` - Stripe payment integration
- `backend/middleware/auth.js` - User authentication middleware
- `backend/middleware/adminAuth.js` - Admin authentication middleware
- `backend/server-subscription.js` - Main server file
- `backend/package-subscription.json` - Dependencies
- `backend/env-example.txt` - Environment variables template

### **Database**
- `backend/database/migration.sql` - Complete database schema

### **Admin Dashboard (HTML/JS)**
- `backend/public/admin/index.html` - Admin interface
- `backend/public/admin/admin.js` - Dashboard functionality

---

## 🚀 **Setup Instructions**

### **Step 1: Install PostgreSQL Database**

#### **Option A: Local Installation (Mac)**
```bash
# Install via Homebrew
brew install postgresql@15

# Start PostgreSQL
brew services start postgresql@15

# Create database
createdb homework_helper
```

#### **Option B: Hosted Database (Recommended for Production)**
Use one of these services:
- **Supabase** (Free tier available) - https://supabase.com
- **Railway** (Free tier) - https://railway.app
- **Neon** (Free tier) - https://neon.tech
- **Heroku Postgres** - https://www.heroku.com/postgres

### **Step 2: Run Database Migration**

```bash
cd backend

# Copy the DATABASE_URL from your hosting service
# Or for local: postgresql://postgres:password@localhost:5432/homework_helper

psql your_database_url -f database/migration.sql

# You should see: "Migration completed successfully!"
```

This creates:
- ✅ `users` table
- ✅ `promo_codes` table
- ✅ `promo_code_usage` table
- ✅ `subscription_history` table
- ✅ `admin_users` table
- ✅ Default admin account (username: `admin`, password: `admin123`)
- ✅ 3 sample promo codes

### **Step 3: Setup Backend Server**

```bash
cd backend

# Install dependencies
npm install

# Copy environment file
cp env-example.txt .env

# Edit .env with your values
nano .env
```

**Edit `.env` file:**
```env
PORT=3000
NODE_ENV=development

# Database
DB_USER=postgres
DB_HOST=localhost
DB_NAME=homework_helper
DB_PASSWORD=your_password
DB_PORT=5432

# JWT Secrets - GENERATE NEW ONES!
JWT_SECRET=your-random-secret-key-here
ADMIN_JWT_SECRET=your-admin-secret-key-here

# Stripe (get from stripe.com dashboard)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PRICE_ID=price_...
```

**Generate secure JWT secrets:**
```bash
# Generate random secrets
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
# Copy output to JWT_SECRET

node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
# Copy output to ADMIN_JWT_SECRET
```

### **Step 4: Start the Backend Server**

```bash
npm start

# You should see:
# ╔════════════════════════════════════════════════════════╗
# ║   📚 Homework Helper Backend Server                   ║
# ║   🚀 Server running on port 3000                      ║
# ║   🌐 Admin Dashboard: http://localhost:3000/admin     ║
# ╚════════════════════════════════════════════════════════╝
```

### **Step 5: Access Admin Dashboard**

1. Open browser: http://localhost:3000/admin
2. Login with:
   - Username: `admin`
   - Password: `admin123`
3. **IMPORTANT**: Change the default password immediately!

---

## 🎟️ **How to Create Promo Codes**

### **Method 1: Admin Dashboard (Easiest)**

1. Go to http://localhost:3000/admin
2. Login
3. Click "Promo Codes" tab
4. Click "+ Create Promo Code"
5. Fill in:
   - **Code**: `STUDENT2025` (uppercase recommended)
   - **Duration**: `90` (days - for 3 months)
   - **Total Uses**: `50` (leave empty for unlimited)
   - **Description**: `Student discount - 3 months`
6. Click "Create"

### **Method 2: Direct Database**

```sql
INSERT INTO promo_codes (code, duration_days, uses_total, uses_remaining, description)
VALUES ('EARLYBIRD', 180, 100, 100, 'Early adopters - 6 months');
```

### **Promo Code Examples:**

| Code | Duration | Use Case |
|------|----------|----------|
| `WELCOME2025` | 90 days (3 months) | New user welcome |
| `STUDENT50` | 30 days (1 month) | Student discount |
| `YEARLONG` | 365 days (1 year) | Special promotion |
| `VIP` | 180 days (6 months) | VIP users |

---

## 👥 **Managing Users**

### **Via Admin Dashboard**

1. Go to "Users" tab
2. Search by email or user ID
3. Click "View" to see user details
4. Actions you can do:
   - ✅ **Extend subscription** (+30 days, +90 days)
   - ✅ **Activate/Deactivate** user access
   - ✅ **Ban/Unban** user
   - ✅ **View subscription history**

### **Via Database**

```sql
-- View all users
SELECT email, subscription_status, subscription_end_date 
FROM users 
ORDER BY created_at DESC;

-- Activate a user
UPDATE users 
SET is_active = true 
WHERE email = 'user@example.com';

-- Extend subscription by 30 days
UPDATE users 
SET subscription_end_date = subscription_end_date + INTERVAL '30 days'
WHERE email = 'user@example.com';

-- Ban a user
UPDATE users 
SET is_banned = true, 
    banned_reason = 'Violated terms of service'
WHERE email = 'spammer@example.com';
```

---

## 💳 **Setting Up Stripe Payments**

### **Step 1: Create Stripe Account**
1. Go to https://stripe.com
2. Sign up for free
3. Go to Dashboard

### **Step 2: Get API Keys**
1. In Dashboard → Developers → API keys
2. Copy **Secret key** (starts with `sk_test_...`)
3. Add to `.env` as `STRIPE_SECRET_KEY`

### **Step 3: Create Subscription Product**
1. Products → Create Product
2. Name: "Homework Helper Premium"
3. Add pricing:
   - **Price**: $9.99/month (or your price)
   - **Billing**: Recurring, Monthly
4. Copy the **Price ID** (starts with `price_...`)
5. Add to `.env` as `STRIPE_PRICE_ID`

### **Step 4: Setup Webhook**
1. Developers → Webhooks → Add endpoint
2. Endpoint URL: `https://your-domain.com/api/payment/webhook`
3. Events to select:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
4. Copy **Signing secret** (starts with `whsec_...`)
5. Add to `.env` as `STRIPE_WEBHOOK_SECRET`

### **Step 5: Test Payment**
1. Use Stripe test card: `4242 4242 4242 4242`
2. Any future expiry date
3. Any 3-digit CVC

---

## 📱 **iOS App Integration**

### **Add SubscriptionService to Your Project**

The file is already created at:
`HomeworkHelper/Services/SubscriptionService.swift`

### **Add to Xcode Project:**

1. In Xcode, right-click `Services` folder
2. "Add Files to HomeworkHelper..."
3. Select `SubscriptionService.swift`
4. ✅ Check "Copy items if needed"
5. ✅ Check "HomeworkHelper" target

### **Update BackendAPIService.swift**

Make sure your `BackendAPIService.swift` has the correct base URL:

```swift
private let baseURL = "https://your-backend-url.com"  // Change this!
```

### **Usage in Your App**

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        VStack {
            if !subscriptionService.hasAccess {
                PaywallView()
                    .environmentObject(subscriptionService)
            } else {
                // Your main app content
                HomeView()
            }
        }
        .onAppear {
            if let userId = authService.currentUser?.id {
                Task {
                    await subscriptionService.checkSubscriptionStatus(userId: userId)
                }
            }
        }
    }
}
```

### **Create PaywallView**

```swift
struct PaywallView: View {
    @EnvironmentObject var subscriptionService: SubscriptionService
    @State private var promoCode = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Premium Access Required")
                .font(.title)
                .bold()
            
            Text(subscriptionService.getDisplayMessage())
                .foregroundColor(.secondary)
            
            Button("Subscribe for $9.99/month") {
                Task {
                    try? await subscriptionService.initiateSubscription(userId: "user_id")
                }
            }
            .buttonStyle(.borderedProminent)
            
            // Promo code section
            HStack {
                TextField("Promo Code", text: $promoCode)
                    .textFieldStyle(.roundedBorder)
                
                Button("Apply") {
                    Task {
                        do {
                            let message = try await subscriptionService.activatePromoCode(
                                promoCode,
                                userId: "user_id"
                            )
                            // Show success alert
                        } catch {
                            // Show error alert
                        }
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}
```

---

## 🌐 **Deploying to Production**

### **Option 1: Render (Recommended - Free Tier)**

1. Go to https://render.com
2. Sign up for free
3. Create New → Web Service
4. Connect your GitHub repo
5. Settings:
   - Build Command: `cd backend && npm install`
   - Start Command: `cd backend && npm start`
6. Add Environment Variables (from your `.env` file)
7. Deploy!

### **Option 2: Railway**

1. Go to https://railway.app
2. Sign up
3. New Project → Deploy from GitHub
4. Select your repo
5. Add environment variables
6. Deploy!

### **Option 3: Heroku**

```bash
# Install Heroku CLI
brew tap heroku/brew && brew install heroku

# Login
heroku login

# Create app
heroku create homework-helper-backend

# Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# Set environment variables
heroku config:set JWT_SECRET=your_secret
heroku config:set STRIPE_SECRET_KEY=your_stripe_key

# Deploy
git push heroku main
```

---

## 🔒 **Security Checklist**

Before going live:

- [ ] Change default admin password
- [ ] Generate new JWT secrets (use crypto.randomBytes)
- [ ] Use environment variables (never commit secrets to git)
- [ ] Enable HTTPS (SSL certificate)
- [ ] Update Stripe to live mode (use `sk_live_...` keys)
- [ ] Set up rate limiting
- [ ] Enable database backups
- [ ] Use strong passwords for database

---

## 📊 **Analytics & Monitoring**

### **Check User Stats**

```sql
-- Active users
SELECT COUNT(*) FROM users 
WHERE subscription_end_date > NOW() AND is_active = true;

-- Trial users
SELECT COUNT(*) FROM users WHERE subscription_status = 'trial';

-- Revenue (needs payment data)
SELECT SUM(amount) FROM payments WHERE created_at > NOW() - INTERVAL '30 days';

-- Most used promo codes
SELECT pc.code, COUNT(pcu.id) as uses
FROM promo_codes pc
LEFT JOIN promo_code_usage pcu ON pc.id = pcu.promo_code_id
GROUP BY pc.id
ORDER BY uses DESC;
```

---

## 🐛 **Troubleshooting**

### **Problem: Can't login to admin dashboard**
**Solution:** Check your admin user exists:
```sql
SELECT * FROM admin_users WHERE username = 'admin';
```
If not, run the migration again.

### **Problem: Promo code not working**
**Solution:** Check if code is active:
```sql
SELECT * FROM promo_codes WHERE code = 'YOUR_CODE';
```

### **Problem: Payment webhook not working**
**Solution:**
1. Check Stripe webhook secret is correct
2. Test webhook in Stripe dashboard
3. Check server logs for errors

### **Problem: iOS app can't connect to backend**
**Solution:**
1. Check backend URL in `BackendAPIService.swift`
2. Verify backend is running
3. Check firewall/CORS settings

---

## 📞 **Support & Documentation**

### **API Endpoints**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/subscription/status` | GET | Check user's subscription |
| `/api/subscription/activate-promo` | POST | Activate promo code |
| `/api/payment/create-checkout-session` | POST | Start payment flow |
| `/api/admin/users` | GET | List all users |
| `/api/admin/promo-codes` | GET | List promo codes |

### **Database Tables**

- `users` - All user accounts
- `promo_codes` - Promotional codes
- `promo_code_usage` - Track who used which codes
- `subscription_history` - Audit log of all changes
- `admin_users` - Admin accounts

---

## 🎉 **You're All Set!**

Your complete subscription system is ready. You can now:

✅ Track users with 14-day free trials  
✅ Charge subscriptions via Stripe  
✅ Give out promo codes for 3 months, 6 months, etc.  
✅ Manage everything from your web dashboard  
✅ Control access from the backend database  

**Admin Dashboard:** http://localhost:3000/admin (or your deployed URL)

Enjoy managing your Homework Helper app! 🚀📚


