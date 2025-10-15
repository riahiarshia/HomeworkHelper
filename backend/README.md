# Homework Helper Backend API

A secure backend API that provides OpenAI integration through Azure Key Vault for the Homework Helper iOS app.

## 🏗️ Architecture

```
iOS App → Backend API → Azure Key Vault → OpenAI API
```

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- Azure Key Vault with OpenAI API key
- Azure App Registration with Key Vault access

### Installation

1. **Install dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Configure environment:**
   - Update `config.js` with your Azure credentials
   - Ensure your OpenAI API key is stored in Azure Key Vault

3. **Start the server:**
   ```bash
   npm start
   ```

   For development with auto-reload:
   ```bash
   npm run dev
   ```

### API Endpoints

#### Health Check
```
GET /health
```
Returns server status and version information.

#### Analyze Homework
```
POST /api/analyze
Content-Type: multipart/form-data

Body:
- image: (file) Homework image
- problemText: (string) Text description
- userGradeLevel: (string) Grade level
```

#### Generate Hint
```
POST /api/hint
Content-Type: application/json

Body:
{
  "step": { "question": "...", "options": [...] },
  "problemContext": "...",
  "userGradeLevel": "..."
}
```

#### Verify Answer
```
POST /api/verify
Content-Type: application/json

Body:
{
  "answer": "...",
  "step": { "question": "...", "correctAnswer": "..." },
  "problemContext": "...",
  "userGradeLevel": "..."
}
```

## 🔐 Security Features

- **Azure Key Vault Integration**: All secrets stored securely in Azure
- **Rate Limiting**: 100 requests per 15 minutes per IP
- **Input Validation**: File size limits and data validation
- **Error Handling**: Secure error messages without exposing internals
- **CORS Protection**: Configurable CORS policies

## 📊 Monitoring

The API includes comprehensive logging:
- Request/response logging
- Azure Key Vault access logging
- OpenAI API usage tracking
- Error monitoring and alerting

## 🚀 Deployment Options

### Option 1: Azure App Service
```bash
# Deploy to Azure App Service
az webapp up --name homework-helper-api --resource-group your-rg
```

### Option 2: Azure Container Instances
```bash
# Build and deploy container
docker build -t homework-helper-api .
az container create --resource-group your-rg --name homework-api --image homework-helper-api
```

### Option 3: Azure Functions
```bash
# Deploy as serverless functions
func azure functionapp publish homework-helper-api
```

### Option 4: Traditional Hosting
```bash
# Deploy to any Node.js hosting service
npm install --production
pm2 start server.js --name homework-api
```

## 🔧 Configuration

### Azure Key Vault Setup
1. Create Key Vault in Azure Portal
2. Store OpenAI API key as secret named `OpenAI-API-Key`
3. Create App Registration with Key Vault access
4. Update config.js with your credentials

### Environment Variables
```bash
# Azure Configuration
AZURE_KEY_VAULT_NAME=your-keyvault-name
AZURE_TENANT_ID=your-tenant-id
AZURE_CLIENT_ID=your-client-id
AZURE_CLIENT_SECRET=your-client-secret

# Server Configuration
PORT=3000
NODE_ENV=production

# Security
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

## 🧪 Testing

### Health Check
```bash
curl http://localhost:3000/health
```

### Test Homework Analysis
```bash
curl -X POST http://localhost:3000/api/analyze \
  -F "image=@homework.jpg" \
  -F "userGradeLevel=elementary"
```

## 📈 Scaling

### Horizontal Scaling
- Deploy multiple instances behind load balancer
- Use Redis for session storage
- Implement connection pooling

### Performance Optimization
- Enable gzip compression
- Implement response caching
- Use CDN for static assets

## 🔒 Security Checklist

- [ ] Azure Key Vault properly configured
- [ ] Rate limiting enabled
- [ ] Input validation implemented
- [ ] Error handling secure
- [ ] CORS policies configured
- [ ] HTTPS enforced
- [ ] API key rotation plan
- [ ] Monitoring and alerting set up

## 🐛 Troubleshooting

### Common Issues

**Azure Key Vault Access Denied:**
- Check App Registration permissions
- Verify Key Vault access policies
- Ensure client secret is valid

**OpenAI API Errors:**
- Verify API key is valid and has credits
- Check rate limits and quotas
- Monitor API usage in OpenAI dashboard

**File Upload Issues:**
- Check file size limits (10MB max)
- Verify multipart/form-data encoding
- Ensure proper Content-Type headers

## 📞 Support

For issues or questions:
- Email: homework@arshia.com
- Check logs for detailed error information
- Monitor Azure Key Vault access logs

---

**Version:** 1.0.0  
**Last Updated:** 2024  
**License:** MIT
