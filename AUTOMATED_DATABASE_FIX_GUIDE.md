# Automated Database Fix Guide

## 🎯 Purpose
This guide provides automated solutions for fixing database issues in the staging environment without manual intervention. The scripts can connect directly to the Azure PostgreSQL database and populate missing data.

## 📋 Prerequisites
- Azure PostgreSQL database with `DATABASE_URL` configured
- Node.js environment with `pg` module available
- Proper database permissions

## 🚀 Quick Fix (Automated)

### Option 1: Run the Automated Script
```bash
# In Azure Kudu Console or local environment with DATABASE_URL
node auto-fix-database.js
```

### Option 2: Use the Deployment Script
```bash
# Make executable and run
chmod +x deploy-auto-fix.sh
./deploy-auto-fix.sh
```

## 🔧 What the Automated Script Does

### 1. **Database Connection Test**
- Tests connection to Azure PostgreSQL
- Verifies DATABASE_URL configuration
- Reports current database state

### 2. **Data Population**
- **Sample Users**: Creates 5 test users with different subscription statuses
- **API Usage Data**: Populates analytics data for testing
- **Device Logins**: Adds device tracking data
- **Promo Codes**: Creates sample promotional codes
- **Database Views**: Sets up analytics views

### 3. **Admin User Verification**
- Ensures admin user exists with correct credentials
- Creates admin user if missing
- Verifies login credentials

### 4. **Comprehensive Reporting**
- Shows before/after statistics
- Lists created users and promo codes
- Provides admin portal access information

## 📊 Expected Results

After running the automated fix, your admin portal will show:

### Dashboard
- User statistics and metrics
- Active/trial/expired user counts
- API usage analytics

### Users Tab
- 5 sample users with different statuses:
  - `demo@example.com` (active, 30 days)
  - `trial@example.com` (trial, 7 days)
  - `expired@example.com` (expired)
  - `student@example.com` (active, 60 days)
  - `teacher@example.com` (active, 90 days)

### API Usage Tab
- Analytics data for all users
- Token usage statistics
- Cost tracking information

### Promo Codes Tab
- 5 sample promo codes:
  - `WELCOME2024` (7 days, 100 uses)
  - `STUDENT50` (14 days, 50 uses)
  - `TEACHER30` (30 days, 25 uses)
  - `BACKTOSCHOOL` (21 days, 75 uses)
  - `HOLIDAY2024` (14 days, 100 uses)

### Device Analytics
- Device login tracking data
- Multiple devices per user
- Login timestamps and IP addresses

## 🔑 Admin Credentials

After running the fix, you can access the admin portal with:

- **URL**: `https://homework-helper-staging.azurewebsites.net/admin/`
- **Username**: `admin`
- **Password**: `Admin123!Staging`

## 🛠️ Manual Database Access (If Needed)

### Azure Cloud Shell Method
```bash
# Connect to database
psql 'host=homework-helper-staging-db.postgres.database.azure.com port=5432 dbname=homework_helper_staging user=homeworkadmin password=Admin123!Staging sslmode=require'

# Run SQL commands
\dt  # List tables
SELECT COUNT(*) FROM users;  # Check user count
```

### Direct SQL Commands
```sql
-- Check existing data
SELECT COUNT(*) as user_count FROM users;
SELECT COUNT(*) as api_usage_count FROM user_api_usage;
SELECT COUNT(*) as promo_count FROM promo_codes;

-- View sample data
SELECT email, subscription_status FROM users LIMIT 5;
SELECT code, description FROM promo_codes;
```

## 🔍 Troubleshooting

### Common Issues

1. **"Cannot find module 'pg'"**
   - Solution: Run in Azure environment where dependencies are installed
   - Alternative: Use manual SQL commands

2. **"Database connection failed"**
   - Check DATABASE_URL environment variable
   - Verify database server accessibility
   - Check firewall rules

3. **"Permission denied"**
   - Ensure proper database permissions
   - Check user credentials

4. **"Tables already exist"**
   - This is normal - the script handles existing tables
   - Data will be added without conflicts

### Debug Commands

```bash
# Check environment variables
echo $DATABASE_URL

# Test database connection
node -e "console.log('Testing connection...'); require('pg').Pool({connectionString: process.env.DATABASE_URL}).query('SELECT NOW()').then(r => console.log('Success:', r.rows[0])).catch(e => console.error('Error:', e.message))"

# Check script availability
ls -la auto-fix-database.js
```

## 📝 Future Use

### For New Deployments
1. Deploy the automated fix script to Azure
2. Run `node auto-fix-database.js` in Azure environment
3. Verify admin portal functionality

### For Database Resets
1. Clear existing data if needed
2. Run the automated fix script
3. Verify all data is populated correctly

### For Testing
1. Use the script to populate test data
2. Run automated tests
3. Clear data when done

## 🔄 Maintenance

### Regular Checks
- Run the script monthly to ensure data freshness
- Monitor admin portal functionality
- Update sample data as needed

### Data Updates
- Modify the script to add new sample data
- Update user scenarios for testing
- Add new promo codes as needed

## 📞 Support

If you encounter issues:

1. **Check the error messages** in the script output
2. **Verify environment variables** are set correctly
3. **Test database connectivity** manually
4. **Check Azure App Service logs** for additional details

The automated script provides comprehensive error handling and detailed reporting to help diagnose any issues.
