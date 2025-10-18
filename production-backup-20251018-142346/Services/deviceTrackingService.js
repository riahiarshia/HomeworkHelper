const { Pool } = require('pg');

// Database connection
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

/**
 * Track device login for analytics and fraud detection
 * @param {string} userId - User ID
 * @param {string} deviceId - Device identifier
 * @param {string} ipAddress - IP address
 * @param {string} userAgent - User agent string
 * @param {Object} deviceInfo - Device information object
 * @returns {Object} Tracking result with fraud analysis
 */
async function trackDeviceLogin(userId, deviceId, ipAddress, userAgent, deviceInfo = {}) {
    try {
        console.log(`📱 Tracking device login: User ${userId}, Device ${deviceId}`);
        console.log(`📱 Device Info:`, JSON.stringify(deviceInfo, null, 2));
        console.log(`📱 IP Address: ${ipAddress}, User Agent: ${userAgent}`);
        
        // 1. Record the device login
        await pool.query(`
            INSERT INTO device_logins (user_id, device_id, login_time, ip_address, user_agent, device_info)
            VALUES ($1, $2, NOW(), $3, $4, $5)
        `, [userId, deviceId, ipAddress, userAgent, JSON.stringify(deviceInfo)]);
        
        console.log(`✅ Device login recorded successfully for user ${userId}`);
        
        // 2. Update or create user device record
        await pool.query(`
            INSERT INTO user_devices (user_id, device_id, device_name, last_seen, login_count)
            VALUES ($1, $2, $3, NOW(), 1)
            ON CONFLICT (user_id, device_id)
            DO UPDATE SET 
                last_seen = NOW(),
                login_count = user_devices.login_count + 1,
                device_name = EXCLUDED.device_name
        `, [userId, deviceId, deviceInfo.deviceName || 'Unknown Device']);
        
        // 3. Run fraud detection
        const fraudAnalysis = await analyzeFraudPatterns(userId, deviceId, ipAddress);
        
        // 4. Return tracking result
        return {
            success: true,
            fraudAnalysis,
            deviceInfo: {
                deviceId,
                deviceName: deviceInfo.deviceName || 'Unknown Device',
                isTrusted: await isDeviceTrusted(userId, deviceId)
            }
        };
        
    } catch (error) {
        console.error('Error tracking device login:', error);
        return {
            success: false,
            error: error.message
        };
    }
}

/**
 * Analyze fraud patterns for the device
 * @param {string} userId - User ID
 * @param {string} deviceId - Device identifier
 * @param {string} ipAddress - IP address
 * @returns {Object} Fraud analysis results
 */
async function analyzeFraudPatterns(userId, deviceId, ipAddress) {
    const patterns = [];
    let severity = 'low';
    
    try {
        // Rule 1: Check accounts per device (last 7 days)
        const deviceAccounts = await pool.query(`
            SELECT COUNT(DISTINCT user_id) as account_count
            FROM device_logins 
            WHERE device_id = $1 AND login_time > NOW() - INTERVAL '7 days'
        `, [deviceId]);
        
        const accountCount = parseInt(deviceAccounts.rows[0].account_count) || 0;
        
        if (accountCount > 5) {
            patterns.push(`excessive_accounts_per_device:${accountCount}`);
            severity = 'high';
        } else if (accountCount > 3) {
            patterns.push(`multiple_accounts_per_device:${accountCount}`);
            severity = 'medium';
        }
        
        // Rule 2: Check rapid account switching (last hour)
        const recentLogins = await pool.query(`
            SELECT COUNT(DISTINCT user_id) as count
            FROM device_logins 
            WHERE device_id = $1 AND login_time > NOW() - INTERVAL '1 hour'
        `, [deviceId]);
        
        const rapidSwitching = parseInt(recentLogins.rows[0].count) || 0;
        
        if (rapidSwitching > 3) {
            patterns.push(`rapid_account_switching:${rapidSwitching}`);
            severity = severity === 'low' ? 'medium' : severity;
        }
        
        // Rule 3: Check multiple IP addresses (last 24 hours)
        const ipCount = await pool.query(`
            SELECT COUNT(DISTINCT ip_address) as count
            FROM device_logins 
            WHERE device_id = $1 AND login_time > NOW() - INTERVAL '24 hours'
        `, [deviceId]);
        
        const ipAddressCount = parseInt(ipCount.rows[0].count) || 0;
        
        if (ipAddressCount > 5) {
            patterns.push(`multiple_ip_addresses:${ipAddressCount}`);
            severity = severity === 'low' ? 'medium' : severity;
        }
        
        // Rule 4: Check for new device (first time seeing this device)
        const deviceHistory = await pool.query(`
            SELECT COUNT(*) as count
            FROM device_logins 
            WHERE device_id = $1
        `, [deviceId]);
        
        const isNewDevice = parseInt(deviceHistory.rows[0].count) === 1;
        
        if (isNewDevice) {
            patterns.push('new_device_detected');
        }
        
        // Create fraud flag if patterns detected
        if (patterns.length > 0) {
            await createFraudFlag(userId, deviceId, patterns, severity);
        }
        
        return {
            patterns,
            severity,
            isNewDevice,
            accountCount,
            rapidSwitching,
            ipAddressCount
        };
        
    } catch (error) {
        console.error('Error analyzing fraud patterns:', error);
        return {
            patterns: ['analysis_error'],
            severity: 'low',
            error: error.message
        };
    }
}

/**
 * Create a fraud flag for manual review
 * @param {string} userId - User ID
 * @param {string} deviceId - Device identifier
 * @param {Array} patterns - Detected fraud patterns
 * @param {string} severity - Severity level
 */
async function createFraudFlag(userId, deviceId, patterns, severity) {
    try {
        await pool.query(`
            INSERT INTO fraud_flags (user_id, device_id, reason, severity, details)
            VALUES ($1, $2, $3, $4, $5)
        `, [
            userId, 
            deviceId, 
            patterns.join(', '), 
            severity, 
            JSON.stringify({ patterns, timestamp: new Date().toISOString() })
        ]);
        
        console.log(`🚨 Fraud flag created: User ${userId}, Device ${deviceId}, Severity: ${severity}`);
        
    } catch (error) {
        console.error('Error creating fraud flag:', error);
    }
}

/**
 * Check if device is trusted by user
 * @param {string} userId - User ID
 * @param {string} deviceId - Device identifier
 * @returns {boolean} Is device trusted
 */
async function isDeviceTrusted(userId, deviceId) {
    try {
        const result = await pool.query(`
            SELECT is_trusted
            FROM user_devices
            WHERE user_id = $1 AND device_id = $2
        `, [userId, deviceId]);
        
        return result.rows.length > 0 ? result.rows[0].is_trusted : false;
        
    } catch (error) {
        console.error('Error checking device trust status:', error);
        return false;
    }
}

/**
 * Get device analytics for admin dashboard
 * @param {number} limit - Number of results to return
 * @returns {Array} Device analytics data
 */
async function getDeviceAnalytics(limit = 50) {
    try {
        const result = await pool.query(`
            SELECT 
                device_id,
                COUNT(DISTINCT user_id) as account_count,
                COUNT(*) as total_logins,
                MIN(login_time) as first_seen,
                MAX(login_time) as last_seen,
                STRING_AGG(DISTINCT ip_address::text, ', ') as ip_addresses
            FROM device_logins 
            WHERE login_time > NOW() - INTERVAL '30 days'
            GROUP BY device_id
            HAVING COUNT(DISTINCT user_id) > 1
            ORDER BY account_count DESC, total_logins DESC
            LIMIT $1
        `, [limit]);
        
        return result.rows;
        
    } catch (error) {
        console.error('Error getting device analytics:', error);
        return [];
    }
}

/**
 * Get fraud flags for admin review
 * @param {boolean} unresolvedOnly - Only get unresolved flags
 * @returns {Array} Fraud flags data
 */
async function getFraudFlags(unresolvedOnly = true) {
    try {
        const query = unresolvedOnly ? 
            `SELECT * FROM fraud_flags WHERE resolved = false ORDER BY created_at DESC` :
            `SELECT * FROM fraud_flags ORDER BY created_at DESC LIMIT 100`;
            
        const result = await pool.query(query);
        
        return result.rows;
        
    } catch (error) {
        console.error('Error getting fraud flags:', error);
        return [];
    }
}

module.exports = {
    trackDeviceLogin,
    analyzeFraudPatterns,
    getDeviceAnalytics,
    getFraudFlags,
    isDeviceTrusted
};
