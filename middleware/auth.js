const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-this-in-production';

/**
 * Middleware to authenticate users via JWT token
 */
function authenticateUser(req, res, next) {
    try {
        const authHeader = req.headers.authorization;
        
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'No authentication token provided' });
        }
        
        const token = authHeader.substring(7); // Remove 'Bearer ' prefix
        
        const decoded = jwt.verify(token, JWT_SECRET);
        
        // Attach user info to request
        req.user = {
            id: decoded.userId,
            email: decoded.email
        };
        
        next();
        
    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({ error: 'Token expired' });
        }
        
        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({ error: 'Invalid token' });
        }
        
        console.error('Auth middleware error:', error);
        return res.status(500).json({ error: 'Authentication failed' });
    }
}

/**
 * Generate JWT token for a user
 */
function generateToken(userId, email) {
    return jwt.sign(
        { userId, email },
        JWT_SECRET,
        { expiresIn: '30d' } // Token valid for 30 days
    );
}

module.exports = authenticateUser;
module.exports.generateToken = generateToken;


