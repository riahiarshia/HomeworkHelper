# Database Connection Guide

## 🚨 CRITICAL: Database Environment Distinction

### **Local Development vs Azure Production/Staging**

This project uses **TWO DIFFERENT DATABASES**:

1. **LOCAL DEVELOPMENT** (Mac environment)
   - **Database**: Local PostgreSQL on your Mac
   - **Connection**: Uses local `DATABASE_URL` or individual DB_* variables
   - **Purpose**: Development and testing
   - **⚠️ NEVER USE FOR PRODUCTION FIXES**

2. **AZURE STAGING/PRODUCTION** (Cloud environment)
   - **Database**: Azure PostgreSQL Flexible Server
   - **Connection**: `postgresql://homeworkadmin:Admin123!Staging@homework-helper-staging-db.postgres.database.azure.com:5432/homework_helper_staging?sslmode=require`
   - **Purpose**: Staging and production environments
   - **✅ USE FOR PRODUCTION FIXES**

## 🔧 **How to Identify Which Environment You're In**

### **Local Development (Mac)**
```bash
# When running locally on Mac
node script.js
# Will try to connect to local database (usually fails with "database 'ar616n' does not exist")
```

### **Azure Environment**
```bash
# When running in Azure (Kudu Console, App Service, etc.)
node script.js
# Will connect to Azure PostgreSQL database
```

## 📋 **Database Connection Strings**

### **Local Development**
```bash
# Local PostgreSQL (Mac)
DATABASE_URL=postgresql://username:password@localhost:5432/local_database_name
# OR
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=local_password
DB_NAME=local_database
```

### **Azure Staging**
```bash
# Azure PostgreSQL (Staging)
DATABASE_URL=postgresql://homeworkadmin:Admin123!Staging@homework-helper-staging-db.postgres.database.azure.com:5432/homework_helper_staging?sslmode=require
```

### **Azure Production**
```bash
# Azure PostgreSQL (Production)
DATABASE_URL=postgresql://username:password@production-db.postgres.database.azure.com:5432/production_database?sslmode=require
```

## 🚨 **Common Mistakes to Avoid**

### **❌ DON'T DO THIS:**
```bash
# Running database fixes locally on Mac
cd /Users/ar616n/Documents/ios-app/ios-app/backend
node fix-database.js  # ❌ This will try to connect to local DB
```

### **✅ DO THIS INSTEAD:**
```bash
# Run database fixes in Azure environment
# Go to: https://homework-helper-staging.scm.azurewebsites.net
# Navigate to: Debug Console → CMD
node fix-database.js  # ✅ This connects to Azure DB
```

## 🔍 **How to Check Which Database You're Connected To**

### **In Scripts:**
```javascript
// Add this to any database script to verify connection
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'staging' 
    ? { rejectUnauthorized: false } 
    : false
});

async function checkConnection() {
  try {
    const result = await pool.query('SELECT current_database() as db_name, inet_server_addr() as server_ip');
    console.log(`Connected to database: ${result.rows[0].db_name}`);
    console.log(`Server IP: ${result.rows[0].server_ip}`);
    
    if (result.rows[0].db_name === 'homework_helper_staging') {
      console.log('✅ Connected to Azure Staging Database');
    } else if (result.rows[0].db_name === 'homework_helper') {
      console.log('✅ Connected to Azure Production Database');
    } else {
      console.log('⚠️  Connected to Local Database - NOT SUITABLE FOR PRODUCTION FIXES');
    }
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
  }
}
```

## 📝 **Scripts That Should Only Run in Azure**

### **Production/Staging Database Fixes:**
- `auto-fix-database.js`
- `fix-azure-database-complete.js`
- `complete-fix.js`
- `fix-existing-structure.js`
- `final-database-fix.js`

### **These scripts MUST be run in Azure environment:**
1. **Azure Kudu Console**: `https://homework-helper-staging.scm.azurewebsites.net`
2. **Azure App Service**: Where `DATABASE_URL` is configured
3. **Azure Cloud Shell**: With proper database access

## 🛠️ **Environment Detection Script**

Create this script to always check your environment:

```javascript
// environment-check.js
const { Pool } = require('pg');

async function checkEnvironment() {
  console.log('🔍 ENVIRONMENT CHECK');
  console.log('===================');
  
  // Check environment variables
  console.log(`NODE_ENV: ${process.env.NODE_ENV || 'undefined'}`);
  console.log(`WEBSITE_SITE_NAME: ${process.env.WEBSITE_SITE_NAME || 'undefined'}`);
  console.log(`DATABASE_URL: ${process.env.DATABASE_URL ? 'SET' : 'NOT SET'}`);
  
  if (process.env.DATABASE_URL) {
    try {
      const pool = new Pool({
        connectionString: process.env.DATABASE_URL,
        ssl: { rejectUnauthorized: false }
      });
      
      const result = await pool.query('SELECT current_database() as db_name, inet_server_addr() as server_ip');
      const dbName = result.rows[0].db_name;
      const serverIp = result.rows[0].server_ip;
      
      console.log(`Database: ${dbName}`);
      console.log(`Server IP: ${serverIp}`);
      
      if (dbName.includes('staging')) {
        console.log('✅ AZURE STAGING ENVIRONMENT - Safe for production fixes');
      } else if (dbName.includes('homework_helper')) {
        console.log('✅ AZURE PRODUCTION ENVIRONMENT - Safe for production fixes');
      } else {
        console.log('⚠️  LOCAL DEVELOPMENT ENVIRONMENT - NOT suitable for production fixes');
        console.log('   Run this script in Azure environment instead');
      }
      
      await pool.end();
    } catch (error) {
      console.error('❌ Database connection failed:', error.message);
    }
  } else {
    console.log('❌ DATABASE_URL not set - cannot connect to database');
  }
}

checkEnvironment();
```

## 📋 **Quick Reference**

### **For Production Fixes:**
- ✅ Use Azure Kudu Console
- ✅ Use Azure App Service environment
- ✅ Use Azure Cloud Shell
- ✅ Ensure `DATABASE_URL` points to Azure database

### **For Local Development:**
- ✅ Use local PostgreSQL
- ✅ Use local `DATABASE_URL`
- ✅ Test scripts locally first
- ❌ Don't run production fixes locally

## 🚨 **Remember:**
- **Local Mac environment** = Development only
- **Azure environment** = Production fixes
- **Always check which database you're connected to**
- **When in doubt, run environment check script first**
