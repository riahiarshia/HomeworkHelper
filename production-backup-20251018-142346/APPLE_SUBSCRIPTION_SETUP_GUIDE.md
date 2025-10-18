# Apple Subscription System - Complete Setup Guide

## 🎯 Overview

This guide implements a **production-ready Apple subscription system** following Apple's latest best practices (2024). The system includes:

- ✅ **Server-side receipt validation** (Industry standard)
- ✅ **Apple Server Notifications** (Real-time updates)
- ✅ **Comprehensive error handling** (All edge cases)
- ✅ **Database tracking** (Full audit trail)
- ✅ **Security best practices** (Never trust client)

---

## 🏗️ Architecture

```
┌─────────────┐    Receipt Validation    ┌─────────────────┐
│  iOS App    │─────────────────────────▶│  Your Backend   │
│ (StoreKit)  │                          │                 │
└─────────────┘                          └─────────┬───────┘
                                                   │
                                                   │ Apple API
                                                   ▼
┌─────────────┐    Server Notifications  ┌─────────────────┐
│   Apple     │◄─────────────────────────│  Your Backend   │
│  Servers    │                          │                 │
└─────────────┘                          └─────────────────┘
```

---

## 📋 Implementation Checklist

### ✅ **Phase 1: Backend Implementation (COMPLETED)**

#### 1. Receipt Validation Endpoint
- **URL:** `POST /api/subscription/apple/validate-receipt`
- **Purpose:** Validates receipts with Apple's servers
- **Security:** Server-side validation only
- **Response:** Updates database with validated subscription data

#### 2. Server Notifications Webhook
- **URL:** `POST /api/subscription/apple/webhook`
- **Purpose:** Receives real-time updates from Apple
- **Events:** Renewals, cancellations, refunds, billing issues
- **Response:** Always returns 200 OK immediately

#### 3. Database Schema Updates
- **New Columns:**
  - `apple_original_transaction_id` - Links transactions to users
  - `apple_product_id` - Product identifier (e.g., `com.homeworkhelper.monthly`)
  - `apple_environment` - Production or Sandbox
- **Indexes:** Optimized for fast lookups
- **History:** Complete audit trail of all subscription events

#### 4. iOS App Updates
- **Receipt Sending:** App now sends receipt data (not just status)
- **Purchase Flow:** Validates with backend after every purchase
- **Transaction Listener:** Validates all transaction updates
- **Error Handling:** Comprehensive error reporting

---

### ⏳ **Phase 2: App Store Connect Configuration (YOUR TASKS)**

#### 1. Get Apple Shared Secret
1. Go to **App Store Connect** → Your App
2. Click **"App Information"**
3. Scroll to **"App Store Connect Shared Secret"**
4. Copy the secret (you'll need this for Azure environment variables)

#### 2. Configure Webhook URL
1. Go to **App Store Connect** → **Users and Access**
2. Click **"Integrations"** tab
3. Click **"Webhooks"** in left sidebar
4. Add URL: `https://homework-helper-api.azurewebsites.net/api/subscription/apple/webhook`
5. Click **"Save"**

#### 3. Verify Subscription Products
1. Go to **Apps** → **HomeworkHelper** → **Monetization** → **Subscriptions**
2. Ensure product ID matches: `com.homeworkhelper.monthly`
3. Verify pricing and availability settings
4. Submit for review if not already done

---

### ⏳ **Phase 3: Azure Configuration (YOUR TASKS)**

#### 1. Set Environment Variables
In Azure App Service Configuration, add:
```bash
APPLE_SHARED_SECRET=your_shared_secret_from_app_store_connect
```

#### 2. Deploy Backend Changes
Run the deployment script:
```bash
cd backend
./deploy-apple-subscriptions.sh
```

#### 3. Test Endpoints
Verify endpoints are accessible:
```bash
# Test webhook endpoint
curl -X POST https://homework-helper-api.azurewebsites.net/api/subscription/apple/webhook \
  -H "Content-Type: application/json" \
  -d '{"test": true}'

# Should return: {"received":true}
```

---

### ⏳ **Phase 4: Testing (YOUR TASKS)**

#### 1. Sandbox Testing
1. Create test Apple ID in App Store Connect
2. Install TestFlight build
3. Make test purchases
4. Verify webhook notifications are received
5. Check database updates

#### 2. End-to-End Testing
1. **Purchase Flow:** User subscribes → Receipt validated → Database updated
2. **Renewal Flow:** Auto-renewal → Webhook received → Database updated
3. **Cancellation Flow:** User cancels → Webhook received → Database updated
4. **Refund Flow:** Apple issues refund → Webhook received → Database updated

---

## 🔧 Technical Details

### Apple Notification Types Handled

| Notification | Description | Action |
|--------------|-------------|---------|
| `INITIAL_BUY` | First subscription purchase | Activate subscription |
| `DID_RENEW` | Auto-renewal succeeded | Extend subscription |
| `DID_FAIL_TO_RENEW` | Payment failed | Set grace period |
| `DID_CHANGE_RENEWAL_STATUS` | User cancelled auto-renew | Mark as cancelled |
| `REFUND` | Apple issued refund | Deactivate subscription |
| `REVOKE` | Subscription revoked | Deactivate subscription |
| `PRICE_INCREASE_CONSENT` | User accepted price increase | Log event |
| `DID_RECOVER` | Subscription recovered | Reactivate subscription |

### Receipt Validation Process

1. **iOS App** completes purchase
2. **App** sends receipt to backend
3. **Backend** validates with Apple's servers
4. **Apple** returns subscription status
5. **Backend** updates database
6. **Backend** logs all events

### Security Features

- ✅ **Server-side validation only** (Never trust iOS app)
- ✅ **Receipt verification** with Apple's servers
- ✅ **Original transaction ID tracking** (Prevents duplicate subscriptions)
- ✅ **Environment detection** (Sandbox vs Production)
- ✅ **Comprehensive logging** (Full audit trail)

---

## 🚀 Production Readiness

### Performance Optimizations
- ✅ **Async webhook processing** (Fast response to Apple)
- ✅ **Database indexes** (Fast user lookups)
- ✅ **Error handling** (Graceful degradation)
- ✅ **Logging** (Debugging and monitoring)

### Monitoring & Alerts
- ✅ **Subscription event logging** (All events tracked)
- ✅ **Error logging** (Failed validations logged)
- ✅ **Performance monitoring** (Response times tracked)

### Scalability
- ✅ **Stateless design** (Horizontal scaling ready)
- ✅ **Database optimized** (Indexed queries)
- ✅ **Async processing** (Non-blocking operations)

---

## 📱 App Store Review Preparation

### Required Information for App Store
1. **Subscription Description:** Clear explanation of what users get
2. **Pricing Justification:** Why the price is fair
3. **Auto-renewal Disclosure:** Clear terms about automatic billing
4. **Restore Purchases:** Implemented and tested
5. **Privacy Policy:** Updated to include subscription data handling

### App Store Review Checklist
- ✅ **Subscription products configured** in App Store Connect
- ✅ **Webhook URL configured** and tested
- ✅ **Receipt validation implemented** (server-side)
- ✅ **Restore purchases** functionality
- ✅ **Subscription management** (in iOS Settings)
- ✅ **Clear subscription terms** in app

---

## 🔍 Troubleshooting

### Common Issues

#### 1. Webhook Not Receiving Notifications
**Symptoms:** No webhook calls in logs
**Solutions:**
- Verify webhook URL is correct in App Store Connect
- Check Azure App Service is running
- Ensure endpoint returns 200 status
- Test with curl command

#### 2. Receipt Validation Failing
**Symptoms:** Receipt validation errors
**Solutions:**
- Check `APPLE_SHARED_SECRET` is set correctly
- Verify receipt is base64 encoded
- Check Apple's server status
- Try both production and sandbox endpoints

#### 3. Database Updates Not Working
**Symptoms:** Subscriptions not updating in database
**Solutions:**
- Check database connection
- Verify migration was run successfully
- Check for foreign key constraints
- Review error logs

### Debug Commands

```bash
# Test webhook endpoint
curl -X POST https://homework-helper-api.azurewebsites.net/api/subscription/apple/webhook \
  -H "Content-Type: application/json" \
  -d '{"test": true}'

# Check Azure logs
az webapp log tail --name homework-helper-api --resource-group your-resource-group

# Test database connection
node -e "
const { Pool } = require('pg');
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
pool.query('SELECT COUNT(*) FROM users').then(console.log).catch(console.error);
"
```

---

## 📞 Support

### Apple Developer Support
- **Documentation:** https://developer.apple.com/in-app-purchase/
- **Server Notifications:** https://developer.apple.com/documentation/appstoreservernotifications
- **Receipt Validation:** https://developer.apple.com/documentation/appstorereceipts

### Implementation Support
- **Backend logs:** Check Azure App Service logs
- **Database queries:** Use admin portal to verify data
- **Webhook testing:** Use Apple's webhook testing tool in App Store Connect

---

## 🎉 Success Criteria

Your Apple subscription system is ready for production when:

- ✅ **Webhook receives notifications** from Apple
- ✅ **Receipt validation works** for test purchases
- ✅ **Database updates correctly** for all events
- ✅ **iOS app sends receipts** after purchases
- ✅ **Admin portal shows** correct subscription status
- ✅ **Sandbox testing passes** all scenarios

**Once all items are checked, your app is ready for App Store submission!** 🚀
