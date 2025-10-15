const sgMail = require('@sendgrid/mail');

// Initialize SendGrid with API key from environment
if (process.env.SENDGRID_API_KEY) {
    sgMail.setApiKey(process.env.SENDGRID_API_KEY);
    console.log('✅ SendGrid initialized');
} else {
    console.warn('⚠️  SENDGRID_API_KEY not found in environment variables');
}

/**
 * Send password reset email
 * @param {string} email - User's email address
 * @param {string} resetToken - Reset token for the user
 * @param {string} userName - User's name (optional)
 */
async function sendPasswordResetEmail(email, resetToken, userName = 'User') {
    const resetLink = `${process.env.APP_URL || 'homeworkhelper://'}reset-password?token=${resetToken}`;
    
    const msg = {
        to: email,
        from: {
            email: process.env.SENDGRID_FROM_EMAIL || 'support_homework@arshia.com',
            name: 'HomeworkHelper'
        },
        subject: 'Reset Your HomeworkHelper Password',
        text: `
Hi ${userName},

You requested to reset your password for HomeworkHelper.

Click this link to reset your password:
${resetLink}

This link expires in 1 hour.

If you didn't request this password reset, please ignore this email. Your password will remain unchanged.

Thanks,
The HomeworkHelper Team
        `.trim(),
        html: `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif; margin: 0; padding: 0; background-color: #f5f5f5;">
    <div style="max-width: 600px; margin: 40px auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
        <!-- Header -->
        <div style="background: linear-gradient(135deg, #007AFF 0%, #5856D6 100%); padding: 40px 20px; text-align: center;">
            <div style="font-size: 48px; margin-bottom: 10px;">📚</div>
            <h1 style="color: white; margin: 0; font-size: 28px; font-weight: 600;">HomeworkHelper</h1>
        </div>
        
        <!-- Content -->
        <div style="padding: 40px 30px;">
            <h2 style="color: #1d1d1f; font-size: 24px; margin: 0 0 20px 0;">Reset Your Password</h2>
            
            <p style="color: #6e6e73; font-size: 16px; line-height: 1.6; margin: 0 0 24px 0;">
                Hi ${userName},<br><br>
                You requested to reset your password for HomeworkHelper. Click the button below to create a new password:
            </p>
            
            <!-- Button -->
            <div style="text-align: center; margin: 32px 0;">
                <a href="${resetLink}" style="display: inline-block; padding: 16px 32px; background-color: #007AFF; color: white; text-decoration: none; border-radius: 8px; font-weight: 600; font-size: 16px;">
                    Reset Password
                </a>
            </div>
            
            <p style="color: #86868b; font-size: 14px; line-height: 1.6; margin: 24px 0 0 0;">
                Or copy and paste this link into your browser:
            </p>
            <p style="color: #007AFF; font-size: 14px; word-break: break-all; margin: 8px 0 24px 0;">
                ${resetLink}
            </p>
            
            <!-- Info Box -->
            <div style="background-color: #f5f5f7; border-left: 4px solid #FF9500; padding: 16px; margin: 24px 0; border-radius: 4px;">
                <p style="color: #6e6e73; font-size: 14px; line-height: 1.6; margin: 0;">
                    <strong>⏰ This link expires in 1 hour</strong><br>
                    For security reasons, this password reset link will expire after 1 hour.
                </p>
            </div>
            
            <p style="color: #86868b; font-size: 14px; line-height: 1.6; margin: 24px 0 0 0;">
                If you didn't request this password reset, you can safely ignore this email. Your password will remain unchanged.
            </p>
        </div>
        
        <!-- Footer -->
        <div style="background-color: #f5f5f7; padding: 24px 30px; border-top: 1px solid #d2d2d7;">
            <p style="color: #86868b; font-size: 12px; line-height: 1.6; margin: 0; text-align: center;">
                © 2025 HomeworkHelper. All rights reserved.<br>
                This is an automated email. Please do not reply.
            </p>
        </div>
    </div>
</body>
</html>
        `.trim()
    };
    
    try {
        await sgMail.send(msg);
        console.log(`✅ Password reset email sent to ${email}`);
        return { success: true };
    } catch (error) {
        console.error('❌ SendGrid error:', error);
        if (error.response) {
            console.error('SendGrid response body:', error.response.body);
        }
        throw new Error('Failed to send email');
    }
}

/**
 * Send welcome email to new users
 * @param {string} email - User's email address
 * @param {string} userName - User's name (optional)
 */
async function sendWelcomeEmail(email, userName = 'User') {
    const msg = {
        to: email,
        from: {
            email: process.env.SENDGRID_FROM_EMAIL || 'support_homework@arshia.com',
            name: 'HomeworkHelper'
        },
        subject: 'Welcome to HomeworkHelper! 🎉',
        text: `
Hi ${userName},

Welcome to HomeworkHelper! We're excited to have you on board.

Your 7-day free trial has started. During this time, you'll have full access to all features:
• AI-powered homework assistance
• Step-by-step problem solving
• 24/7 availability
• Multi-subject support

Get started by taking a photo of your homework or typing in your question!

Need help? Contact us anytime at support@homework-helper.com

Happy learning!
The HomeworkHelper Team
        `.trim(),
        html: `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif; margin: 0; padding: 0; background-color: #f5f5f5;">
    <div style="max-width: 600px; margin: 40px auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
        <!-- Header -->
        <div style="background: linear-gradient(135deg, #007AFF 0%, #5856D6 100%); padding: 40px 20px; text-align: center;">
            <div style="font-size: 48px; margin-bottom: 10px;">🎉</div>
            <h1 style="color: white; margin: 0; font-size: 28px; font-weight: 600;">Welcome to HomeworkHelper!</h1>
        </div>
        
        <!-- Content -->
        <div style="padding: 40px 30px;">
            <p style="color: #6e6e73; font-size: 16px; line-height: 1.6; margin: 0 0 24px 0;">
                Hi ${userName},<br><br>
                Welcome to HomeworkHelper! We're excited to have you on board. Your 7-day free trial has started.
            </p>
            
            <h3 style="color: #1d1d1f; font-size: 18px; margin: 24px 0 16px 0;">What you get:</h3>
            <ul style="color: #6e6e73; font-size: 16px; line-height: 1.8; margin: 0 0 24px 0; padding-left: 20px;">
                <li>🤖 AI-powered homework assistance</li>
                <li>📝 Step-by-step problem solving</li>
                <li>⏰ 24/7 availability</li>
                <li>📚 Multi-subject support</li>
            </ul>
            
            <p style="color: #6e6e73; font-size: 16px; line-height: 1.6; margin: 0 0 24px 0;">
                Get started by taking a photo of your homework or typing in your question!
            </p>
            
            <p style="color: #86868b; font-size: 14px; line-height: 1.6; margin: 24px 0 0 0;">
                Need help? Contact us anytime at <a href="mailto:support_homework@arshia.com" style="color: #007AFF;">support_homework@arshia.com</a>
            </p>
        </div>
        
        <!-- Footer -->
        <div style="background-color: #f5f5f7; padding: 24px 30px; border-top: 1px solid #d2d2d7;">
            <p style="color: #86868b; font-size: 12px; line-height: 1.6; margin: 0; text-align: center;">
                © 2025 HomeworkHelper. All rights reserved.
            </p>
        </div>
    </div>
</body>
</html>
        `.trim()
    };
    
    try {
        await sgMail.send(msg);
        console.log(`✅ Welcome email sent to ${email}`);
        return { success: true };
    } catch (error) {
        console.error('❌ SendGrid error:', error);
        // Don't throw error for welcome email - it's not critical
        return { success: false, error: error.message };
    }
}

module.exports = {
    sendPasswordResetEmail,
    sendWelcomeEmail
};

