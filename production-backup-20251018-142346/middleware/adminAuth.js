const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-this-in-production';
const ADMIN_JWT_SECRET = process.env.ADMIN_JWT_SECRET || 'admin-secret-key-change-this';

/**
 * Middleware to authenticate admin users
 */
function requireAdmin(req, res, next) {
    try {
        const authHeader = req.headers.authorization;
        
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'No admin token provided' });
        }
        
        const token = authHeader.substring(7);
        
        const decoded = jwt.verify(token, ADMIN_JWT_SECRET);
        
        // Check if user is admin
        if (!decoded.isAdmin) {
            return res.status(403).json({ error: 'Admin access required' });
        }
        
        // Attach admin info to request
        req.admin = {
            id: decoded.adminId,
            username: decoded.username,
            email: decoded.email
        };
        
        next();
        
    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({ error: 'Admin token expired' });
        }
        
        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({ error: 'Invalid admin token' });
        }
        
        console.error('Admin auth middleware error:', error);
        return res.status(500).json({ error: 'Admin authentication failed' });
    }
}

/**
 * Generate admin JWT token
 */
function generateAdminToken(adminId, username, email) {
    return jwt.sign(
        { adminId, username, email, isAdmin: true },
        ADMIN_JWT_SECRET,
        { expiresIn: '7d' } // Admin token valid for 7 days
    );
}

module.exports = {
    requireAdmin,
    generateAdminToken
};


