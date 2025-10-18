// Configuration for Homework Helper Backend API

module.exports = {
  // Azure Key Vault Configuration
  azure: {
    keyVaultName: process.env.AZURE_KEY_VAULT_NAME || 'OpenAI-1',
    tenantId: process.env.AZURE_TENANT_ID || 'c3b32785-891b-4be9-90c2-c6d313ab4895',
    clientId: process.env.AZURE_CLIENT_ID || '25c1dc23-3925-49f1-94d3-4e702da5fa9b',
    clientSecret: process.env.AZURE_CLIENT_SECRET || 'REPLACE_WITH_YOUR_CLIENT_SECRET',
    openaiSecretName: process.env.OPENAI_SECRET_NAME || 'OpenAi'
  },

  // Server Configuration
  server: {
    port: process.env.PORT || 3000,
    nodeEnv: process.env.NODE_ENV || 'development'
  },

  // Security Configuration
  security: {
    apiKeyHeader: process.env.API_KEY_HEADER || 'X-API-Key',
    rateLimitWindowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 900000, // 15 minutes
    rateLimitMaxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100
  },

  // OpenAI Configuration
  openai: {
    baseURL: 'https://api.openai.com/v1',
    // Model selection based on task type
    models: {
      // Image analysis - needs better vision capabilities
      imageAnalysis: 'gpt-4o-mini', // Better at understanding images
      // Chat interactions - can use cheaper model
      chat: 'gpt-4.1-mini', // Cost-effective for conversations
      // General homework analysis
      homework: 'gpt-4.1-mini', // Good balance for most tasks
      // Fallback model
      default: 'gpt-4.1-mini'
    },
    // Legacy single model (for backward compatibility)
    model: 'gpt-4.1-mini',
    maxTokens: 4000,
    temperature: 0.2
  }
};
