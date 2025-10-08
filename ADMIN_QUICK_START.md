# Admin User Management - Quick Start

## ✅ What's New

Your admin panel now has **full user management capabilities**:

### 🆕 New Features
1. **Create Users** - Add new users with custom settings
2. **Delete Users** - Permanently remove users (with safety confirmations)
3. **Change Passwords** - Reset any user's password
4. **Edit Membership** - Update subscription status and dates

### 🌐 Access Your Admin Panel
**URL**: https://homework-helper-api.azurewebsites.net/admin/

---

## 🚀 Quick Actions

### Create a New User
1. Go to **Users** tab
2. Click **"+ Create User"**
3. Fill in:
   - Email (required)
   - Password (required, 6+ chars)
   - Username (optional)
   - Status (Trial/Active/Promo)
   - Days (subscription length)
4. Click **Create User**

### Change a User's Password
1. Find user → Click **"View"**
2. Click **"Change Password"**
3. Enter new password twice
4. Click **Update Password**

### Edit Membership
1. Find user → Click **"View"**
2. Click **"Edit Membership"**
3. Update:
   - Subscription status
   - Start date
   - End date
4. Click **Update Membership**

### Delete a User
1. Find user → Click **"View"**
2. Click **"Delete User"** (red button)
3. Confirm (twice for safety)
4. Type "DELETE" to confirm

---

## 📋 All Available Actions

### User Table Actions
- **View** - See full user details
- **Activate/Deactivate** - Toggle account access

### User Details Actions
**Quick Actions:**
- +30 Days - Extend subscription by 30 days
- +90 Days - Extend subscription by 90 days
- Ban/Unban User - Restrict user access

**Management Actions:**
- Change Password - Reset user password
- Edit Membership - Update subscription details
- Delete User - Permanently remove user

---

## 🔧 Deployment

### If Running Locally
```bash
cd backend
npm start
```

### Deploy to Azure
```bash
./deploy-to-azure.sh
```

The Azure app will automatically use the updated code.

---

## 📊 User Fields You Can Manage

| Field | Editable Via | Notes |
|-------|-------------|-------|
| Email | Create only | Cannot change after creation |
| Username | Create only | Defaults to email prefix |
| Password | Change Password | Min 6 characters |
| Subscription Status | Edit Membership | Trial/Active/Promo/Expired/Cancelled |
| Subscription Dates | Edit Membership or Quick Extend | Start & end dates |
| Active Status | Activate/Deactivate | Enable/disable account |
| Banned Status | Ban/Unban | Permanently restrict access |

---

## 🔐 Security

- All actions require admin authentication
- Delete requires double confirmation
- Passwords are hashed with bcrypt
- All actions are logged with your admin username
- Logs stored in `subscription_history` table

---

## 💡 Pro Tips

1. **Create Trial Users**: Use 7-day trial status for new users to try the app
2. **Extend by 90 days**: Give active users 3 months at a time
3. **Change Status to Active**: When users upgrade from trial
4. **Use Ban for Issues**: Ban instead of delete to preserve history
5. **Delete Only When Necessary**: Delete permanently removes all data

---

## 🆘 Troubleshooting

### "Dependencies missing" error
```bash
cd backend
npm install bcrypt uuid
```

### Need to redeploy
```bash
./deploy-to-azure.sh
```

### Admin token expired
Just logout and login again (tokens last 7 days)

---

## 📖 Detailed Documentation

See **ADMIN_USER_MANAGEMENT_GUIDE.md** for:
- Complete API documentation
- Security details
- Backend routes
- Logging information
- Advanced usage

---

## ✨ Summary

You now have complete control over user management:
- ✅ Create users manually
- ✅ Modify passwords
- ✅ Update subscriptions
- ✅ Delete accounts

All from your admin panel at:
**https://homework-helper-api.azurewebsites.net/admin/**

