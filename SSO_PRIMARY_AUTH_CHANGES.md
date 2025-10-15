# SSO Primary Authentication Changes

## Overview
Restructured the authentication flow to make SSO (Sign in with Apple/Google) the primary path and restrict email/password login to whitelisted organization and test accounts only.

## Changes Made

### 1. Backend Changes (`backend/routes/auth.js`)

#### Email Allowlist System
- Added `EMAIL_PASSWORD_ALLOWLIST` configuration with whitelisted emails and domains:
  - `reviewer@apple.com` (for App Store review)
  - `@homeworkhelper.com` (internal team)
  - `@test.com`, `@example.com` (testing)
  - Other specific test accounts

- Created `isEmailPasswordAllowed()` function to validate email against allowlist
  - Checks both exact email matches and domain matches
  - Case-insensitive matching

#### Updated `/api/auth/login` Endpoint
- Added allowlist check before processing login
- Returns 403 error with clear message for non-whitelisted emails:
  ```
  "Email/password login isn't available for public accounts. Please use Sign in with Apple or Google."
  ```
- Includes `errorType: 'not_whitelisted'` for client-side handling

#### Updated `/api/auth/register` Endpoint  
- Added same allowlist check to prevent new non-whitelisted registrations
- Returns same 403 error message for consistency

### 2. iOS Frontend Changes

#### New View: `EmailPasswordLoginView.swift`
Created dedicated view for organization/test account login with:
- **Prominent Warning Notice**: Yellow-bordered info box at top stating:
  > "This login is for organization or test accounts only. New users should use Sign in with Apple or Google."
- Clean login form (email + password)
- Forgot password link to `ResetPasswordView`
- Form validation
- Proper error display from backend
- Back button to return to main auth screen

#### Updated `AuthenticationView.swift`
**Major Restructure:**
- ✅ **SSO Front and Center**: 
  - Apple Sign In button (primary, 55pt height)
  - Google Sign In button (primary, 55pt height)
  - Removed "OR" divider between SSO options
  - Changed Google button text from "Start Trial with Google" to "Continue with Google"

- ✅ **De-emphasized Email/Password**:
  - Removed all email/password fields from main screen
  - Removed "Create account" option entirely
  - Added small, secondary link in footer: "Existing org/test account? Log in"
  - Link uses `.caption` font with 70% opacity for de-emphasis
  - NavigationLink takes users to new `EmailPasswordLoginView`

- **Visual Improvements**:
  - Consistent button heights (55pt)
  - Removed "OR" divider for cleaner SSO presentation
  - Better spacing and hierarchy

#### Existing `AuthenticationService.swift`
- ✅ **Already handles 403 errors correctly**:
  - Lines 246-252 extract and display error message from backend
  - Will properly show allowlist error to users
  - No changes needed

### 3. User Experience Flow

#### New Users (Public)
1. See main auth screen with **only** SSO options (Apple/Google)
2. Sign in with Apple or Google → instant 7-day trial
3. If they try email/password link → see clear warning message
4. If they somehow attempt to use non-whitelisted email → backend rejects with clear error

#### Test/Review Accounts
1. See main auth screen with SSO options
2. Click small "Existing org/test account? Log in" link at bottom
3. Navigate to dedicated org login screen with warning
4. Enter whitelisted email/password
5. Successfully authenticate

#### Apple Reviewer Experience
1. Uses `reviewer@apple.com` credentials (whitelisted)
2. Can access via org login link
3. Sees clear messaging that this is for org accounts
4. No confusion about why they have special credentials

### 4. Security Benefits

- **Prevents Email Enumeration**: 403 error doesn't reveal if email exists
- **Clear User Communication**: Users understand why they can't use email/password
- **Centralized Allowlist**: Easy to add/remove whitelisted emails/domains
- **Backend Enforcement**: Even if someone bypasses UI, backend blocks non-whitelisted logins

### 5. Configuration

To add new whitelisted emails or domains, edit `backend/routes/auth.js`:

```javascript
const EMAIL_PASSWORD_ALLOWLIST = [
    // Add specific emails
    'newreviewer@apple.com',
    
    // Or add entire domains
    '@yourcompany.com',
];
```

### 6. What's Preserved

✅ **Delete Account** remains in Settings (works for all auth types)  
✅ **Password Reset** flow intact via forgot password link  
✅ **Existing email/password accounts** can still log in if whitelisted  
✅ **All SSO functionality** unchanged  
✅ **Session validation** and security features intact  

## Testing Checklist

- [ ] Deploy backend changes to staging/production
- [ ] Test SSO login (Apple) - should work normally
- [ ] Test SSO login (Google) - should work normally  
- [ ] Test whitelisted email login - should work
- [ ] Test non-whitelisted email login - should see clear error
- [ ] Test non-whitelisted email registration - should see clear error
- [ ] Verify "Existing org/test account?" link navigates correctly
- [ ] Verify warning message displays on org login screen
- [ ] Test forgot password flow
- [ ] Test delete account from Settings (SSO user)
- [ ] Test delete account from Settings (email user)

## Files Modified

### Backend
- `backend/routes/auth.js` - Added allowlist system and enforcement

### iOS Frontend  
- `HomeworkHelper/Views/AuthenticationView.swift` - Restructured to SSO-primary
- `HomeworkHelper/Views/Authentication/EmailPasswordLoginView.swift` - New file
- `HomeworkHelper/Services/AuthenticationService.swift` - No changes (already compatible)

## Notes

- The allowlist is currently hardcoded in `auth.js`. For more complex needs, consider moving to environment variables or database table.
- `SignUpView.swift` still exists in codebase but is no longer accessible from UI.
- Consider adding analytics to track usage of org login link vs SSO buttons.

