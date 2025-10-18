/**
 * Homework Helper Backend Server
 * With Subscription Management
 * Azure Deployment Version
 */

const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8080;

// Middleware
app.use(cors());

// Special handling for Stripe webhooks (needs raw body)
app.use('/api/payment/webhook', express.raw({type: 'application/json'}));

// JSON parsing for all other routes
app.use(express.json());

// Serve static files (admin dashboard)
app.use('/admin', express.static(path.join(__dirname, 'public/admin')));

// Import routes
const authRoutes = require('./routes/auth');
const subscriptionRoutes = require('./routes/subscription');
const adminRoutes = require('./routes/admin');
const adminDeviceRoutes = require('./routes/admin-devices');
const adminActivityRoutes = require('./routes/admin-activity');
const migrationRoutes = require('./routes/migration');
const paymentRoutes = require('./routes/payment');
const imageAnalysisRoutes = require('./routes/imageAnalysis');
const databaseRoutes = require('./routes/database');
const debugRoutes = require('./routes/debug');
const homeworkRoutes = require('./routes/homework');
const usageRoutes = require('./routes/usage');

// Register routes
app.use('/api/auth', authRoutes);
app.use('/api/subscription', subscriptionRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/admin/devices', adminDeviceRoutes);
app.use('/api/admin/activity', adminActivityRoutes);
app.use('/api/migration', migrationRoutes);
app.use('/api/payment', paymentRoutes);
app.use('/api', imageAnalysisRoutes);
app.use('/api/database', databaseRoutes);
app.use('/api/debug', debugRoutes);
app.use('/api/homework', homeworkRoutes);
app.use('/api/usage', usageRoutes);

// Health check
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development'
    });
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
            admin: '/api/admin',
            payment: '/api/payment',
            image_analysis: '/api/validate-image, /api/analyze-homework'
        }
    });
});

// Redirect /admin without trailing slash
app.get('/admin', (req, res) => {
    res.redirect('/admin/');
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Server error:', err);
    res.status(500).json({
        error: 'Internal server error',
        message: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

// Auto-apply database migrations on startup
const checkAndApplyMigrations = require('./auto-migrate-on-startup');

// Start server
app.listen(PORT, async () => {
    console.log(`
╔════════════════════════════════════════════════════════╗
║                                                        ║
║   📚 Homework Helper Backend Server                   ║
║                                                        ║
║   🚀 Server running on port ${PORT}                      ║
║   🌐 Environment: ${process.env.NODE_ENV || 'development'}            ║
║   📊 API Health: http://localhost:${PORT}/api/health     ║
║   🎯 Admin Dashboard: http://localhost:${PORT}/admin    ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
    `);
    
    // Run migrations automatically
    await checkAndApplyMigrations();
});

module.exports = app;
