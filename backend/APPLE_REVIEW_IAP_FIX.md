# Apple Review IAP Fix - Receipt Validation

## Issue Reported by Apple
**Guideline 2.1 - Performance - App Completeness**

> We found that your in-app purchase products exhibited one or more bugs which create a poor user experience. Specifically, the IAP products were not available.

**Test Environment:**
- Device: iPad Air (5th generation)
- OS: iPadOS 18.0.1 (reported as 26.0.1, likely typo)

## Root Cause
The backend receipt validation was not following Apple's recommended approach:
1. ❌ **Old behavior:** Check `NODE_ENV` and route to production OR sandbox
2. ✅ **Apple's requirement:** ALWAYS try production first, then fallback to sandbox on error 21007

### Why This Matters
- **Apple reviewers** use a **production-signed build** with **sandbox IAP**
- When they make a test purchase, the receipt is a **sandbox receipt**
- Our backend was only checking production, so sandbox receipts failed
- Result: IAP appeared broken during review

## The Fix

### Updated `validateAppleReceipt()` Function
**Location:** `/backend/routes/subscription.js` (lines 447-511)

**New Logic:**
```javascript
1. ALWAYS validate against production first
2. If error code === 21007 (sandbox receipt on production server):
   → Retry with sandbox server
   → Mark as sandbox environment
3. Accept and process the receipt normally
```

### Key Changes
1. **Removed environment-based routing** - no more `if (isProduction)`
2. **Always try production first** - `https://buy.itunes.apple.com/verifyReceipt`
3. **Detect error 21007** - "Sandbox receipt used in production"
4. **Automatic fallback** - retry with `https://sandbox.itunes.apple.com/verifyReceipt`
5. **Environment tracking** - set `environment: 'sandbox'` or `'production'` flag

### Error Code 21007
- **Meaning:** "This is a sandbox receipt, but you sent it to the production server"
- **Action:** Retry the same receipt against the sandbox server
- **Expected during:** Apple Review, Xcode testing, TestFlight with sandbox testers

## Testing Scenarios

### ✅ Scenario 1: Production User (Real Purchase)
1. User makes real purchase → production receipt
2. Backend validates against production → Success (status 0)
3. Subscription activated

### ✅ Scenario 2: Apple Reviewer (Sandbox Purchase)
1. Reviewer makes test purchase → sandbox receipt
2. Backend validates against production → Error 21007
3. Backend retries against sandbox → Success (status 0)
4. Subscription activated (marked as sandbox)

### ✅ Scenario 3: Xcode Testing
1. Developer tests in Xcode → sandbox receipt
2. Backend validates against production → Error 21007
3. Backend retries against sandbox → Success (status 0)
4. Subscription activated (marked as sandbox)

### ✅ Scenario 4: TestFlight Beta Testing
1. Beta tester makes purchase → production OR sandbox receipt
2. Backend tries production first
3. If sandbox (21007), retries sandbox
4. Subscription activated

## Deployment

### Files Changed
- ✅ `/backend/routes/subscription.js` - Updated `validateAppleReceipt()` function
- ✅ Added comprehensive logging for debugging
- ✅ Added environment detection and tracking

### Deployment Command
```bash
cd backend
zip -r apple-review-iap-fix.zip . -x "*.git*" "node_modules/*" "*.log" "*.zip"
az webapp deploy --name homework-helper-api --resource-group homework-helper-rg-f --src-path apple-review-iap-fix.zip
```

## Verification

### Check Logs
After deployment, monitor Azure logs for:
- `🍎 Validating receipt with Apple Production server...`
- `🔄 Sandbox receipt detected (error 21007) - retrying with Sandbox server...`
- `✅ Sandbox receipt validated successfully`
- `✅ Production receipt validated successfully`

### Expected Behavior
- **Production users:** Single validation call to production (fast)
- **Sandbox users:** Two validation calls (production → 21007 → sandbox)
- **Both work correctly** without any code changes needed

## Apple's Official Guidance
From Apple's App Store Server API documentation:

> "Your production server should always validate receipts against the production App Store first. If validation fails with the error code 'Sandbox receipt used in production' (21007), you should validate against the test environment instead."

## Status
- ✅ Fix implemented
- ⏳ Deployment pending
- ⏳ Apple re-review pending

## Next Steps
1. Deploy the fix to Azure
2. Test with a sandbox purchase to verify logs
3. Reply to Apple's review feedback
4. Wait for re-review

---

**Date:** October 14, 2025  
**Issue:** Apple Review - IAP Not Available  
**Fix:** Production-first receipt validation with sandbox fallback  
**Status:** Ready for deployment

