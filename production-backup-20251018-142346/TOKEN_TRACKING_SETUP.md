# 📊 OpenAI API Usage Tracking System

## Overview

This comprehensive token tracking system monitors OpenAI API usage per user, calculates costs, and provides detailed analytics through an admin portal with CSV export capabilities.

---

## 🚀 Setup Instructions

### 1. Install Dependencies

```bash
cd backend
npm install axios json2csv
```

### 2. Run Database Migration

```bash
# Connect to your database
psql $DATABASE_URL

# Run the migration
\i database/usage-tracking-migration.sql
```

This creates:
- `user_api_usage` table - Stores detailed API call records
- `user_usage_summary` view - Aggregated user statistics
- `monthly_usage_summary` view - Monthly usage trends
- `endpoint_usage_summary` view - Usage by endpoint
- `daily_usage_summary` view - Daily statistics

### 3. Verify Installation

```sql
-- Check if table exists
SELECT * FROM user_api_usage LIMIT 1;

-- Check views
SELECT * FROM user_usage_summary LIMIT 5;
SELECT * FROM endpoint_usage_summary;
SELECT * FROM daily_usage_summary WHERE date >= CURRENT_DATE - INTERVAL '7 days';
```

---

## 📋 Features

### ✅ Automatic Usage Tracking

Every OpenAI API call automatically tracks:
- **Tokens**: prompt_tokens, completion_tokens, total_tokens
- **Cost**: Real-time cost calculation based on OpenAI pricing
- **Metadata**: User info, endpoint, model, timestamp
- **Context**: Problem ID, session ID, grade level

### ✅ Pricing Models

Current pricing (2024):
- **GPT-4o**: $2.50/1M input tokens, $10.00/1M output tokens
- **GPT-4o-mini**: $0.150/1M input tokens, $0.600/1M output tokens

Costs are calculated automatically for each API call.

### ✅ Admin Portal Features

Access at: `https://your-domain.com/admin`

**API Usage Tab includes:**
1. **Overview Statistics**
   - Total API calls (all-time + today)
   - Total tokens (all-time + today)
   - Total cost in USD (all-time + today)
   - Active users (all-time + monthly)

2. **Endpoint Analytics**
   - Usage breakdown by endpoint
   - Model usage (gpt-4o vs gpt-4o-mini)
   - Average tokens per call
   - Average cost per call

3. **User Usage Table**
   - Per-user API call counts
   - Per-user token usage
   - Per-user total costs
   - Last activity timestamp

4. **CSV Export**
   - **Summary Export**: Aggregated data per user
   - **Detailed Export**: Individual API call records
   - Downloadable .csv files
   - Date range filtering

---

## 🔌 API Endpoints

All endpoints require admin authentication.

### GET /api/usage/stats
Get overall platform statistics.

**Response:**
```json
{
  "success": true,
  "data": {
    "overall": {
      "total_api_calls": 1500,
      "total_users": 45,
      "total_tokens": 2500000,
      "total_cost": 15.50
    },
    "monthly": {
      "monthly_api_calls": 450,
      "monthly_users": 30,
      "monthly_tokens": 750000,
      "monthly_cost": 4.25
    },
    "daily": {
      "daily_api_calls": 120,
      "daily_users": 15,
      "daily_tokens": 200000,
      "daily_cost": 1.15
    }
  }
}
```

### GET /api/usage/summary
Get user usage summary.

**Query Parameters:**
- `limit` (default: 100) - Number of users to return
- `offset` (default: 0) - Pagination offset
- `sortBy` (default: total_cost) - Sort field
- `order` (default: DESC) - Sort order

**Response:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "user_id": 123,
        "username": "john@example.com",
        "email": "john@example.com",
        "total_calls": 45,
        "total_tokens": 125000,
        "total_cost": 0.875,
        "last_call": "2025-10-11T10:30:00Z"
      }
    ],
    "total": 45,
    "limit": 100,
    "offset": 0
  }
}
```

### GET /api/usage/user/:userId
Get specific user's usage details.

**Response:**
```json
{
  "success": true,
  "data": {
    "userId": 123,
    "total": {
      "total_calls": 45,
      "total_tokens": 125000,
      "total_cost": 0.875
    },
    "monthly": {
      "monthly_calls": 12,
      "monthly_tokens": 35000,
      "monthly_cost": 0.245
    }
  }
}
```

### GET /api/usage/endpoint
Get usage statistics by endpoint.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "endpoint": "analyze_homework",
      "model": "gpt-4o",
      "api_calls": 850,
      "total_tokens": 1750000,
      "cost_usd": 10.25,
      "avg_tokens_per_call": 2058,
      "avg_cost_per_call": 0.012
    }
  ]
}
```

### GET /api/usage/daily
Get daily usage statistics.

**Query Parameters:**
- `days` (default: 30) - Number of days to include

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "date": "2025-10-11",
      "api_calls": 120,
      "unique_users": 15,
      "total_tokens": 200000,
      "cost_usd": 1.15
    }
  ]
}
```

### GET /api/usage/export
Export detailed usage data to CSV.

**Query Parameters:**
- `startDate` - Start date (ISO format)
- `endDate` - End date (ISO format)
- `userId` - Filter by specific user ID
- `limit` (default: 10000) - Max records

**Response:** CSV file download

**CSV Columns:**
- ID, User ID, Username, Email, Endpoint, Model
- Prompt Tokens, Completion Tokens, Total Tokens
- Cost (USD), Problem ID, Session ID, Timestamp

### GET /api/usage/export/summary
Export user summary data to CSV.

**Response:** CSV file download

**CSV Columns:**
- User ID, Username, Email
- Total API Calls, Total Prompt Tokens, Total Completion Tokens
- Total Tokens, Total Cost (USD)
- First API Call, Last API Call

---

## 💻 Integration Guide

### iOS App Integration

Add `userId` to API requests:

```swift
// In BackendAPIService.swift

func analyzeHomework(imageData: Data, userId: Int?) async throws -> ProblemAnalysis {
    var request = URLRequest(url: URL(string: "\(baseURL)/analyze")!)
    request.httpMethod = "POST"
    
    // Add userId to request body
    let parameters: [String: Any] = [
        "image": imageData.base64EncodedString(),
        "userId": userId ?? NSNull(),
        "gradeLevel": currentGradeLevel
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
    // ... rest of implementation
}
```

### Backend Tracking (Already Implemented)

The system automatically tracks usage when `userId` is provided:

```javascript
// In routes/imageAnalysis.js
const userId = req.body.userId ? parseInt(req.body.userId) : null;

const result = await openaiService.analyzeHomework({
    imageData: imageBuffer,
    apiKey: apiKey,
    userId: userId,  // ✅ Automatically tracked
    metadata: {
        gradeLevel: userGradeLevel,
        problemText: problemText
    }
});
```

---

## 📊 Usage Analytics

### Key Metrics to Monitor

1. **Cost per User**
   ```sql
   SELECT username, total_cost 
   FROM user_usage_summary 
   ORDER BY total_cost DESC 
   LIMIT 10;
   ```

2. **Most Expensive Endpoints**
   ```sql
   SELECT endpoint, model, cost_usd 
   FROM endpoint_usage_summary 
   ORDER BY cost_usd DESC;
   ```

3. **Daily Cost Trend**
   ```sql
   SELECT date, cost_usd 
   FROM daily_usage_summary 
   ORDER BY date DESC 
   LIMIT 30;
   ```

4. **Users Exceeding Budget**
   ```sql
   SELECT username, email, total_cost 
   FROM user_usage_summary 
   WHERE total_cost > 5.00  -- $5 threshold
   ORDER BY total_cost DESC;
   ```

---

## 🔒 Security & Privacy

- ✅ Admin-only access to usage data
- ✅ JWT authentication required
- ✅ No sensitive data in API responses
- ✅ Audit trail for all API calls
- ✅ GDPR-compliant data storage

---

## 🎯 Cost Management

### Setting Usage Limits

Use `usageTrackingService.checkUsageLimits()`:

```javascript
const limits = {
    maxMonthlyTokens: 1000000,  // 1M tokens/month
    maxMonthlyCost: 10.00,      // $10/month
    maxMonthlyCalls: 500        // 500 calls/month
};

const status = await usageTrackingService.checkUsageLimits(userId, limits);

if (status.exceeded) {
    return res.status(429).json({
        error: 'Usage limit exceeded',
        reason: status.reason,
        usage: {
            tokens: status.monthlyTokens,
            cost: status.monthlyCost,
            calls: status.monthlyCalls
        },
        limits: status.limits
    });
}
```

### Subscription Tiers

Example tier structure:

| Tier | Monthly Tokens | Monthly Cost | Monthly Calls |
|------|----------------|--------------|---------------|
| Free | 100,000 | $0.50 | 50 |
| Basic | 500,000 | $2.50 | 250 |
| Pro | 2,000,000 | $10.00 | 1,000 |
| Unlimited | ∞ | ∞ | ∞ |

---

## 🐛 Troubleshooting

### Issue: No usage data showing

**Solution:**
1. Check if migration ran successfully:
   ```sql
   SELECT COUNT(*) FROM user_api_usage;
   ```
2. Verify `userId` is being passed to API calls
3. Check backend logs for tracking errors

### Issue: Incorrect costs

**Solution:**
1. Verify pricing in `usageTrackingService.js`
2. Check model name matches pricing config
3. Ensure OpenAI response includes `usage` object

### Issue: CSV export not working

**Solution:**
1. Verify `json2csv` package is installed:
   ```bash
   npm list json2csv
   ```
2. Check admin authentication token
3. Verify API endpoint accessibility

---

## 📈 Future Enhancements

- [ ] Real-time usage dashboards
- [ ] Automatic alerts for high usage
- [ ] Usage predictions/forecasting
- [ ] Per-feature cost breakdown
- [ ] Budget management system
- [ ] Automatic usage reports via email
- [ ] Integration with billing system

---

## 📞 Support

For issues or questions:
1. Check backend logs: `backend/server.log`
2. Review migration status: `\dt user_api_usage`
3. Test API endpoints with admin token
4. Verify database connectivity

---

## ✅ Verification Checklist

- [ ] Database migration completed
- [ ] Dependencies installed (`axios`, `json2csv`)
- [ ] Server restarted with new routes
- [ ] Admin portal shows "API Usage" tab
- [ ] Can view usage statistics
- [ ] Can export to CSV
- [ ] Usage data is being tracked
- [ ] Costs are calculated correctly

---

**Last Updated:** October 11, 2025  
**Version:** 1.0.0  
**Status:** ✅ Production Ready

