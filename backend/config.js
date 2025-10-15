// Configuration for Homework Helper Backend API
// Supports multiple environments: development, staging, production

const env = process.env.NODE_ENV || 'development';

module.exports = {
  // Environment
  environment: env,
  isDevelopment: env === 'development',
  isStaging: env === 'staging',
  isProduction: env === 'production',

  // Server Configuration
  server: {
    port: process.env.PORT || 3000,
    nodeEnv: env,
    appUrl: process.env.APP_URL || 'http://localhost:3000'
  },

  // Database Configuration
  database: {
    // Support both individual params and DATABASE_URL
    url: process.env.DATABASE_URL,
    user: process.env.DB_USER || 'postgres',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'homework_helper_dev',
    password: process.env.DB_PASSWORD || '',
    port: parseInt(process.env.DB_PORT) || 5432,
    ssl: env === 'production' || env === 'staging' ? { rejectUnauthorized: false } : false
  },

  // JWT Configuration
  jwt: {
    secret: process.env.JWT_SECRET || 'dev-jwt-secret-change-in-production',
    adminSecret: process.env.ADMIN_JWT_SECRET || 'dev-admin-jwt-secret-change-in-production',
    expiresIn: '7d'
  },

  // OpenAI Configuration
  openai: {
    // Direct API key (preferred for dev/staging, or if not using Azure Key Vault)
    apiKey: process.env.OPENAI_API_KEY,
    orgId: process.env.OPENAI_ORG_ID,
    baseURL: 'https://api.openai.com/v1',
    
    // Model selection based on task type
    models: {
      // Image analysis - needs better vision capabilities
      imageAnalysis: process.env.OPENAI_MODEL_VISION || 'gpt-4o-mini',
      // Chat interactions - can use cheaper model
      chat: process.env.OPENAI_MODEL_CHAT || 'gpt-4o-mini',
      // General homework analysis
      homework: process.env.OPENAI_MODEL_HOMEWORK || 'gpt-4o-mini',
      // Fallback model
      default: process.env.OPENAI_MODEL_DEFAULT || 'gpt-4o-mini'
    },
    // Legacy single model (for backward compatibility)
    model: process.env.OPENAI_MODEL || 'gpt-4o-mini',
    maxTokens: parseInt(process.env.OPENAI_MAX_TOKENS) || 4000,
    temperature: parseFloat(process.env.OPENAI_TEMPERATURE) || 0.2
  },

  // Azure Key Vault Configuration (Optional - for production)
  // If configured, will fetch OpenAI key from Key Vault instead of env var
  azure: {
    enabled: !!process.env.AZURE_KEY_VAULT_NAME,
    keyVaultName: process.env.AZURE_KEY_VAULT_NAME,
    tenantId: process.env.AZURE_TENANT_ID,
    clientId: process.env.AZURE_CLIENT_ID,
    clientSecret: process.env.AZURE_CLIENT_SECRET,
    openaiSecretName: process.env.OPENAI_SECRET_NAME || 'OpenAI'
  },

  // Stripe Configuration
  stripe: {
    secretKey: process.env.STRIPE_SECRET_KEY,
    webhookSecret: process.env.STRIPE_WEBHOOK_SECRET,
    priceId: process.env.STRIPE_PRICE_ID,
    isTestMode: env !== 'production'
  },

  // Admin Configuration
  admin: {
    username: process.env.ADMIN_USERNAME || 'admin',
    password: process.env.ADMIN_PASSWORD,
    email: process.env.ADMIN_EMAIL || 'admin@localhost'
  },

  // Security Configuration
  security: {
    apiKeyHeader: process.env.API_KEY_HEADER || 'X-API-Key',
    rateLimitWindowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 900000, // 15 minutes
    rateLimitMaxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
    corsOrigins: process.env.CORS_ORIGINS ? process.env.CORS_ORIGINS.split(',') : '*'
  },

  // Logging Configuration
  logging: {
    level: process.env.LOG_LEVEL || (env === 'production' ? 'error' : 'debug'),
    debug: process.env.DEBUG === 'true' || env === 'development'
  }
};
