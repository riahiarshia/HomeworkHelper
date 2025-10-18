# Development Environment Setup Guide

Complete guide for setting up local development environment for HomeworkHelper iOS app.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Environment Strategy](#environment-strategy)
3. [Prerequisites](#prerequisites)
4. [Backend Setup (Local)](#backend-setup-local)
5. [iOS App Configuration](#ios-app-configuration)
6. [Running the App](#running-the-app)
7. [Deployment Workflow](#deployment-workflow)
8. [Troubleshooting](#troubleshooting)
9. [Cost Tracking](#cost-tracking)

---

## 🎯 Overview

Your project is set up with three environments:

| Environment | Backend Location | Database | OpenAI Key | Stripe | Purpose |
|-------------|-----------------|----------|------------|--------|---------|
| **Development** | Local (localhost:3000) | Local PostgreSQL | Dev Key | Test Mode | Fast iteration, debugging |
| **Staging** | Azure App Service | Azure PostgreSQL | Dev/Staging Key | Test Mode | Pre-release testing |
| **Production** | Azure App Service | Azure PostgreSQL | Prod Key | Live Mode | Real users, real payments |

**Project Location:** `/Users/ar616n/Documents/ios-app/ios-app`

---

## �� Environment Strategy

```
Development (Local)
      ↓
   [Test & Iterate Fast]
      ↓
Staging (Azure)
      ↓
   [Final Testing - Production-like]
      ↓
Production (Azure)
      ↓
   [Live Users]
```

### Cost Tracking

- **Development OpenAI Key**: Track all dev/testing costs
- **Production OpenAI Key**: Track only real user costs
- Separate keys = clear cost attribution in OpenAI dashboard

---

## ✅ Prerequisites

### 1. Install Homebrew (if not installed)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install PostgreSQL
```bash
brew install postgresql@16
brew services start postgresql@16
```

### 3. Install Node.js (v18+)
```bash
brew install node
node --version  # Should be 18.0.0 or higher
```

### 4. Get API Keys

#### OpenAI API Keys
1. Go to https://platform.openai.com/api-keys
2. Create **TWO** separate keys:
   - `Homework Helper - Development` (for local dev & staging)
   - `Homework Helper - Production` (for production only)
3. Save both keys securely

#### Stripe API Keys (Optional for now)
1. Go to https://dashboard.stripe.com/test/apikeys
2. Copy your test keys (for development)
3. You'll need live keys later for production

---

## 🖥️ Backend Setup (Local)

### Step 1: Install Dependencies

```bash
cd /Users/ar616n/Documents/ios-app/ios-app/backend
npm install
```

### Step 2: Configure Environment

Open `.env.development` and add your **DEVELOPMENT** OpenAI key:

```bash
# Edit this file
nano .env.development

# Or use your favorite editor
code .env.development  # VS Code
open -a Xcode .env.development  # Xcode
```

**Update these lines:**
```env
# Replace with your DEVELOPMENT OpenAI key
OPENAI_API_KEY=sk-proj-dev-YOUR_ACTUAL_DEV_KEY_HERE

# Optional: Add Stripe test keys if testing payments
STRIPE_SECRET_KEY=sk_test_YOUR_TEST_KEY
```

### Step 3: Setup Database

```bash
# Run the setup script
./setup-local-db.sh

# This will:
# ✓ Create database: homework_helper_dev
# ✓ Run all migrations
# ✓ Create admin user (admin/admin123)
```

**If script fails, manual setup:**
```bash
# Create database manually
createdb homework_helper_dev

# Run migrations
psql -d homework_helper_dev -f database/migration.sql
psql -d homework_helper_dev -f migrations/004_add_device_tracking.sql
psql -d homework_helper_dev -f migrations/005_add_homework_tracking.sql
psql -d homework_helper_dev -f migrations/006_add_apple_subscription_tracking.sql
```

### Step 4: Start Backend Server

```bash
# Start in development mode with auto-reload
npm run dev:watch

# You should see:
# ✅ Server running on http://localhost:3000
# ✅ Database connected
# ✅ OpenAI API configured
```

**Test it:**
```bash
# In a new terminal
curl http://localhost:3000/health

# Should return: {"status":"ok"}
```

---

## 📱 iOS App Configuration

### Step 1: Open Config File

Open `HomeworkHelper/Config.swift` in Xcode.

### Step 2: Set Environment

**Line 16** - Change this for different environments:

```swift
// For local development (default)
static let current: Environment = .development

// For staging tests (later)
// static let current: Environment = .staging

// For production release (later)
// static let current: Environment = .production
```

### Step 3: Update BackendAPIService (One-time)

Open `HomeworkHelper/Services/BackendAPIService.swift`.

**Find line 38** and replace:
```swift
// OLD:
private let baseURL = "https://homework-helper-api.azurewebsites.net"

// NEW:
private let baseURL = Config.apiBaseURL
```

This makes it use the Config environment automatically.

### Step 4: Add Config.swift to Xcode Project

1. Open `HomeworkHelper.xcodeproj` in Xcode
2. Right-click on `HomeworkHelper` folder in project navigator
3. Select "Add Files to HomeworkHelper..."
4. Navigate to and select `Config.swift`
5. Make sure "Copy items if needed" is **unchecked** (it's already in the folder)
6. Click "Add"

---

## 🚀 Running the App

### Terminal 1: Backend Server
```bash
cd /Users/ar616n/Documents/ios-app/ios-app/backend
npm run dev:watch
```

### Xcode: iOS App
1. Open `HomeworkHelper.xcodeproj`
2. Select your target device (iPhone simulator or real device)
3. Press ▶️ Run (or Cmd+R)

### The app will now:
- ✅ Connect to your local backend at `http://localhost:3000`
- ✅ Use your development OpenAI key
- ✅ Use local PostgreSQL database
- ✅ Show verbose debug logs

---

## 🔄 Deployment Workflow

### Development Phase (Now)

```bash
# Make changes to backend
cd backend/
# Edit files...

# Backend auto-reloads (if using npm run dev:watch)

# Make changes to iOS app
# Edit in Xcode, press Run to test immediately
```

**Benefits:**
- ⚡ Instant feedback
- 🐛 Easy debugging
- 💰 Free (no Azure costs)
- 📊 Dev costs tracked separately

---

### Staging Phase (Later)

When ready to test in production-like environment:

#### 1. Deploy Backend to Azure Staging

```bash
cd backend/

# Create Azure App Service (staging)
az webapp create \
  --name homework-helper-staging \
  --resource-group your-resource-group \
  --plan your-plan

# Configure environment variables in Azure Portal
# Use values from .env.staging template

# Deploy
zip -r backend.zip . -x "node_modules/*" -x ".git/*"
az webapp deployment source config-zip \
  --resource-group your-resource-group \
  --name homework-helper-staging \
  --src backend.zip
```

#### 2. Update iOS App Config

```swift
// Config.swift line 16
static let current: Environment = .staging
```

#### 3. Test thoroughly before production

---

### Production Phase (Later)

When staging tests pass:

#### 1. Deploy to Production Azure

```bash
# Similar to staging but use production resources
# Use .env.production template values
# Use PRODUCTION OpenAI key
# Use LIVE Stripe keys
```

#### 2. Update iOS App Config

```swift
// Config.swift line 16
static let current: Environment = .production
```

#### 3. Build for App Store

```bash
# In Xcode:
# Product > Archive
# Submit to App Store
```

---

## 🔧 Troubleshooting

### Backend won't start

```bash
# Check if PostgreSQL is running
pg_isready

# If not:
brew services start postgresql@16

# Check if port 3000 is in use
lsof -i :3000

# Kill process if needed
kill -9 <PID>
```

### Database connection fails

```bash
# Test database connection
psql -d homework_helper_dev

# If fails, check .env.development has correct:
DB_NAME=homework_helper_dev
DB_USER=postgres
DB_PASSWORD=dev_password_123
DB_HOST=localhost
DB_PORT=5432
```

### OpenAI API errors

```bash
# Check your key is set
cat backend/.env.development | grep OPENAI_API_KEY

# Test the key
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer YOUR_KEY_HERE"
```

### iOS App can't connect to backend

1. **Check backend is running:** `curl http://localhost:3000/health`
2. **Check Config.swift:** Environment should be `.development`
3. **Check BackendAPIService.swift:** Should use `Config.apiBaseURL`
4. **iOS Simulator networking:** localhost should work, but try `127.0.0.1:3000` if issues

### "localhost refused to connect" on real iPhone

Real iPhones can't access `localhost`. Options:

1. **Use your Mac's IP address:**
   ```bash
   # Find your IP
   ipconfig getifaddr en0
   
   # Update Config.swift temporarily:
   return "http://192.168.x.x:3000"  // Your Mac's IP
   ```

2. **Use Xcode Simulator** for development (easier)

---

## 💰 Cost Tracking

### OpenAI Dashboard

1. Go to https://platform.openai.com/usage
2. You'll see costs separated by API key:
   - Development key: All dev/testing costs
   - Production key: Only real user costs

### Monitoring Costs

```bash
# Check usage in backend logs
grep "OpenAI" backend/logs/*.log

# Monitor database size
psql -d homework_helper_dev -c "SELECT pg_size_pretty(pg_database_size('homework_helper_dev'));"
```

### Cost Optimization Tips

- ✅ Use `gpt-4o-mini` for development (cheaper)
- ✅ Test with small images
- ✅ Cache responses when possible
- ✅ Only use production key for final tests
- ✅ Monitor usage regularly

---

## 📚 Quick Reference

### Useful Commands

```bash
# Backend
cd /Users/ar616n/Documents/ios-app/ios-app/backend
npm run dev:watch          # Start backend with auto-reload
npm run db:setup           # Setup database
npm run db:migrate         # Run migrations
npm run db:reset           # Reset database (WARNING: deletes all data)

# Database
psql -d homework_helper_dev                    # Connect to database
psql -d homework_helper_dev -c "SELECT * FROM users;"  # Query users

# Check what's running
lsof -i :3000              # Check if backend is running
pg_isready                 # Check if PostgreSQL is running
```

### File Locations

- **Backend:** `/Users/ar616n/Documents/ios-app/ios-app/backend/`
- **iOS App:** `/Users/ar616n/Documents/ios-app/ios-app/HomeworkHelper/`
- **Config:** `HomeworkHelper/Config.swift`
- **Environment:** `backend/.env.development`
- **Database:** Local PostgreSQL `homework_helper_dev`

### Default Credentials

- **Database:** `postgres` / `dev_password_123`
- **Admin Portal:** `admin` / `admin123`
- **API:** No auth required for development

---

## 🎓 Next Steps

1. ✅ Complete backend setup
2. ✅ Configure iOS app
3. ✅ Test local development workflow
4. 🔲 Develop features
5. 🔲 Setup Azure staging environment
6. 🔲 Deploy to staging for testing
7. 🔲 Deploy to production
8. 🔲 Submit to App Store

---

## 📞 Need Help?

- **Backend Issues:** Check logs at `backend/` directory
- **iOS Issues:** Check Xcode console
- **Database Issues:** Check PostgreSQL logs with `brew services info postgresql@16`

---

**Happy coding! 🚀**
