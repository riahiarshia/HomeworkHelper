const { SecretClient } = require('@azure/keyvault-secrets');
const { ClientSecretCredential } = require('@azure/identity');
const config = require('../config');

class AzureService {
  constructor() {
    this.client = null;
    this.credential = null;
    this.openaiKey = null;
    this.keyCacheTimestamp = null;
    this.cacheValidityDuration = 3600000; // 1 hour in milliseconds
  }

  async initialize() {
    if (this.client) return; // Already initialized

    try {
      // Create credentials
      this.credential = new ClientSecretCredential(
        config.azure.tenantId,
        config.azure.clientId,
        config.azure.clientSecret
      );

      // Create Key Vault client
      const keyVaultUrl = `https://${config.azure.keyVaultName}.vault.azure.net`;
      this.client = new SecretClient(keyVaultUrl, this.credential);

      console.log('✅ Azure Key Vault client initialized');
    } catch (error) {
      console.error('❌ Failed to initialize Azure Key Vault client:', error.message);
      throw new Error('Azure Key Vault initialization failed');
    }
  }

  async getOpenAIKey() {
    try {
      // SMART KEY RETRIEVAL:
      // 1. If direct API key is in environment (.env.development), use that (for dev/staging)
      // 2. Otherwise, fetch from Azure Key Vault (for production)
      
      if (config.openai.apiKey) {
        console.log(`🔑 Using OpenAI API key from environment variables (${config.environment})`);
        return config.openai.apiKey;
      }
      
      // Only use Azure Key Vault if no direct key is available
      if (!config.azure.enabled) {
        throw new Error('No OpenAI API key configured. Please set OPENAI_API_KEY in environment variables or configure Azure Key Vault.');
      }

      // Check if we have a cached key that's still valid
      if (this.openaiKey && this.keyCacheTimestamp) {
        const now = new Date();
        const cacheAge = now - this.keyCacheTimestamp;
        
        if (cacheAge < this.cacheValidityDuration) {
          console.log('🔄 Using cached OpenAI API key from Azure Key Vault');
          return this.openaiKey;
        }
      }

      // Initialize client if needed
      await this.initialize();

      // Fetch the secret from Key Vault
      console.log('🔑 Fetching OpenAI API key from Azure Key Vault...');
      const secret = await this.client.getSecret(config.azure.openaiSecretName);
      
      if (!secret.value) {
        throw new Error('OpenAI API key not found in Key Vault');
      }

      // Cache the key
      this.openaiKey = secret.value;
      this.keyCacheTimestamp = new Date();

      console.log('✅ OpenAI API key retrieved from Azure Key Vault and cached');
      return this.openaiKey;

    } catch (error) {
      console.error('❌ Failed to get OpenAI API key:', error.message);
      throw new Error(`Failed to retrieve OpenAI API key: ${error.message}`);
    }
  }

  async refreshOpenAIKey() {
    // Clear cache to force refresh
    this.openaiKey = null;
    this.keyCacheTimestamp = null;
    
    console.log('🔄 Refreshing OpenAI API key...');
    return await this.getOpenAIKey();
  }

  // Health check for Azure Key Vault
  async healthCheck() {
    try {
      await this.getOpenAIKey(); // Uses smart retrieval
      return { 
        status: 'healthy', 
        message: `OpenAI API key available (source: ${config.openai.apiKey ? 'environment' : 'Azure Key Vault'})`,
        environment: config.environment
      };
    } catch (error) {
      return { 
        status: 'unhealthy', 
        message: error.message,
        environment: config.environment
      };
    }
  }
}

// Export singleton instance
module.exports = new AzureService();
