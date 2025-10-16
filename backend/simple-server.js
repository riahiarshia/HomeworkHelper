/**
 * Minimal test server to isolate startup issues
 */

console.log('🚀 Starting minimal test server...');

const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

// Basic middleware
app.use(express.json());

// Simple health endpoint
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        message: 'Minimal server is working',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development'
    });
});

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'Homework Helper Minimal Server',
        status: 'running',
        endpoints: ['/api/health']
    });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ Minimal server running on port ${PORT}`);
    console.log(`🌐 Health check: http://0.0.0.0:${PORT}/api/health`);
});

// Handle errors
process.on('uncaughtException', (error) => {
    console.error('❌ Uncaught Exception:', error);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
});

module.exports = app;
