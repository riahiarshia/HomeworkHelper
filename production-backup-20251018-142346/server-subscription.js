/**
 * Homework Helper Backend Server
 * With Subscription Management
 */

const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Serve static files (admin dashboard)
app.use('/admin', express.static(path.join(__dirname, 'public/admin')));

// Import routes
const authRoutes = require('./routes/auth');
const subscriptionRoutes = require('./routes/subscription');
const adminRoutes = require('./routes/admin');
const paymentRoutes = require('./routes/payment');

// Register routes
app.use('/api/auth', authRoutes);
app.use('/api/subscription', subscriptionRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/payment', paymentRoutes);

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Root route
app.get('/', (req, res) => {
    res.json({
        message: 'Homework Helper API',
        version: '1.0.0',
        endpoints: {
            admin_dashboard: '/admin',
            api_health: '/api/health',
            auth: '/api/auth',
            subscription: '/api/subscription',
            payment: '/api/payment'
        }
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Server error:', err);
    res.status(500).json({
        error: 'Internal server error',
        message: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`
╔════════════════════════════════════════════════════════╗
║                                                        ║
║   📚 Homework Helper Backend Server                   ║
║                                                        ║
║   🚀 Server running on port ${PORT}                      ║
║   🌐 Admin Dashboard: http://localhost:${PORT}/admin     ║
║   📊 API Endpoint: http://localhost:${PORT}/api          ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
    `);
});

module.exports = app;


