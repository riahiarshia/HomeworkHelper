# Git Workflow Guide
## How to Manage Code from Development to Production

---

## 📚 Git Branch Strategy

```
main (production-ready)
  │
  ├── develop (integration branch)
  │     │
  │     ├── feature/new-homework-feature
  │     ├── feature/improve-ui
  │     └── bugfix/fix-image-upload
  │
  └── hotfix/critical-prod-bug
```

---

## 🔄 Complete Workflow

### 1. Daily Development Work

```bash
# Start from develop branch
git checkout develop
git pull origin develop

# Create a feature branch
git checkout -b feature/add-teacher-mode

# Work on your feature...
# Edit files in backend/ or HomeworkHelper/
# Test locally with: npm run dev:watch

# Commit your changes
git add .
git commit -m "Add teacher mode feature"

# Push to remote
git push origin feature/add-teacher-mode
```

**At this stage:**
- ✅ Code is on a feature branch
- ✅ You test locally with dev config (.env.development)
- ✅ Nothing affects staging or production yet

---

### 2. Merge to Develop (Integration Testing)

```bash
# When feature is ready, merge to develop
git checkout develop
git pull origin develop
git merge feature/add-teacher-mode

# Push to develop
git push origin develop

# Delete feature branch (optional)
git branch -d feature/add-teacher-mode
git push origin --delete feature/add-teacher-mode
```

**At this stage:**
- ✅ Code is merged into develop branch
- ✅ Still nothing deployed to cloud
- ✅ Team can test integration locally

---

### 3. Deploy to Staging (Testing in Cloud)

```bash
# Make sure develop is up to date
git checkout develop
git pull origin develop

# Deploy to staging
./deploy-staging.sh

# This will:
# 1. Run pre-deployment checks
# 2. Package code (without .env files!)
# 3. Deploy to Azure staging
# 4. Staging uses Azure environment variables (not local .env)
```

**At this stage:**
- ✅ Code deployed to staging.azurewebsites.net
- ✅ Uses staging config (Azure App Service settings)
- ✅ Production still untouched
- ✅ Test thoroughly in cloud environment

```bash
# Test staging
curl https://homework-helper-staging.azurewebsites.net/api/health/detailed

# If issues found, fix them:
git checkout -b bugfix/staging-issue
# Fix the bug...
git commit -m "Fix staging issue"
git push origin bugfix/staging-issue

# Merge fix to develop
git checkout develop
git merge bugfix/staging-issue

# Re-deploy to staging
./deploy-staging.sh
```

---

### 4. Release to Production

```bash
# When staging tests pass, merge develop to main
git checkout main
git pull origin main
git merge develop

# Tag the release
git tag -a v1.2.0 -m "Release version 1.2.0 - Teacher Mode"
git push origin main --tags

# Deploy to production
./deploy-production.sh

# This will:
# 1. Run pre-deployment checks (with production validations)
# 2. Package code (without .env files!)
# 3. Deploy to Azure production
# 4. Production uses Key Vault (not local .env)
```

**At this stage:**
- ✅ Code deployed to production
- ✅ Uses production config (Azure Key Vault)
- ✅ Tagged for version tracking
- ✅ Real users get the new feature

---

## 📊 What's in Git vs What's Not

### ✅ COMMITTED TO GIT (Same for everyone):
```
backend/
├── server.js                    ← Code
├── services/azureService.js     ← Code
├── config.js                    ← Code (reads env vars)
├── routes/                      ← Code
├── package.json                 ← Dependencies
├── .env.staging                 ← Template (with placeholders)
├── .env.production              ← Template (with placeholders)
└── env-example.txt              ← Template

HomeworkHelper/
├── Config.swift                 ← Code (environment switcher)
├── Services/                    ← Code
└── Views/                       ← Code

deploy-staging.sh                ← Deployment scripts
deploy-production.sh             ← Deployment scripts
```

### ❌ NOT COMMITTED TO GIT (Local only):
```
backend/
├── .env.development             ← YOUR local config with real keys
├── .env                         ← Local override
├── node_modules/                ← Dependencies (installed locally)
└── *.log                        ← Logs

*.zip                            ← Build artifacts
```

---

## 🎯 Key Points

1. **One Codebase**: Same code runs everywhere
2. **Git Branches**: Use branches for features, not separate codebases
3. **Environment Config**: NOT in git (except templates)
4. **Deployment**: Deploy same code to different environments
5. **Configuration**: Set at deploy time, not in code

---

## 🚦 When to Merge

| Scenario | Action | Deploy To |
|----------|--------|-----------|
| New feature started | Create feature branch | Nothing (local dev) |
| Feature complete | Merge to `develop` | Nothing yet |
| Ready for testing | Deploy from `develop` | Staging |
| Staging tests pass | Merge `develop` → `main` | Production |
| Critical bug in prod | Create `hotfix` branch from `main` | → Fix → `main` → Production |

---

## 🔄 Daily Routine Example

**Monday:**
```bash
git checkout develop
git checkout -b feature/pdf-export
# Code all day, test locally with .env.development
git commit -m "Add PDF export"
```

**Tuesday:**
```bash
# Continue working
git commit -m "Improve PDF formatting"
git push origin feature/pdf-export
```

**Wednesday:**
```bash
# Feature done, merge to develop
git checkout develop
git merge feature/pdf-export
./deploy-staging.sh  # Test in cloud
```

**Thursday:**
```bash
# Staging tests pass!
git checkout main
git merge develop
git tag -a v1.3.0 -m "Add PDF export"
./deploy-production.sh  # Go live!
```

**Same code, tested through multiple environments!** 🚀

---

## 🛡️ Safety Checks

Before each deployment, the scripts automatically:
- ✅ Check health endpoints
- ✅ Verify configuration
- ✅ Confirm environment matches
- ✅ Exclude .env files from package
- ✅ Prompt for confirmation on production

You **cannot accidentally deploy local dev config** to production!

