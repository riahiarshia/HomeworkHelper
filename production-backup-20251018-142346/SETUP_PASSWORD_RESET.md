# Password Reset Setup Guide

## ✅ What's Been Implemented

The complete password reset system has been implemented in the backend:

1. ✅ Email service (`services/emailService.js`)
2. ✅ Password reset API endpoints (`routes/auth.js`)
3. ✅ Database migration (`database/password-reset-migration.sql`)
4. ✅ SendGrid package installed
5. ✅ Welcome email on registration
6. ✅ Password reset email with beautiful HTML template

---

## 🚀 Quick Setup (5 minutes)

### Step 1: Get SendGrid API Key

1. Go to https://sendgrid.com/
2. Sign up (FREE tier: 100 emails/day)
3. Verify your email
4. Go to **Settings** → **API Keys**
5. Click **Create API Key**
6. Name it "HomeworkHelper"
7. Choose **Full Access**
8. Click **Create & View**
9. **Copy the key** (you won't see it again!)

### Step 2: Verify Sender Email

1. In SendGrid, go to **Settings** → **Sender Authentication**
2. Click **Verify a Single Sender**
3. Fill in your details:
   - From Name: `HomeworkHelper`
   - From Email Address: `noreply@yourdomain.com` (or your actual email)
   - Reply To: Your support email
4. Check your email and verify
5. Wait for approval (usually instant)

### Step 3: Set Environment Variables

In Azure App Service:

1. Go to Azure Portal
2. Open your App Service
3. Go to **Configuration** → **Application settings**
4. Add these new settings:

```
SENDGRID_API_KEY=your_api_key_from_step_1
SENDGRID_FROM_EMAIL=noreply@yourdomain.com
APP_URL=homeworkhelper://
```

4. Click **Save**
5. Restart your app

### Step 4: Run Database Migration

**Option A: Using Azure Data Studio / psql**
```bash
psql $DATABASE_URL -f backend/database/password-reset-migration.sql
```

**Option B: Using Azure Portal**
1. Go to your Azure Database for PostgreSQL
2. Open Query Editor
3. Copy contents from `database/password-reset-migration.sql`
4. Run the query

**Option C: Node.js Script**
```bash
cd backend
node -e "
const { Pool } = require('pg');
const fs = require('fs');
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const sql = fs.readFileSync('database/password-reset-migration.sql', 'utf8');
pool.query(sql).then(() => {
  console.log('✅ Migration complete!');
  process.exit(0);
}).catch(err => {
  console.error('❌ Migration failed:', err);
  process.exit(1);
});
"
```

---

## 🧪 Testing

### Test 1: Request Password Reset

```bash
curl -X POST https://homework-helper-api.azurewebsites.net/api/auth/request-reset \
  -H "Content-Type: application/json" \
  -d '{"email":"your-test-email@gmail.com"}'
```

Expected response:
```json
{
  "success": true,
  "message": "If that email exists in our system, a reset link has been sent"
}
```

Check your email! You should receive a password reset email.

### Test 2: Verify Token (Optional)

```bash
curl "https://homework-helper-api.azurewebsites.net/api/auth/verify-reset-token?token=YOUR_TOKEN"
```

### Test 3: Reset Password

```bash
curl -X POST https://homework-helper-api.azurewebsites.net/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "token": "token_from_email",
    "newPassword": "newPassword123"
  }'
```

Expected response:
```json
{
  "success": true,
  "message": "Password successfully reset"
}
```

### Test 4: Login with New Password

```bash
curl -X POST https://homework-helper-api.azurewebsites.net/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your-test-email@gmail.com",
    "password": "newPassword123"
  }'
```

---

## 📧 Email Templates

The system sends 2 types of emails:

### 1. Password Reset Email
- **Subject:** "Reset Your HomeworkHelper Password"
- **Contains:** Reset button + deep link
- **Expires:** 1 hour
- **Template:** Beautiful HTML with gradient header

### 2. Welcome Email (New!)
- **Subject:** "Welcome to HomeworkHelper! 🎉"
- **Sent:** When user registers
- **Contains:** Trial info, features list
- **Template:** Beautiful HTML with gradient header

---

## 🔍 Troubleshooting

### Email not sending?

1. **Check SendGrid API key is set:**
   ```bash
   echo $SENDGRID_API_KEY
   ```

2. **Check sender is verified:**
   - Go to SendGrid → Settings → Sender Authentication
   - Make sure your email is verified (green checkmark)

3. **Check logs:**
   - In Azure Portal → App Service → Log stream
   - Look for: `✅ Password reset email sent` or error messages

4. **Test SendGrid directly:**
   ```javascript
   const sgMail = require('@sendgrid/mail');
   sgMail.setApiKey('YOUR_API_KEY');
   
   sgMail.send({
     to: 'your-email@example.com',
     from: 'verified-sender@example.com',
     subject: 'Test',
     text: 'Testing SendGrid'
   }).then(() => console.log('✅ Sent')).catch(console.error);
   ```

### Database migration failed?

**Error: "relation already exists"**
- Migration already ran. That's OK!

**Error: "permission denied"**
- Your database user needs CREATE TABLE permission
- Run as admin user or grant permission

### Token not working?

**Error: "Invalid or expired reset token"**
- Check token hasn't been used already (`used = true`)
- Check token hasn't expired (`expires_at > now`)
- Check table exists: `SELECT * FROM password_reset_tokens;`

---

## 🔒 Security Features

✅ **Secure token generation** - 32 bytes = 256 bits
✅ **Token expiration** - 1 hour max lifetime
✅ **One-time use** - Token marked as used after password reset
✅ **Email enumeration protection** - Always returns same message
✅ **bcrypt password hashing** - Industry standard
✅ **HTTPS required** - Azure enforces SSL
✅ **SQL injection protection** - Parameterized queries

---

## 📊 Database Schema

```sql
password_reset_tokens:
  - id (UUID, primary key)
  - user_id (UUID, foreign key → users.user_id)
  - token (VARCHAR(255), unique, indexed)
  - expires_at (TIMESTAMP, indexed)
  - created_at (TIMESTAMP, default NOW())
  - used (BOOLEAN, default FALSE, indexed)
  - used_at (TIMESTAMP, nullable)
```

**Indexes:**
- `token` - Fast lookup when user clicks email link
- `user_id` - Fast lookup of user's reset tokens
- `expires_at` - Fast cleanup of expired tokens
- `used` - Fast filtering of unused tokens

---

## 🔄 API Endpoints

### POST /api/auth/request-reset
Request password reset email.

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "If that email exists in our system, a reset link has been sent"
}
```

**Status Codes:**
- `200` - Request processed (email may or may not exist)
- `400` - Invalid email format
- `500` - Server error

---

### POST /api/auth/reset-password
Reset password using token.

**Request:**
```json
{
  "token": "64-character-hex-string",
  "newPassword": "newPassword123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password successfully reset"
}
```

**Status Codes:**
- `200` - Password reset successful
- `400` - Invalid/expired token or password too short
- `500` - Server error

---

### GET /api/auth/verify-reset-token
Verify if token is still valid (optional endpoint).

**Request:**
```
GET /api/auth/verify-reset-token?token=YOUR_TOKEN
```

**Response:**
```json
{
  "valid": true
}
```

---

## 🎯 Next Steps

After setup is complete:

1. ✅ Test password reset from iOS app
2. ✅ Test email delivery
3. ✅ Test deep link works on iPhone
4. ⏭️ Monitor SendGrid dashboard for email stats
5. ⏭️ Set up automated cleanup of expired tokens (optional)
6. ⏭️ Add email templates for other events (optional)

---

## 📈 Monitoring

**SendGrid Dashboard:**
- Track email delivery rate
- Monitor bounces and spam reports
- See opens/clicks (if tracking enabled)

**Azure Logs:**
- Password reset requests: Look for `✅ Password reset requested`
- Successful resets: Look for `✅ Password reset successful`
- Errors: Look for `❌` symbols

---

## 💰 Cost Estimate

**SendGrid Free Tier:**
- 100 emails/day
- FREE forever
- Perfect for small apps

**SendGrid Paid (if needed):**
- $19.95/month for 50,000 emails
- $89.95/month for 100,000 emails

**Azure Costs:**
- No additional cost (just normal API calls)

---

## ✅ Deployment Checklist

- [ ] SendGrid account created
- [ ] API key generated
- [ ] Sender email verified
- [ ] Environment variables set in Azure
- [ ] Database migration run successfully
- [ ] Backend restarted
- [ ] Test email received
- [ ] Test password reset works
- [ ] Test deep link opens iOS app
- [ ] iOS app tested end-to-end

---

## 🆘 Support

If you need help:
1. Check Azure App Service logs
2. Check SendGrid Activity Feed
3. Verify environment variables are set
4. Test with curl commands above
5. Check database table exists

Everything is ready to go! Just follow the 4 setup steps above. 🚀

