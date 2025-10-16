const express = require('express');
const router = express.Router();
const config = require('../config');
const azureService = require('../services/azureService');
const { Pool } = require('pg');

// Basic health check
router.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        environment: config.environment
    });
});

// Comprehensive health check with all services
router.get('/health/detailed', async (req, res) => {
    const health = {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        environment: config.environment,
        services: {}
    };

    try {
        // 1. Check OpenAI Configuration
        try {
            const apiKey = await azureService.getOpenAIKey();
            const keySource = config.openai.apiKey ? 'environment_variable' : 'azure_key_vault';
            const keyPreview = apiKey ? `${apiKey.substring(0, 10)}...` : 'not found';
            
            health.services.openai = {
                status: 'healthy',
                source: keySource,
                key_preview: keyPreview,
                configured: true
            };
        } catch (error) {
            health.status = 'unhealthy';
            health.services.openai = {
                status: 'unhealthy',
                error: error.message,
                configured: false
            };
        }

        // 2. Check Database Connection
        try {
            const pool = new Pool({
                connectionString: config.database.url || 
                    `postgresql://${config.database.user}:${config.database.password}@${config.database.host}:${config.database.port}/${config.database.database}`,
                ssl: config.database.ssl
            });
            
            const result = await pool.query('SELECT NOW()');
            await pool.end();
            
            health.services.database = {
                status: 'healthy',
                connected: true,
                timestamp: result.rows[0].now
            };
        } catch (error) {
            health.status = 'unhealthy';
            health.services.database = {
                status: 'unhealthy',
                error: error.message,
                connected: false
            };
        }

        // 3. Check Azure Key Vault (if configured)
        if (config.azure.enabled) {
            const vaultHealth = await azureService.healthCheck();
            health.services.azure_key_vault = vaultHealth;
            
            if (vaultHealth.status === 'unhealthy') {
                health.status = 'degraded'; // Still works if direct key is available
            }
        } else {
            health.services.azure_key_vault = {
                status: 'not_configured',
                message: 'Using direct API keys from environment variables'
            };
        }

        // 4. Configuration Summary
        health.configuration = {
            environment: config.environment,
            is_development: config.isDevelopment,
            is_staging: config.isStaging,
            is_production: config.isProduction,
            openai_key_source: config.openai.apiKey ? 'direct' : 'key_vault',
            azure_key_vault_enabled: config.azure.enabled,
            debug_mode: config.logging.debug
        };

        res.json(health);
        
    } catch (error) {
        res.status(500).json({
            status: 'error',
            timestamp: new Date().toISOString(),
            error: error.message
        });
    }
});

module.exports = router;
