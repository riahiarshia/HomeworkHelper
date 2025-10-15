# Environment Synchronization Guide

This guide explains how to maintain consistency between your local development environment and Azure production.

## 🎯 Problem Solved

You mentioned that your local development and Azure production databases were different in terms of tables and schema. This guide provides a complete solution to:

1. **Sync production database to local** - Copy production data and schema to your laptop
2. **Deploy local changes to production** - Push your changes to Azure safely
3. **Maintain consistency** - Keep both environments identical

## 📁 Scripts Overview

I've created several scripts in the `backend/scripts/` directory:

### 🔄 `sync-prod-to-local.sh`
- **Purpose**: Copy production database to local development
- **When to use**: When you want to sync your local database with production
- **What it does**:
  - Backs up your current local database
  - Exports production database
  - Imports production data to local
  - Updates local environment configuration

### 🏗️ `setup-local-from-prod.sh`
- **Purpose**: Complete local setup from scratch using production
- **When to use**: First time setup or when you want to completely reset local environment
- **What it does**:
  - Installs dependencies
  - Sets up PostgreSQL
  - Syncs production database
  - Configures local environment
  - Verifies everything works

### 🚀 `deploy-to-azure.sh`
- **Purpose**: Deploy local changes to Azure production
- **When to use**: When you want to push your local changes to production
- **What it does**:
  - Runs pre-deployment checks (tests, linting)
  - Backs up production database
  - Deploys code to Azure
  - Verifies deployment

### 🔧 `maintain-sync.sh`
- **Purpose**: Master script to manage all synchronization tasks
- **When to use**: For all synchronization operations
- **Commands**:
  - `./scripts/maintain-sync.sh sync-db` - Sync database
  - `./scripts/maintain-sync.sh deploy` - Deploy to production
  - `./scripts/maintain-sync.sh setup` - Complete local setup
  - `./scripts/maintain-sync.sh check` - Check sync status

## 🚀 Quick Start

### First Time Setup (Complete Local Setup from Production)

```bash
cd backend
./scripts/setup-local-from-prod.sh
```

This will:
1. Install all dependencies
2. Set up PostgreSQL locally
3. Copy production database to local
4. Configure local environment
5. Verify everything works

### Regular Database Sync (When Production Has New Changes)

```bash
cd backend
./scripts/sync-prod-to-local.sh
```

This will:
1. Back up your current local database
2. Copy production database to local
3. Update local configuration

### Deploy Local Changes to Production

```bash
cd backend
./scripts/deploy-to-azure.sh
```

This will:
1. Run tests and checks
2. Back up production database
3. Deploy your changes to Azure
4. Verify deployment

### Check Synchronization Status

```bash
cd backend
./scripts/maintain-sync.sh check
```

This will show you:
- Git status
- Database connection status
- Environment configuration status
- Whether environments are in sync

## ⚙️ Prerequisites

Before running any scripts, make sure you have:

1. **PostgreSQL installed locally**
   ```bash
   # macOS
   brew install postgresql@16
   brew services start postgresql@16
   
   # Ubuntu
   sudo apt-get install postgresql postgresql-contrib
   sudo service postgresql start
   ```

2. **Azure CLI installed and logged in**
   ```bash
   # Install Azure CLI
   # macOS: brew install azure-cli
   # Ubuntu: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   
   # Login to Azure
   az login
   ```

3. **Production DATABASE_URL**
   ```bash
   # Set your production database URL
   export DATABASE_URL="postgresql://username:password@host:port/database"
   
   # Or add it to your .env file
   echo "DATABASE_URL=postgresql://username:password@host:port/database" >> .env
   ```

## 🔧 Configuration

### Local Database Configuration

The scripts use these default local database settings:
- **Database Name**: `homework_helper_dev`
- **Username**: `postgres`
- **Password**: `dev_password_123`
- **Host**: `localhost`
- **Port**: `5432`

You can modify these in the scripts if needed.

### Environment Files

The scripts will create/update these files:
- `.env.development` - Local development environment variables
- `deployment.log` - Deployment history
- `backups/` - Database backup files

## 📊 Database Schema

Your production database includes these tables (from the migration files):

### Core Tables (from `database/migration.sql`):
- `users` - User accounts and subscription info
- `promo_codes` - Promotional codes
- `promo_code_usage` - Promo code usage tracking
- `subscription_history` - Subscription event history
- `admin_users` - Admin accounts

### Additional Tables (from migrations 004-008):
- `device_logins` - Device tracking for fraud detection
- `fraud_flags` - Suspicious activity flags
- `user_devices` - User device preferences
- `homework_submissions` - Homework submission tracking
- `user_api_usage` - API usage tracking
- `entitlements_ledger` - Apple subscription ledger (PII-free)
- `user_entitlements` - User-linked Apple subscriptions

## 🔄 Recommended Workflow

### Daily Development Workflow:

1. **Start of day** - Sync with production:
   ```bash
   cd backend
   ./scripts/maintain-sync.sh sync-db
   ```

2. **Make your changes** - Develop locally with production data

3. **Before deploying** - Check status:
   ```bash
   ./scripts/maintain-sync.sh check
   ```

4. **Deploy changes**:
   ```bash
   ./scripts/deploy-to-azure.sh
   ```

### Weekly Maintenance:

1. **Check synchronization**:
   ```bash
   ./scripts/maintain-sync.sh check
   ```

2. **Clean up old backups**:
   ```bash
   # Remove backups older than 30 days
   find backend/backups -name "*.sql" -mtime +30 -delete
   ```

## 🚨 Troubleshooting

### Common Issues:

1. **"PostgreSQL not found"**
   ```bash
   # Install PostgreSQL
   brew install postgresql@16  # macOS
   sudo apt-get install postgresql  # Ubuntu
   ```

2. **"Cannot connect to production database"**
   - Check your DATABASE_URL
   - Verify network connection
   - Check Azure firewall settings

3. **"Local database connection failed"**
   - Start PostgreSQL: `brew services start postgresql@16`
   - Check if port 5432 is available

4. **"Permission denied"**
   ```bash
   # Make scripts executable
   chmod +x backend/scripts/*.sh
   ```

5. **"Azure CLI not logged in"**
   ```bash
   az login
   ```

### Getting Help:

1. **Check script logs** - Scripts provide detailed output
2. **Verify prerequisites** - Run `./scripts/maintain-sync.sh check`
3. **Check backup files** - Look in `backend/backups/` directory
4. **Review deployment log** - Check `deployment.log` file

## 🔐 Security Notes

- **Never commit production credentials** to git
- **Use environment variables** for sensitive data
- **Backup before deploying** - Scripts do this automatically
- **Test locally first** - Always verify changes work locally

## 📈 Benefits

With this setup, you get:

1. **Identical environments** - Local and production are always in sync
2. **Safe deployments** - Automatic backups and verification
3. **Easy recovery** - Quick rollback if something goes wrong
4. **Consistent data** - Work with real production data locally
5. **Automated workflow** - Scripts handle the complexity

## 🎉 Next Steps

1. **Run the setup script** to sync your local environment with production
2. **Test the workflow** with a small change
3. **Set up regular sync schedule** (daily/weekly)
4. **Customize scripts** for your specific needs

---

**Remember**: Always backup before making changes, and test locally before deploying to production!
