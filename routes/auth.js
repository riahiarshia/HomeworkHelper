const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const { Pool } = require('pg');
const authenticateUser = require('../middleware/auth');
const { calculateSubscriptionStatus } = require('../services/subscriptionService');
const { generateToken } = require('../middleware/auth');
const { generateAdminToken } = require('../middleware/adminAuth');
const { sendPasswordResetEmail, sendWelcomeEmail } = require('../services/emailService');
const { trackDeviceLogin } = require('../services/deviceTrackingService');
const { upsertLedgerRecord } = require('../services/entitlementsLedgerService');

// Email allowlist for password authentication
// Only these email domains and specific emails can use email/password login
const EMAIL_PASSWORD_ALLOWLIST = [
    // Specific emails for testing/review
    'reviewer@apple.com',
    'test@homeworkhelper.com',
    'admin@homeworkhelper.com',
    // Your internal domain
    '@homeworkhelper.com',
    // Testing domains
    '@test.com',
    '@example.com'
];

/**
 * Check if an email is allowed to use email/password authentication
 * @param {string} email - The email address to check
 * @returns {boolean} - True if allowed, false otherwise
 */
function isEmailPasswordAllowed(email) {
    const lowerEmail = email.toLowerCase();
    
    // Check exact email matches
    if (EMAIL_PASSWORD_ALLOWLIST.some(allowed => 
        !allowed.startsWith('@') && allowed.toLowerCase() === lowerEmail
    )) {
        return true;
    }
    
    // Check domain matches
    return EMAIL_PASSWORD_ALLOWLIST.some(allowed => 
        allowed.startsWith('@') && lowerEmail.endsWith(allowed.toLowerCase())
    );
}

// Simple password hashing (replace with bcrypt later for production)
function hashPassword(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}

function verifyPassword(password, hash) {
    return hashPassword(password) === hash;
}

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

/**
 * POST /api/auth/admin-login
 * Admin login endpoint
 */
router.post('/admin-login', async (req, res) => {
    try {
        const { username, password } = req.body;
        
        if (!username || !password) {
            return res.status(400).json({ error: 'Username and password required' });
        }
        
        // Get admin user
        const result = await pool.query(
            'SELECT * FROM admin_users WHERE username = $1 AND is_active = true',
            [username]
        );
        
        if (result.rows.length === 0) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }
        
        const admin = result.rows[0];
        
        // Verify password
        const validPassword = verifyPassword(password, admin.password_hash);
        
        if (!validPassword) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }
        
        // Update last login
        await pool.query(
            'UPDATE admin_users SET last_login = NOW() WHERE id = $1',
            [admin.id]
        );
        
        // Generate token
        const token = generateAdminToken(admin.id, admin.username, admin.email);
        
        res.json({
            success: true,
            token,
            admin: {
                id: admin.id,
                username: admin.username,
                email: admin.email,
                role: admin.role
            }
        });
        
    } catch (error) {
        console.error('Admin login error:', error);
        res.status(500).json({ error: 'Login failed' });
    }
});

/**
 * POST /api/auth/login
 * Login with email and password
 */
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password required' });
        }
        
        // Check if email is on the allowlist for password authentication
        if (!isEmailPasswordAllowed(email)) {
            console.log(`❌ Email/password login blocked for non-whitelisted email: ${email}`);
            return res.status(403).json({ 
                error: 'Email/password login isn\'t available for public accounts. Please use Sign in with Apple or Google.',
                errorType: 'not_whitelisted'
            });
        }
        
        // Get user by email
        const result = await pool.query(
            'SELECT * FROM users WHERE email = $1',
            [email.toLowerCase()]
        );
        
        if (result.rows.length === 0) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }
        
        const user = result.rows[0];
        
        // Check if user has password (not OAuth user)
        if (!user.password_hash) {
            return res.status(401).json({ error: 'Please use social login for this account' });
        }
        
        // Verify password with bcrypt
        const bcrypt = require('bcrypt');
        const validPassword = await bcrypt.compare(password, user.password_hash);
        
        if (!validPassword) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }
        
        // Check if account is banned or inactive
        if (user.is_banned) {
            return res.status(403).json({ error: 'Account has been banned. Reason: ' + (user.banned_reason || 'Violation of terms') });
        }
        
        if (!user.is_active) {
            return res.status(403).json({ error: 'Account is inactive. Please contact support.' });
        }
        
        // Update last active
        await pool.query(
            'UPDATE users SET last_active_at = NOW() WHERE user_id = $1',
            [user.user_id]
        );
        
        // Generate JWT token
        const token = generateToken(user.user_id, email);
        
        // Calculate days remaining
        const now = new Date();
        const endDate = user.subscription_end_date ? new Date(user.subscription_end_date) : null;
        let daysRemaining = 0;
        
        if (endDate) {
            const diffTime = endDate - now;
            daysRemaining = Math.max(0, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));
        }
        
        res.json({
            userId: user.user_id,
            email: user.email,
            token: token,
            age: null, // Not stored in current schema
            grade: null, // Not stored in current schema
            subscription_status: user.subscription_status,
            subscription_end_date: user.subscription_end_date,
            days_remaining: daysRemaining
        });
        
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ error: 'Login failed' });
    }
});

/**
 * POST /api/auth/register
 * Register new user with email and password
 * RESTRICTED: Only whitelisted emails can register with password
 */
router.post('/register', async (req, res) => {
    try {
        const { email, password, age, grade } = req.body;
        
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password required' });
        }
        
        // Check if email is on the allowlist for password authentication
        if (!isEmailPasswordAllowed(email)) {
            console.log(`❌ Email/password registration blocked for non-whitelisted email: ${email}`);
            return res.status(403).json({ 
                error: 'Email/password registration isn\'t available for public accounts. Please use Sign in with Apple or Google.',
                errorType: 'not_whitelisted'
            });
        }
        
        // Check if user already exists
        const existingUser = await pool.query(
            'SELECT * FROM users WHERE email = $1',
            [email.toLowerCase()]
        );
        
        if (existingUser.rows.length > 0) {
            return res.status(400).json({ error: 'User with this email already exists' });
        }
        
        // Hash password with bcrypt
        const bcrypt = require('bcrypt');
        const password_hash = await bcrypt.hash(password, 10);
        
        // Generate user ID
        const { v4: uuidv4 } = require('uuid');
        const user_id = uuidv4();
        
        // NO CUSTOM TRIAL - Users start with expired status
        // They must purchase through Apple IAP to get trial (Apple enforces one trial per Apple ID)
        // This prevents trial abuse via account deletion
        
        // Create user with NO subscription (must go through Apple IAP)
        const result = await pool.query(`
            INSERT INTO users (
                user_id, email, username, password_hash, auth_provider,
                subscription_status, subscription_start_date, subscription_end_date,
                is_active, is_banned
            )
            VALUES ($1, $2, $3, $4, 'email', 'expired', NULL, NULL, true, false)
            RETURNING *
        `, [
            user_id,
            email.toLowerCase(),
            email.toLowerCase(), // username = email
            password_hash
        ]);
        
        const user = result.rows[0];
        
        // Log account creation (no trial given)
        await pool.query(`
            INSERT INTO subscription_history (user_id, event_type, new_status, new_end_date)
            VALUES ($1, 'account_created', 'expired', NULL)
        `, [user_id]);
        
        // Generate JWT token
        const token = generateToken(user_id, email);
        
        // Send welcome email (don't wait for it)
        sendWelcomeEmail(email, email.split('@')[0]).catch(err => {
            console.error('Failed to send welcome email:', err);
        });
        
        res.status(201).json({
            userId: user.user_id,
            email: user.email,
            token: token,
            age: age || null,
            grade: grade || null,
            subscription_status: 'expired',  // No free trial - must go through Apple IAP
            days_remaining: 0,
            createdAt: user.created_at,
            message: 'Account created. Subscribe to unlock premium features.'
        });
        
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ error: 'Registration failed' });
    }
});

/**
 * POST /api/auth/google
 * Google Sign-In authentication endpoint
 */
router.post('/google', async (req, res) => {
    try {
        const { googleIdToken, email, name } = req.body;
        
        if (!email || !name) {
            return res.status(400).json({ error: 'Email and name required for Google authentication' });
        }
        
        console.log(`🔍 Google authentication attempt for: ${email} (${name})`);
        
        // Check if user exists by email
        const existingUser = await pool.query(
            'SELECT * FROM users WHERE email = $1',
            [email.toLowerCase()]
        );
        
        if (existingUser.rows.length > 0) {
            // User exists, check if account is active
            const user = existingUser.rows[0];
            
            // Check if user is banned
            if (user.is_banned) {
                console.log(`❌ Google authentication failed - user is banned: ${email}`);
                return res.status(403).json({ 
                    error: 'Account has been banned',
                    reason: user.banned_reason || 'Violation of terms'
                });
            }
            
            // Check if user is inactive
            if (!user.is_active) {
                console.log(`❌ Google authentication failed - user is inactive: ${email}`);
                return res.status(403).json({ 
                    error: 'Account is inactive. Please contact support.'
                });
            }
            
            await pool.query(
                'UPDATE users SET last_active_at = NOW() WHERE user_id = $1',
                [user.user_id]
            );
            
            const token = generateToken(user.user_id, email);
            
            // Calculate days remaining
            const now = new Date();
            const endDate = user.subscription_end_date ? new Date(user.subscription_end_date) : null;
            let daysRemaining = 0;
            
            if (endDate) {
                const diffTime = endDate - now;
                daysRemaining = Math.max(0, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));
            }
            
            // Track device login
            const deviceInfo = req.body.deviceInfo || {};
            let trackingResult = null;
            try {
                console.log(`🔍 Attempting to track device login for user ${user.user_id}`);
                console.log(`🔍 Device info received:`, JSON.stringify(deviceInfo, null, 2));
                trackingResult = await trackDeviceLogin(
                    user.user_id,
                    deviceInfo.deviceId || 'unknown',
                    req.ip || req.connection.remoteAddress,
                    req.get('User-Agent'),
                    deviceInfo
                );
                console.log(`✅ Device tracking result:`, trackingResult);
            } catch (trackingError) {
                console.error(`❌ Device tracking failed for user ${user.user_id}:`, trackingError.message);
                // Don't fail the login if tracking fails
            }
            
            console.log(`✅ Google authentication successful for existing user: ${email}`);
            if (trackingResult) {
                console.log(`📱 Device tracking result:`, trackingResult.fraudAnalysis);
            }
            
            return res.json({
                userId: user.user_id,
                email: user.email,
                token: token,
                age: null, // Not stored in current schema
                grade: null, // Not stored in current schema
                subscription_status: user.subscription_status,
                subscription_end_date: user.subscription_end_date,
                days_remaining: daysRemaining,
                deviceInfo: trackingResult?.deviceInfo
            });
        }
        
        // Create new user with Google authentication
        const { v4: uuidv4 } = require('uuid');
        const user_id = uuidv4();
        
        // NO CUSTOM TRIAL - Users start with expired status
        // They must purchase through Apple IAP to get trial (Apple enforces one trial per Apple ID)
        // This prevents trial abuse via account deletion
        
        // Create user with Google provider (NO subscription)
        const result = await pool.query(`
            INSERT INTO users (
                user_id, email, username, auth_provider,
                subscription_status, subscription_start_date, subscription_end_date,
                is_active, is_banned
            )
            VALUES ($1, $2, $3, 'google', 'expired', NULL, NULL, true, false)
            RETURNING *
        `, [
            user_id,
            email.toLowerCase(),
            name // Use Google name as username
        ]);
        
        const user = result.rows[0];
        
        // Log account creation (no trial given)
        await pool.query(`
            INSERT INTO subscription_history (user_id, event_type, new_status, new_end_date)
            VALUES ($1, 'account_created', 'expired', NULL)
        `, [user_id]);
        
        // Generate JWT token
        const token = generateToken(user_id, email);
        
        // Track device login for new user
        const deviceInfo = req.body.deviceInfo || {};
        let trackingResult = null;
        try {
            trackingResult = await trackDeviceLogin(
                user.user_id,
                deviceInfo.deviceId || 'unknown',
                req.ip || req.connection.remoteAddress,
                req.get('User-Agent'),
                deviceInfo
            );
        } catch (trackingError) {
            console.error(`❌ Device tracking failed for new user ${user.user_id}:`, trackingError.message);
            // Don't fail the login if tracking fails
        }
        
        console.log(`✅ Google authentication successful - new user created: ${email}`);
        if (trackingResult) {
            console.log(`📱 Device tracking result:`, trackingResult.fraudAnalysis);
        }
        
        res.status(201).json({
            userId: user.user_id,
            email: user.email,
            token: token,
            age: null,
            grade: null,
            subscription_status: 'expired',  // No free trial - must go through Apple IAP
            subscription_end_date: null,
            days_remaining: 0,
            createdAt: user.created_at,
            deviceInfo: trackingResult?.deviceInfo,
            message: 'Account created. Subscribe to unlock premium features.'
        });
        
    } catch (error) {
        console.error('Google authentication error:', error);
        res.status(500).json({ error: 'Google authentication failed' });
    }
});

/**
 * POST /api/auth/apple
 * Apple Sign-In authentication endpoint
 */
router.post('/apple', async (req, res) => {
    try {
        const { userIdentifier, email, name, appleIDToken } = req.body;
        
        console.log(`🍎 Apple Sign-In request received:`, {
            userIdentifier,
            email: email || 'none',
            name: name || 'none',
            hasToken: !!appleIDToken
        });
        
        if (!userIdentifier || !appleIDToken) {
            console.log('❌ Missing required fields');
            return res.status(400).json({ error: 'User identifier and Apple ID token required' });
        }
        
        // For now, we'll use the email if provided, otherwise generate one from userIdentifier
        const userEmail = email && email.trim() !== '' ? email.toLowerCase() : `${userIdentifier}@privaterelay.appleid.com`;
        const displayName = name && name.trim() !== '' ? name : '';
        
        console.log(`🍎 Apple Sign-In attempt: ${userEmail} (${userIdentifier})`);
        console.log(`🔍 Searching for existing user...`);
        console.log(`🔍 Search params: apple_user_id=${userIdentifier}, email=${userEmail}`);
        
        // Check if user already exists (by apple_user_id or email)
        let existingUser;
        try {
            existingUser = await pool.query(`
                SELECT * FROM users 
                WHERE apple_user_id = $1 OR email = $2
            `, [userIdentifier, userEmail]);
            console.log(`🔍 Found ${existingUser.rows.length} existing user(s)`);
        } catch (dbError) {
            console.error('❌ Database query error:', dbError.message);
            throw new Error(`Database query failed: ${dbError.message}`);
        }
        
        if (existingUser.rows.length > 0) {
            const user = existingUser.rows[0];
            
            console.log(`✅ Found existing user: ${user.email} (user_id: ${user.user_id})`);
            console.log(`   apple_user_id: ${user.apple_user_id || 'NULL'}`);
            console.log(`   is_active: ${user.is_active}, is_banned: ${user.is_banned}`);
            
            // Check if user is banned or inactive
            if (user.is_banned) {
                console.log(`❌ Apple authentication failed - user is banned: ${userEmail}`);
                return res.status(403).json({ 
                    error: 'Account has been banned',
                    reason: user.banned_reason || 'Violation of terms'
                });
            }
            
            if (!user.is_active) {
                console.log(`❌ Apple authentication failed - user is inactive: ${userEmail}`);
                return res.status(403).json({ 
                    error: 'Account is inactive. Please contact support.'
                });
            }
            
            // Update Apple user ID if not set
            try {
                if (!user.apple_user_id) {
                    console.log(`📝 Setting apple_user_id for existing user...`);
                    await pool.query(`
                        UPDATE users SET apple_user_id = $1 WHERE user_id = $2
                    `, [userIdentifier, user.user_id]);
                    console.log(`✅ apple_user_id set to: ${userIdentifier}`);
                }
            } catch (updateError) {
                console.error('⚠️ Failed to update apple_user_id:', updateError.message);
                // Continue anyway - not critical
            }
            
            // Update username if provided and current username is empty or generic
            try {
                if (name && name.trim() !== '' && 
                    (!user.username || user.username.trim() === '' || user.username.includes('@privaterelay'))) {
                    await pool.query(`
                        UPDATE users SET username = $1 WHERE user_id = $2
                    `, [displayName, user.user_id]);
                    console.log(`📝 Updated username from "${user.username}" to "${displayName}"`);
                }
            } catch (updateError) {
                console.error('⚠️ Failed to update username:', updateError.message);
                // Continue anyway - not critical
            }
            
            // Update last login (use last_active_at if last_login doesn't exist)
            try {
                await pool.query(`
                    UPDATE users SET last_active_at = NOW() WHERE user_id = $1
                `, [user.user_id]);
                console.log(`✅ Updated last_active_at`);
            } catch (updateError) {
                console.error('⚠️ Failed to update last_active_at:', updateError.message);
                // Continue anyway - not critical
            }
            
            // Generate JWT token
            let token;
            try {
                token = generateToken(user.user_id, user.email);
                console.log(`✅ JWT token generated`);
            } catch (tokenError) {
                console.error('❌ Failed to generate token:', tokenError.message);
                throw new Error('Token generation failed');
            }
            
            // Calculate days remaining
            const daysRemaining = user.subscription_end_date 
                ? Math.max(0, Math.ceil((user.subscription_end_date - new Date()) / (1000 * 60 * 60 * 24)))
                : 0;
            
            // Track device login
            const deviceInfo = req.body.deviceInfo || {};
            let trackingResult = null;
            try {
                console.log(`🔍 Attempting to track device login for user ${user.user_id}`);
                console.log(`🔍 Device info received:`, JSON.stringify(deviceInfo, null, 2));
                trackingResult = await trackDeviceLogin(
                    user.user_id,
                    deviceInfo.deviceId || 'unknown',
                    req.ip || req.connection.remoteAddress,
                    req.get('User-Agent'),
                    deviceInfo
                );
                console.log(`✅ Device tracking result:`, trackingResult);
            } catch (trackingError) {
                console.error(`❌ Device tracking failed for user ${user.user_id}:`, trackingError.message);
                // Don't fail the login if tracking fails
            }
            
            console.log(`✅ Apple authentication successful - existing user: ${userEmail}`);
            if (trackingResult) {
                console.log(`📱 Device tracking result:`, trackingResult.fraudAnalysis);
            }
            
            res.status(200).json({
                userId: user.user_id,
                email: user.email,
                token: token,
                age: user.age,
                grade: user.grade,
                subscription_status: user.subscription_status,
                subscription_end_date: user.subscription_end_date,
                days_remaining: daysRemaining,
                isActive: user.is_active,
                isBanned: user.is_banned,
                createdAt: user.created_at,
                deviceInfo: trackingResult?.deviceInfo
            });
            return;
        }
        
        // Create new user with Apple authentication
        const { v4: uuidv4 } = require('uuid');
        const user_id = uuidv4();
        
        // NO CUSTOM TRIAL - Users start with expired status
        // They must purchase through Apple IAP to get trial (Apple enforces one trial per Apple ID)
        // This prevents trial abuse via account deletion
        
        // Create user with Apple provider (NO subscription)
        const result = await pool.query(`
            INSERT INTO users (
                user_id, email, username, auth_provider, apple_user_id,
                subscription_status, subscription_start_date, subscription_end_date,
                is_active, is_banned
            )
            VALUES ($1, $2, $3, 'apple', $4, 'expired', NULL, NULL, true, false)
            RETURNING *
        `, [
            user_id,
            userEmail,
            displayName,
            userIdentifier
        ]);
        
        const user = result.rows[0];
        
        // Log account creation (no trial given)
        await pool.query(`
            INSERT INTO subscription_history (user_id, event_type, new_status, new_end_date)
            VALUES ($1, 'account_created', 'expired', NULL)
        `, [user_id]);
        
        // Generate JWT token
        const token = generateToken(user_id, userEmail);
        
        // Track device login for new Apple user
        const deviceInfo = req.body.deviceInfo || {};
        let trackingResult = null;
        try {
            trackingResult = await trackDeviceLogin(
                user.user_id,
                deviceInfo.deviceId || 'unknown',
                req.ip || req.connection.remoteAddress,
                req.get('User-Agent'),
                deviceInfo
            );
        } catch (trackingError) {
            console.error(`❌ Device tracking failed for new Apple user ${user.user_id}:`, trackingError.message);
            // Don't fail the login if tracking fails
        }
        
        console.log(`✅ Apple authentication successful - new user created: ${userEmail}`);
        if (trackingResult) {
            console.log(`📱 Device tracking result:`, trackingResult.fraudAnalysis);
        }
        
        res.status(201).json({
            userId: user.user_id,
            email: user.email,
            token: token,
            age: null,
            grade: null,
            subscription_status: 'expired',  // No free trial - must go through Apple IAP
            subscription_end_date: null,
            days_remaining: 0,
            isActive: user.is_active,
            isBanned: user.is_banned,
            createdAt: user.created_at,
            deviceInfo: trackingResult?.deviceInfo,
            message: 'Account created. Subscribe to unlock premium features.'
        });
        
    } catch (error) {
        console.error('Apple authentication error:', error);
        console.error('Error details:', error.message);
        console.error('Stack trace:', error.stack);
        res.status(500).json({ 
            error: 'Apple authentication failed',
            details: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
});

/**
 * PUT /api/auth/update-profile
 * Update user profile (username, age, grade)
 */
router.put('/update-profile', authenticateUser, async (req, res) => {
    try {
        const { username, age, grade } = req.body;
        const userId = req.user.userId;
        
        if (!username || username.trim() === '') {
            return res.status(400).json({ error: 'Username is required' });
        }
        
        // Update user profile
        const result = await pool.query(`
            UPDATE users 
            SET username = $1, grade = $2
            WHERE user_id = $3
            RETURNING user_id, email, username, grade
        `, [username.trim(), grade || null, userId]);
        
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        console.log(`✅ Profile updated for user: ${result.rows[0].email} (${userId})`);
        
        res.json({
            success: true,
            message: 'Profile updated successfully',
            user: result.rows[0]
        });
        
    } catch (error) {
        console.error('Profile update error:', error);
        res.status(500).json({ error: 'Failed to update profile' });
    }
});

/**
 * POST /api/auth/oauth-register
 * Register or update user after OAuth authentication (Google, Apple, etc.)
 */
router.post('/oauth-register', async (req, res) => {
    try {
        const { user_id, email, username, provider } = req.body;
        
        if (!user_id || !email) {
            return res.status(400).json({ error: 'User ID and email required' });
        }
        
        // Check if user exists
        const existingUser = await pool.query(
            'SELECT * FROM users WHERE user_id = $1',
            [user_id]
        );
        
        if (existingUser.rows.length > 0) {
            // User exists, update last active
            await pool.query(
                'UPDATE users SET last_active_at = NOW() WHERE user_id = $1',
                [user_id]
            );
            
            const user = existingUser.rows[0];
            const token = generateToken(user_id, email);
            
            // Calculate days remaining
            const now = new Date();
            const endDate = user.subscription_end_date ? new Date(user.subscription_end_date) : null;
            let daysRemaining = 0;
            
            if (endDate) {
                const diffTime = endDate - now;
                daysRemaining = Math.max(0, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));
            }
            
            return res.json({
                success: true,
                token,
                user: {
                    user_id: user.user_id,
                    email: user.email,
                    subscription_status: user.subscription_status,
                    days_remaining: daysRemaining
                }
            });
        }
        
        // Create new user with 7-day trial
        const trialEndDate = new Date();
        trialEndDate.setDate(trialEndDate.getDate() + 7);
        
        const result = await pool.query(`
            INSERT INTO users (
                user_id, email, username, auth_provider,
                subscription_status, subscription_start_date, subscription_end_date
            ) VALUES ($1, $2, $3, $4, 'trial', NOW(), $5)
            RETURNING *
        `, [user_id, email, email, provider, trialEndDate]); // username = email
        
        const user = result.rows[0];
        
        // Log trial start
        await pool.query(`
            INSERT INTO subscription_history (user_id, event_type, new_status, new_end_date)
            VALUES ($1, 'trial_started', 'trial', $2)
        `, [user_id, trialEndDate]);
        
        const token = generateToken(user_id, email);
        
        res.json({
            success: true,
            token,
            user: {
                user_id: user.user_id,
                email: user.email,
                subscription_status: 'trial',
                days_remaining: 14,
                trial_started: true
            }
        });
        
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ error: 'Registration failed' });
    }
});

/**
 * POST /api/auth/request-reset
 * Request password reset - sends email with reset link
 */
router.post('/request-reset', async (req, res) => {
    try {
        const { email } = req.body;
        
        if (!email || !email.includes('@')) {
            return res.status(400).json({ error: 'Valid email address required' });
        }
        
        // Find user by email (case-insensitive)
        const userResult = await pool.query(
            'SELECT user_id, email, username FROM users WHERE email = $1',
            [email.toLowerCase()]
        );
        
        // Always return success to prevent email enumeration attacks
        // (don't reveal if email exists or not)
        if (userResult.rows.length === 0) {
            return res.json({
                success: true,
                message: 'If that email exists in our system, a reset link has been sent'
            });
        }
        
        const user = userResult.rows[0];
        
        // Check if user has a password (not OAuth-only account)
        const checkPassword = await pool.query(
            'SELECT password_hash FROM users WHERE user_id = $1',
            [user.user_id]
        );
        
        if (!checkPassword.rows[0].password_hash) {
            return res.json({
                success: true,
                message: 'If that email exists in our system, a reset link has been sent'
            });
        }
        
        // Generate secure reset token (32 bytes = 64 hex characters)
        const resetToken = crypto.randomBytes(32).toString('hex');
        
        // Set expiration to 1 hour from now
        const expiresAt = new Date(Date.now() + 60 * 60 * 1000);
        
        // Save token to database
        await pool.query(
            `INSERT INTO password_reset_tokens (user_id, token, expires_at)
             VALUES ($1, $2, $3)`,
            [user.user_id, resetToken, expiresAt]
        );
        
        // Send email with reset link
        try {
            await sendPasswordResetEmail(
                user.email,
                resetToken,
                user.username || user.email.split('@')[0]
            );
            
            console.log(`✅ Password reset requested for ${user.email}`);
            
            res.json({
                success: true,
                message: 'If that email exists in our system, a reset link has been sent'
            });
        } catch (emailError) {
            console.error('⚠️  Failed to send reset email (SendGrid not configured):', emailError.message);
            
            // Token is still saved in DB for testing
            // In testing mode, return success anyway so developers can test with deep links
            console.log(`⚠️  Token saved in database for manual testing`);
            console.log(`📱 Deep link: homeworkhelper://reset-password?token=${resetToken}`);
            
            res.json({
                success: true,
                message: 'Password reset requested. (Email not configured - check server logs for reset link)'
            });
        }
        
    } catch (error) {
        console.error('Password reset request error:', error);
        res.status(500).json({
            error: 'Failed to process password reset request'
        });
    }
});

/**
 * POST /api/auth/reset-password
 * Reset password using token from email
 */
router.post('/reset-password', async (req, res) => {
    try {
        const { token, newPassword } = req.body;
        
        // Validate input
        if (!token) {
            return res.status(400).json({ error: 'Reset token is required' });
        }
        
        if (!newPassword || newPassword.length < 6) {
            return res.status(400).json({
                error: 'Password must be at least 6 characters long'
            });
        }
        
        // Find valid, unused, non-expired token
        const tokenResult = await pool.query(
            `SELECT rt.id, rt.user_id, rt.expires_at, rt.used
             FROM password_reset_tokens rt
             WHERE rt.token = $1 
               AND rt.used = FALSE 
               AND rt.expires_at > NOW()`,
            [token]
        );
        
        if (tokenResult.rows.length === 0) {
            return res.status(400).json({
                success: false,
                error: 'Invalid or expired reset token'
            });
        }
        
        const resetToken = tokenResult.rows[0];
        
        // Hash the new password with bcrypt
        const bcrypt = require('bcrypt');
        const passwordHash = await bcrypt.hash(newPassword, 10);
        
        // Update user's password
        await pool.query(
            'UPDATE users SET password_hash = $1, updated_at = NOW() WHERE user_id = $2',
            [passwordHash, resetToken.user_id]
        );
        
        // Mark token as used
        await pool.query(
            'UPDATE password_reset_tokens SET used = TRUE, used_at = NOW() WHERE id = $1',
            [resetToken.id]
        );
        
        console.log(`✅ Password reset successful for user ${resetToken.user_id}`);
        
        res.json({
            success: true,
            message: 'Password successfully reset'
        });
        
    } catch (error) {
        console.error('Password reset error:', error);
        res.status(500).json({
            error: 'Failed to reset password'
        });
    }
});

/**
 * GET /api/auth/verify-reset-token
 * Verify if a reset token is valid (optional endpoint for client validation)
 */
router.get('/verify-reset-token', async (req, res) => {
    try {
        const { token } = req.query;
        
        if (!token) {
            return res.status(400).json({ error: 'Token is required' });
        }
        
        // Check if token is valid, unused, and not expired
        const tokenResult = await pool.query(
            `SELECT id FROM password_reset_tokens
             WHERE token = $1 
               AND used = FALSE 
               AND expires_at > NOW()`,
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

/**
 * DELETE /api/auth/delete-account
 * Delete user's own account (self-service)
 * Requires authentication token in header
 */
router.delete('/delete-account', authenticateUser, async (req, res) => {
    try {
        const userId = req.user.id;
        
        console.log(`🗑️ Account deletion request for user: ${userId}`);
        
        // Get user from database
        const result = await pool.query(
            'SELECT email FROM users WHERE user_id = $1',
            [userId]
        );
        
        if (result.rows.length === 0) {
            console.log(`❌ User not found: ${userId}`);
            return res.status(404).json({ 
                error: 'User not found' 
            });
        }
        
        const userEmail = result.rows[0].email;
        
        // ADDITIVE: Mirror entitlements to ledger BEFORE deletion (fraud prevention)
        try {
            const entitlements = await pool.query(
                'SELECT * FROM user_entitlements WHERE user_id = $1',
                [userId]
            );
            
            console.log(`📊 Mirroring ${entitlements.rows.length} entitlement(s) to ledger before deletion`);
            
            for (const ent of entitlements.rows) {
                if (!ent.original_transaction_id) {
                    console.log(`⚠️ Skipping entitlement ${ent.id} - no original_transaction_id`);
                    continue;
                }
                
                try {
                    await upsertLedgerRecord({
                        originalTransactionId: ent.original_transaction_id,
                        productId: ent.product_id,
                        subscriptionGroupId: ent.subscription_group_id,
                        status: ent.status,
                        everTrial: ent.is_trial
                    });
                    
                    console.log(`✅ Mirrored entitlement to ledger: product=${ent.product_id}, trial=${ent.is_trial}`);
                } catch (ledgerError) {
                    // Don't fail deletion if ledger upsert fails
                    console.error(`⚠️ Failed to mirror entitlement to ledger:`, ledgerError.message);
                }
            }
        } catch (entError) {
            // Don't fail deletion if entitlements query fails
            console.error(`⚠️ Failed to query user entitlements:`, entError.message);
        }
        
        // Delete all user-related data (cascade)
        await pool.query('DELETE FROM user_entitlements WHERE user_id = $1', [userId]);
        await pool.query('DELETE FROM subscription_history WHERE user_id = $1', [userId]);
        await pool.query('DELETE FROM promo_code_usage WHERE user_id = $1', [userId]);
        await pool.query('DELETE FROM password_reset_tokens WHERE user_id = $1', [userId]);
        await pool.query('DELETE FROM user_devices WHERE user_id = $1', [userId]);
        await pool.query('DELETE FROM user_api_usage WHERE user_id = $1', [userId]);
        await pool.query('DELETE FROM users WHERE user_id = $1', [userId]);
        
        console.log(`✅ Successfully deleted account: ${userEmail} (${userId})`);
        
        res.json({
            success: true,
            message: 'Account successfully deleted'
        });
        
    } catch (error) {
        console.error('Account deletion error:', error);
        res.status(500).json({ 
            error: 'Failed to delete account' 
        });
    }
});

/**
 * GET /api/auth/validate-session
 * Validate user session and check account status
 * Requires authentication token in header
 */
router.get('/validate-session', authenticateUser, async (req, res) => {
    try {
        const userId = req.user.id;
        
        console.log(`🔍 Session validation request for user: ${userId}`);
        
        // Get user from database
        const result = await pool.query(
            'SELECT * FROM users WHERE user_id = $1',
            [userId]
        );
        
        if (result.rows.length === 0) {
            console.log(`❌ User not found: ${userId}`);
            return res.status(404).json({ 
                valid: false,
                error: 'User not found' 
            });
        }
        
        const user = result.rows[0];
        
        // Check if user is banned
        if (user.is_banned) {
            console.log(`❌ User is banned: ${userId}`);
            return res.status(403).json({ 
                valid: false,
                error: 'Account has been banned',
                reason: user.banned_reason || 'Violation of terms',
                is_banned: true
            });
        }
        
        // Check if user is inactive
        if (!user.is_active) {
            console.log(`❌ User is inactive: ${userId}`);
            return res.status(403).json({ 
                valid: false,
                error: 'Account is inactive',
                is_active: false
            });
        }
        
        // Update last active timestamp
        await pool.query(
            'UPDATE users SET last_active_at = NOW() WHERE user_id = $1',
            [userId]
        );
        
        // Get subscription status using centralized service
        const subscriptionData = await calculateSubscriptionStatus(userId);
        
        console.log(`✅ Session valid for user: ${userId} (${user.email})`);
        
        // Return user status using centralized subscription data
        res.json({
            valid: true,
            user: {
                userId: user.user_id,
                email: user.email,
                username: user.username,
                subscriptionStatus: subscriptionData.status,
                subscriptionEndDate: subscriptionData.endDate,
                daysRemaining: subscriptionData.daysRemaining,
                isActive: user.is_active,
                isBanned: user.is_banned
            }
        });
        
    } catch (error) {
        console.error('Session validation error:', error);
        res.status(500).json({ 
            valid: false,
            error: 'Session validation failed' 
        });
    }
});

module.exports = router;

// Force deployment - Tue Oct  7 16:49:24 MST 2025
// DEPLOYMENT UPDATE: Account validation is now LIVE - $(date)
