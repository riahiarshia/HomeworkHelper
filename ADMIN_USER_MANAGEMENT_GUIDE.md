# Admin User Management Guide

## Overview
The admin panel at https://homework-helper-api.azurewebsites.net/admin/ now includes comprehensive user management capabilities.

## Features Added

### 1. Create New Users
**Location**: Users tab → "+ Create User" button

**Functionality**:
- Create new users with email and password
- Set custom username (optional - defaults to email prefix)
- Choose initial subscription status (Trial, Active, Promo Active)
- Set subscription duration in days

**API Endpoint**: `POST /api/admin/users`

**Fields**:
- Email (required)
- Username (optional)
- Password (required, min 6 characters)
- Subscription Status (default: trial)
- Subscription Days (default: 7)

### 2. Delete Users
**Location**: User Details modal → "Delete User" button

**Functionality**:
- Permanently delete users and all their data
- Double confirmation required for safety
- Deletes user account, subscription history, and promo code usage

**API Endpoint**: `DELETE /api/admin/users/:userId`

**Safety Features**:
- Confirmation dialog with user email
- Must type "DELETE" to confirm
- Cannot be undone

### 3. Change User Password
**Location**: User Details modal → "Change Password" button

**Functionality**:
- Reset or change any user's password
- Password must be at least 6 characters
- Confirmation required

**API Endpoint**: `PUT /api/admin/users/:userId/password`

**Fields**:
- New Password (required, min 6 characters)
- Confirm Password (must match)

### 4. Edit Membership Details
**Location**: User Details modal → "Edit Membership" button

**Functionality**:
- Change subscription status (Trial, Active, Promo Active, Expired, Cancelled)
- Modify subscription start date
- Modify subscription end date
- All changes are logged in subscription history

**API Endpoint**: `PUT /api/admin/users/:userId/membership`

**Fields**:
- Subscription Status (optional)
- Subscription Start Date (optional)
- Subscription End Date (optional)

## Existing Features (Already Present)

### View Users
- Search by email, username, or user ID
- Filter by subscription status
- Paginated results (20 per page)
- View detailed user information

### User Details
- View complete user profile
- See subscription history
- Check promo codes used
- View account status

### Quick Actions
- Extend subscription by 30 or 90 days
- Ban/Unban users
- Activate/Deactivate accounts

### Promo Code Management
- Create new promo codes
- Set duration and usage limits
- Activate/Deactivate codes
- Track usage statistics

## Installation

### 1. Install Dependencies
```bash
cd backend
npm install
```

This will install the new required packages:
- `bcrypt` - For password hashing
- `uuid` - For generating unique user IDs

### 2. Deploy to Azure (if needed)
```bash
# From the project root
./deploy-to-azure.sh
```

### 3. Restart the Server
If running locally:
```bash
cd backend
npm start
```

If deployed on Azure, the app will restart automatically after deployment.

## Usage Examples

### Creating a New User
1. Navigate to the Users tab
2. Click "+ Create User"
3. Fill in the form:
   - Email: user@example.com
   - Password: securepassword123
   - Status: Active
   - Days: 30
4. Click "Create User"

### Changing a User's Password
1. Click "View" on any user
2. Click "Change Password"
3. Enter new password (min 6 characters)
4. Confirm the password
5. Click "Update Password"

### Editing Membership
1. Click "View" on any user
2. Click "Edit Membership"
3. Update desired fields:
   - Change status to "Active"
   - Set new end date
4. Click "Update Membership"

### Deleting a User
1. Click "View" on any user
2. Click "Delete User"
3. Confirm by clicking OK
4. Type "DELETE" in the confirmation prompt
5. User is permanently removed

## Security Notes

- All admin actions require authentication with admin JWT token
- All actions are logged in subscription history
- Delete operations require double confirmation
- Passwords are hashed using bcrypt before storage
- Admin username is recorded with each action for audit trail

## API Authentication

All admin endpoints require:
```
Authorization: Bearer <admin_jwt_token>
```

Token is automatically included in all requests from the admin panel.

## Logging

All user management actions are logged in the `subscription_history` table with event types:
- `user_created_by_admin`
- `password_changed_by_admin`
- `membership_updated_by_admin`
- `subscription_extended`
- `access_toggled`
- `user_banned` / `user_unbanned`

## Backend Routes Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/users` | List all users with pagination |
| GET | `/api/admin/users/:userId` | Get user details |
| POST | `/api/admin/users` | Create new user |
| DELETE | `/api/admin/users/:userId` | Delete user |
| PUT | `/api/admin/users/:userId/password` | Change password |
| PUT | `/api/admin/users/:userId/membership` | Update membership |
| POST | `/api/admin/users/:userId/extend` | Extend subscription |
| POST | `/api/admin/users/:userId/ban` | Ban/unban user |
| POST | `/api/admin/users/:userId/toggle-access` | Activate/deactivate |

## Troubleshooting

### Dependencies Not Installed
If you get errors about missing modules:
```bash
cd backend
npm install bcrypt uuid
```

### Password Hashing Fails
Ensure bcrypt is properly installed. On some systems you may need:
```bash
npm rebuild bcrypt
```

### Admin Token Expired
Admin tokens expire after 7 days. Simply log out and log back in.

## Support

For issues or questions, check the subscription_history table for detailed logs of all admin actions.

