# Password Reset Implementation Guide

## Backend Implementation (Azure)

### 1. Database Schema Updates

Add a `password_reset_tokens` table:

```sql
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    used BOOLEAN DEFAULT FALSE
);

-- Index for faster lookups
CREATE INDEX idx_password_reset_tokens_token ON password_reset_tokens(token);
CREATE INDEX idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);
```

### 2. Environment Variables (Add to Azure App Service Configuration)

```bash
# Choose ONE email service:

# Option A: SendGrid (Recommended - easiest to set up)
SENDGRID_API_KEY=your_sendgrid_api_key
SENDGRID_FROM_EMAIL=noreply@yourdomain.com

# Option B: Azure Communication Services
AZURE_COMMUNICATION_CONNECTION_STRING=your_connection_string
AZURE_COMMUNICATION_FROM_EMAIL=noreply@yourdomain.com

# Option C: AWS SES
AWS_SES_REGION=us-east-1
AWS_SES_ACCESS_KEY_ID=your_access_key
AWS_SES_SECRET_ACCESS_KEY=your_secret_key
AWS_SES_FROM_EMAIL=noreply@yourdomain.com

# App configuration
APP_URL=homeworkhelper://
FRONTEND_URL=https://yourdomain.com (if you have a web version)
RESET_TOKEN_EXPIRY_HOURS=1
```

### 3. Install Dependencies

```bash
# For Node.js backend
npm install @sendgrid/mail uuid bcrypt

# For Python backend
pip install sendgrid python-dotenv bcrypt

# For .NET backend
dotnet add package SendGrid
```

### 4. Email Service Setup (SendGrid - Recommended)

**Steps to get SendGrid API Key:**
1. Go to https://sendgrid.com/
2. Sign up (Free tier: 100 emails/day)
3. Go to Settings → API Keys
4. Create API Key with "Full Access"
5. Copy the key (save it securely!)

### 5. Backend Code (Node.js/Express Example)

```javascript
const express = require('express');
const crypto = require('crypto');
const bcrypt = require('bcrypt');
const sgMail = require('@sendgrid/mail');
const { Pool } = require('pg');

const router = express.Router();
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

// Configure SendGrid
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

// POST /api/auth/request-reset
router.post('/request-reset', async (req, res) => {
  try {
    const { email } = req.body;

    // Validate email
    if (!email || !email.includes('@')) {
      return res.status(400).json({ error: 'Invalid email address' });
    }

    // Find user by email
    const userResult = await pool.query(
      'SELECT id, email FROM users WHERE email = $1',
      [email.toLowerCase()]
    );

    // Always return success (don't reveal if email exists for security)
    if (userResult.rows.length === 0) {
      return res.json({ 
        success: true, 
        message: 'If that email exists, a reset link has been sent' 
      });
    }

    const user = userResult.rows[0];

    // Generate secure reset token
    const resetToken = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hour from now

    // Save token to database
    await pool.query(
      `INSERT INTO password_reset_tokens (user_id, token, expires_at) 
       VALUES ($1, $2, $3)`,
      [user.id, resetToken, expiresAt]
    );

    // Create reset link
    const resetLink = `${process.env.APP_URL}reset-password?token=${resetToken}`;

    // Send email
    const msg = {
      to: user.email,
      from: process.env.SENDGRID_FROM_EMAIL,
      subject: 'Reset Your HomeworkHelper Password',
      text: `Click this link to reset your password: ${resetLink}\n\nThis link expires in 1 hour.\n\nIf you didn't request this, please ignore this email.`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Reset Your Password</h2>
          <p>You requested to reset your password for HomeworkHelper.</p>
          <p>Click the button below to reset your password:</p>
          <a href="${resetLink}" 
             style="display: inline-block; padding: 12px 24px; background-color: #007AFF; 
                    color: white; text-decoration: none; border-radius: 6px; margin: 16px 0;">
            Reset Password
          </a>
          <p>Or copy and paste this link:</p>
          <p style="color: #666; word-break: break-all;">${resetLink}</p>
          <p><small>This link expires in 1 hour.</small></p>
          <p><small>If you didn't request this, please ignore this email.</small></p>
        </div>
      `
    };

    await sgMail.send(msg);

    res.json({ 
      success: true, 
      message: 'If that email exists, a reset link has been sent' 
    });

  } catch (error) {
    console.error('Password reset request error:', error);
    res.status(500).json({ error: 'Failed to process password reset request' });
  }
});

// POST /api/auth/reset-password
router.post('/reset-password', async (req, res) => {
  try {
    const { token, newPassword } = req.body;

    // Validate input
    if (!token || !newPassword) {
      return res.status(400).json({ error: 'Token and new password are required' });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    // Find valid token
    const tokenResult = await pool.query(
      `SELECT rt.id, rt.user_id, rt.expires_at, rt.used
       FROM password_reset_tokens rt
       WHERE rt.token = $1 AND rt.used = FALSE AND rt.expires_at > NOW()`,
      [token]
    );

    if (tokenResult.rows.length === 0) {
      return res.status(400).json({ error: 'Invalid or expired reset token' });
    }

    const resetToken = tokenResult.rows[0];

    // Hash new password
    const passwordHash = await bcrypt.hash(newPassword, 10);

    // Update user password
    await pool.query(
      'UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2',
      [passwordHash, resetToken.user_id]
    );

    // Mark token as used
    await pool.query(
      'UPDATE password_reset_tokens SET used = TRUE WHERE id = $1',
      [resetToken.id]
    );

    res.json({ 
      success: true, 
      message: 'Password successfully reset' 
    });

  } catch (error) {
    console.error('Password reset error:', error);
    res.status(500).json({ error: 'Failed to reset password' });
  }
});

// GET /api/auth/verify-reset-token (optional - to check if token is valid)
router.get('/verify-reset-token', async (req, res) => {
  try {
    const { token } = req.query;

    if (!token) {
      return res.status(400).json({ error: 'Token is required' });
    }

    const tokenResult = await pool.query(
      `SELECT id FROM password_reset_tokens 
       WHERE token = $1 AND used = FALSE AND expires_at > NOW()`,
      [token]
    );

    res.json({ 
      valid: tokenResult.rows.length > 0 
    });

  } catch (error) {
    console.error('Token verification error:', error);
    res.status(500).json({ error: 'Failed to verify token' });
  }
});

module.exports = router;
```

### 6. Python/Flask Backend Example

```python
import os
import secrets
from datetime import datetime, timedelta
import bcrypt
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
import psycopg2
from flask import Blueprint, request, jsonify

auth_bp = Blueprint('auth', __name__)

def get_db_connection():
    return psycopg2.connect(os.environ['DATABASE_URL'])

@auth_bp.route('/request-reset', methods=['POST'])
def request_password_reset():
    try:
        data = request.get_json()
        email = data.get('email', '').lower()

        if not email or '@' not in email:
            return jsonify({'error': 'Invalid email address'}), 400

        conn = get_db_connection()
        cur = conn.cursor()

        # Find user
        cur.execute('SELECT id, email FROM users WHERE email = %s', (email,))
        user = cur.fetchone()

        # Always return success (security)
        if not user:
            return jsonify({
                'success': True,
                'message': 'If that email exists, a reset link has been sent'
            })

        # Generate token
        reset_token = secrets.token_urlsafe(32)
        expires_at = datetime.now() + timedelta(hours=1)

        # Save token
        cur.execute(
            'INSERT INTO password_reset_tokens (user_id, token, expires_at) VALUES (%s, %s, %s)',
            (user[0], reset_token, expires_at)
        )
        conn.commit()

        # Send email
        reset_link = f"{os.environ['APP_URL']}reset-password?token={reset_token}"
        
        message = Mail(
            from_email=os.environ['SENDGRID_FROM_EMAIL'],
            to_emails=email,
            subject='Reset Your HomeworkHelper Password',
            html_content=f'''
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                    <h2>Reset Your Password</h2>
                    <p>Click the button below to reset your password:</p>
                    <a href="{reset_link}" 
                       style="display: inline-block; padding: 12px 24px; background-color: #007AFF; 
                              color: white; text-decoration: none; border-radius: 6px;">
                        Reset Password
                    </a>
                    <p><small>This link expires in 1 hour.</small></p>
                </div>
            '''
        )

        sg = SendGridAPIClient(os.environ['SENDGRID_API_KEY'])
        sg.send(message)

        cur.close()
        conn.close()

        return jsonify({
            'success': True,
            'message': 'If that email exists, a reset link has been sent'
        })

    except Exception as e:
        print(f'Password reset request error: {e}')
        return jsonify({'error': 'Failed to process password reset request'}), 500

@auth_bp.route('/reset-password', methods=['POST'])
def reset_password():
    try:
        data = request.get_json()
        token = data.get('token')
        new_password = data.get('newPassword')

        if not token or not new_password:
            return jsonify({'error': 'Token and new password are required'}), 400

        if len(new_password) < 6:
            return jsonify({'error': 'Password must be at least 6 characters'}), 400

        conn = get_db_connection()
        cur = conn.cursor()

        # Find valid token
        cur.execute('''
            SELECT rt.id, rt.user_id 
            FROM password_reset_tokens rt
            WHERE rt.token = %s AND rt.used = FALSE AND rt.expires_at > NOW()
        ''', (token,))
        
        reset_token = cur.fetchone()

        if not reset_token:
            return jsonify({'error': 'Invalid or expired reset token'}), 400

        # Hash password
        password_hash = bcrypt.hashpw(new_password.encode(), bcrypt.gensalt())

        # Update password
        cur.execute('UPDATE users SET password_hash = %s WHERE id = %s',
                   (password_hash.decode(), reset_token[1]))
        
        # Mark token as used
        cur.execute('UPDATE password_reset_tokens SET used = TRUE WHERE id = %s',
                   (reset_token[0],))
        
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({
            'success': True,
            'message': 'Password successfully reset'
        })

    except Exception as e:
        print(f'Password reset error: {e}')
        return jsonify({'error': 'Failed to reset password'}), 500
```

## Next: iOS App Integration

After implementing the backend, I'll update the iOS app to:
1. Call these endpoints
2. Handle deep links for reset tokens
3. Create a reset password view
4. Handle the complete flow

Would you like me to proceed with the iOS app updates now?

