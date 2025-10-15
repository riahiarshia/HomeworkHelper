# Deploy Delete Account Feature

## Status: Backend changes need deployment

The Delete Account feature is **fully implemented** in code but the backend API endpoint hasn't been deployed yet.

## Error You're Seeing:
```
❌ Failed to delete account (HTTP 404)
```

This is because `https://homework-helper-api.azurewebsites.net/api/auth/delete-account` doesn't exist yet on your production server.

## What's Implemented (Local):

### ✅ Backend (`backend/routes/auth.js`)
- New endpoint: `DELETE /api/auth/delete-account`
- Requires authentication
- Deletes all user data from database
- Located at line 1047

### ✅ iOS App
- `AuthenticationService.deleteAccount()` method
- Settings UI with Delete Account button
- Proper alert flow with confirmation
- Complete data cleanup

## What You Need To Do:

### Option 1: Deploy to Staging First (Recommended)
```bash
cd /Users/ar616n/Documents/ios-app/ios-app
./deploy-staging.sh
```

Test with staging backend, then deploy to production.

### Option 2: Deploy Directly to Production
```bash
cd /Users/ar616n/Documents/ios-app/ios-app
# Check what your production deploy script is called
# Likely one of:
./deploy-production.sh
# or
az webapp deployment source config-zip --resource-group homework-helper-rg --name homework-helper-api --src backend.zip
```

## After Deployment:

1. **Wait 2-3 minutes** for Azure to restart the app
2. **Test in the iOS app**:
   - Go to Settings
   - Tap "Delete Account"
   - Confirm deletion
   - Should see success in logs

## Verify Deployment:

You can test the endpoint directly:

```bash
# Get your auth token from Xcode logs or keychain
# Then test:
curl -X DELETE https://homework-helper-api.azurewebsites.net/api/auth/delete-account \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

Should return:
```json
{
  "success": true,
  "message": "Account successfully deleted"
}
```

## Files Changed (Need Deployment):
- `backend/routes/auth.js` - Added DELETE /api/auth/delete-account endpoint (line 1047)

## Files Changed (iOS - Already Done):
- `HomeworkHelper/Services/AuthenticationService.swift` - Added deleteAccount() method
- `HomeworkHelper/Services/DataManager.swift` - Added clearAllData() method  
- `HomeworkHelper/Views/SettingsView.swift` - Added Delete Account UI
- `HomeworkHelper/Views/ContentView.swift` - Shows AuthenticationView instead of OnboardingView

## What Backend Endpoint Does:

```javascript
router.delete('/delete-account', authenticateUser, async (req, res) => {
  // 1. Gets user ID from auth token
  // 2. Deletes from all tables:
  //    - subscription_history
  //    - promo_code_usage
  //    - password_reset_tokens
  //    - user_devices
  //    - user_api_usage
  //    - users
  // 3. Returns success response
});
```

## Important Notes:

⚠️ **This is a destructive operation** - it permanently deletes user accounts from the database

✅ **It's properly secured** - requires valid auth token

✅ **Works for all auth types**:
- SSO (Apple Sign-In)
- SSO (Google Sign-In)
- Email/Password (whitelisted accounts)

## Once Deployed:

The complete flow will work:
1. User taps "Delete Account" in Settings
2. Confirms scary warning
3. Backend deletes account from database
4. iOS app clears all local data
5. User automatically signed out
6. Returns to login screen

---

**Next Step:** Run your deployment script to push the backend changes!

