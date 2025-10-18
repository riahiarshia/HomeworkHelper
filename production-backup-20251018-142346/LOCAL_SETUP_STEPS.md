# Local Development Environment Setup - Step by Step

Follow these steps in order to get your development environment running.

---

## ✅ Step 1: Check Prerequisites

### Check if you have the required software:

```bash
# Check Node.js (need 18+)
node --version

# Check npm
npm --version

# Check PostgreSQL
psql --version

# Check if PostgreSQL is running
pg_isready
```

**If anything is missing:**

```bash
# Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Node.js
brew install node

# Install PostgreSQL
brew install postgresql@16

# Start PostgreSQL
brew services start postgresql@16
```

---

## ✅ Step 2: Get Your Development OpenAI API Key

1. Go to: https://platform.openai.com/api-keys
2. Sign in to your OpenAI account
3. Click "Create new secret key"
4. Name it: **"Homework Helper - Development"**
5. Copy the key (starts with `sk-proj-...`)
6. **Save it somewhere safe!** You'll need it in Step 4.

---

## ✅ Step 3: Install Backend Dependencies

```bash
cd /Users/ar616n/Documents/ios-app/ios-app/backend
npm install
```

This will install all required packages.

---

## ✅ Step 4: Configure Environment Variables

Open your development environment file:

```bash
nano backend/.env.development
```

**Update this line** (around line 33):
```env
OPENAI_API_KEY=sk-proj-YOUR_ACTUAL_DEV_KEY_HERE
```

Paste your actual OpenAI key from Step 2.

**Save and exit:** Press `Ctrl+X`, then `Y`, then `Enter`

Or use your favorite editor:
```bash
code backend/.env.development    # VS Code
open -e backend/.env.development # TextEdit
```

---

## ✅ Step 5: Setup Local Database

```bash
cd /Users/ar616n/Documents/ios-app/ios-app/backend
./setup-local-db.sh
```

This will:
- Create database `homework_helper_dev`
- Run all migrations
- Create admin user (username: admin, password: admin123)

**If the script has issues, manual setup:**
```bash
# Create database
createdb homework_helper_dev

# Run migrations
psql -d homework_helper_dev -f database/migration.sql
psql -d homework_helper_dev -f migrations/004_add_device_tracking.sql
psql -d homework_helper_dev -f migrations/005_add_homework_tracking.sql
psql -d homework_helper_dev -f migrations/006_add_apple_subscription_tracking.sql
```

---

## ✅ Step 6: Start Backend Server

```bash
cd /Users/ar616n/Documents/ios-app/ios-app/backend
npm run dev:watch
```

You should see:
```
╔════════════════════════════════════════════════════════╗
║   📚 Homework Helper Backend Server                   ║
║   🚀 Server running on port 3000                      ║
║   🌐 Environment: development                         ║
╚════════════════════════════════════════════════════════╝
```

**Test it in a new terminal:**
```bash
curl http://localhost:3000/api/health
```

Should return: `{"status":"ok",...}`

**Leave this terminal running!**

---

## ✅ Step 7: Configure iOS App

### 7a. Add Config.swift to Xcode Project

1. Open `HomeworkHelper.xcodeproj` in Xcode
2. In Project Navigator, right-click on "HomeworkHelper" folder
3. Select "Add Files to HomeworkHelper..."
4. Navigate to: `/Users/ar616n/Documents/ios-app/ios-app/HomeworkHelper/Config.swift`
5. **Uncheck** "Copy items if needed"
6. Click "Add"

### 7b. Update BackendAPIService.swift

1. Open `HomeworkHelper/Services/BackendAPIService.swift`
2. Find line ~38 that says:
   ```swift
   private let baseURL = "https://homework-helper-api.azurewebsites.net"
   ```
3. Replace with:
   ```swift
   private let baseURL = Config.apiBaseURL
   ```
4. Save (Cmd+S)

### 7c. Verify Config.swift environment

1. Open `HomeworkHelper/Config.swift`
2. Check line 16:
   ```swift
   static let current: Environment = .development  // ✅ Should be .development
   ```

---

## ✅ Step 8: Run iOS App

1. In Xcode, select your target device (iPhone simulator)
2. Click the Run button ▶️ (or press Cmd+R)
3. Wait for app to build and launch

**You should see:**
- Backend terminal shows API requests
- iOS app connects to `http://localhost:3000`
- Features work with your dev OpenAI key

---

## ✅ Step 9: Verify Everything Works

### Test 1: Health Check
```bash
curl http://localhost:3000/api/health/detailed
```

Should show:
```json
{
  "status": "healthy",
  "environment": "development",
  "services": {
    "openai": {
      "status": "healthy",
      "source": "environment_variable"
    },
    "database": {
      "status": "healthy",
      "connected": true
    }
  }
}
```

### Test 2: Database Connection
```bash
psql -d homework_helper_dev -c "SELECT COUNT(*) FROM users;"
```

Should return a count (probably 0 initially).

### Test 3: iOS App
- Upload a homework image
- Check backend terminal for OpenAI API calls
- Verify feature works

---

## 🎉 Success!

Your local development environment is running!

**Current Setup:**
- ✅ Backend: http://localhost:3000
- ✅ Database: homework_helper_dev (local PostgreSQL)
- ✅ OpenAI: Using your development API key
- ✅ iOS App: Connecting to localhost

**Cost Tracking:**
- All API usage tracked under your "Development" OpenAI key
- Check usage: https://platform.openai.com/usage

---

## 🔧 Daily Development Workflow

```bash
# Terminal 1: Backend
cd /Users/ar616n/Documents/ios-app/ios-app/backend
npm run dev:watch

# Xcode: iOS App
# Open HomeworkHelper.xcodeproj
# Press Run ▶️

# Make changes, test immediately!
```

---

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check if PostgreSQL is running
pg_isready

# If not:
brew services start postgresql@16

# Check if port 3000 is in use
lsof -i :3000
# Kill if needed: kill -9 <PID>
```

### OpenAI API errors
```bash
# Verify key is set
cat backend/.env.development | grep OPENAI_API_KEY

# Should show: OPENAI_API_KEY=sk-proj-...
# If empty, edit .env.development and add your key
```

### Database connection fails
```bash
# Test connection
psql -d homework_helper_dev

# If fails, recreate database
dropdb homework_helper_dev
./setup-local-db.sh
```

### iOS app can't connect
1. Make sure backend is running (`npm run dev:watch`)
2. Check Config.swift has `.development`
3. Check BackendAPIService.swift uses `Config.apiBaseURL`
4. Try `http://127.0.0.1:3000` instead of `localhost`

---

## 📚 Useful Commands

```bash
# View database
psql -d homework_helper_dev

# Check tables
psql -d homework_helper_dev -c "\dt"

# View users
psql -d homework_helper_dev -c "SELECT * FROM users;"

# Reset database
npm run db:reset

# Check logs
tail -f backend/*.log
```

---

## 🎯 Next Steps

Once local dev is working:
1. Develop features
2. Test thoroughly locally
3. When ready, move to staging
4. See: `GIT_WORKFLOW_GUIDE.md` for deployment workflow

