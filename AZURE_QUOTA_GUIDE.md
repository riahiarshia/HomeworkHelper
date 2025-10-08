# Azure Quota Management Guide

This guide helps you resolve Azure quota issues and provides multiple approaches to increase your quota limits.

## 🚨 Current Issue

**Error**: `Operation cannot be completed without additional quota`
- **Location**: East US
- **Current Limit**: 0 Basic VMs
- **Required**: 1 Basic VM
- **Minimum New Limit**: 1 Basic VM

## 🎯 Solution Options

### Option 1: Free Tier (Immediate - Recommended)

Use Azure's free tier to get started immediately without quota increases:

```bash
./request-azure-quota.sh
```

**Benefits**:
- ✅ No quota increase needed
- ✅ Immediate deployment
- ✅ Perfect for development/testing
- ✅ Can upgrade later

**Limitations**:
- 60 minutes CPU per day
- 1GB RAM
- No custom domain
- Apps sleep after 20 minutes inactivity

### Option 2: Quota Increase Request (1-2 days)

Request a formal quota increase through Azure support:

```bash
./request-quota-api.sh
```

**Benefits**:
- ✅ Full production capabilities
- ✅ No time restrictions
- ✅ Better performance
- ✅ Custom domains

**Process**:
1. Submit support ticket
2. Wait 1-2 business days for approval
3. Deploy with increased quota

### Option 3: Manual Portal Request (Alternative)

If automated scripts don't work, use Azure Portal:

1. **Go to Azure Portal**: https://portal.azure.com
2. **Navigate to**: Subscriptions → Your Subscription → Usage + quotas
3. **Search for**: "Basic" in the filter
4. **Select**: "Basic" quota for East US
5. **Click**: "Request increase"
6. **Enter details**:
   - New limit: 10 (recommended)
   - Business justification: "Development of Homework Helper educational app"
   - Priority: Normal
7. **Submit** the request

## 📊 Current Quota Status

Check your current quota limits:

```bash
./check-quota.sh
```

## 🚀 Quick Start (Free Tier)

Get started immediately with free tier:

```bash
# 1. Set up free tier resources
./request-azure-quota.sh

# 2. Deploy your app
./deploy-to-azure.sh

# 3. Test your deployment
curl https://homework-helper-free-api.azurewebsites.net/health
```

## 🔄 Upgrade Path

Once you have quota approval, upgrade to production tier:

```bash
# Upgrade App Service Plan
az appservice plan update \
  --name homework-helper-free-plan \
  --resource-group homework-helper-rg-f \
  --sku B1

# Update app configuration
az webapp config appsettings set \
  --name homework-helper-free-api \
  --resource-group homework-helper-rg-f \
  --settings WEBSITE_NODE_DEFAULT_VERSION=18.17.0
```

## 📋 Monitoring & Management

### Check Quota Status
```bash
./check-quota.sh
```

### Check Support Ticket Status
```bash
./check-ticket-status.sh
```

### View App Service Usage
```bash
az appservice plan list-usage \
  --name homework-helper-free-plan \
  --resource-group homework-helper-rg-f \
  --output table
```

## 💰 Cost Comparison

| Tier | Monthly Cost | CPU | RAM | Quota Required |
|------|-------------|-----|-----|----------------|
| Free | $0 | 60 min/day | 1GB | No |
| B1 | ~$13 | Unlimited | 1.75GB | Yes |
| S1 | ~$25 | Unlimited | 1.75GB | Yes |

## 🔧 Troubleshooting

### Common Issues

**1. Quota Still Insufficient**
```bash
# Check all quota limits
az vm list-usage --location eastus --output table

# Request specific quota
az support tickets create \
  --ticket-id "quota-increase-$(date +%s)" \
  --title "Quota Increase Request" \
  --description "Requesting Basic VM quota increase"
```

**2. Free Tier Not Available**
```bash
# Check if free tier is available
az appservice plan show \
  --name homework-helper-free-plan \
  --resource-group homework-helper-rg-f

# Try different region
az appservice plan create \
  --name homework-helper-free-plan \
  --resource-group homework-helper-rg-f \
  --location westus2 \
  --sku FREE
```

**3. Support Ticket Not Created**
- Use manual portal method (Option 3)
- Contact Azure support directly
- Try different subscription

## 📞 Support Contacts

- **Azure Portal**: https://portal.azure.com
- **Support Center**: https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade
- **Documentation**: https://docs.microsoft.com/en-us/azure/azure-supportability/regional-quota-requests

## 🎯 Recommended Workflow

1. **Start with Free Tier** (immediate)
   ```bash
   ./request-azure-quota.sh
   ```

2. **Request Quota Increase** (parallel)
   ```bash
   ./request-quota-api.sh
   ```

3. **Monitor Progress**
   ```bash
   ./check-quota.sh
   ./check-ticket-status.sh
   ```

4. **Upgrade When Ready**
   ```bash
   az appservice plan update --name homework-helper-free-plan --resource-group homework-helper-rg-f --sku B1
   ```

## 📝 Files Created

- `request-azure-quota.sh` - Free tier setup
- `request-quota-api.sh` - Quota increase request
- `check-quota.sh` - Quota status checker
- `check-ticket-status.sh` - Support ticket status
- `AZURE_QUOTA_GUIDE.md` - This guide

## 🚀 Next Steps

1. **Run free tier setup**: `./request-azure-quota.sh`
2. **Deploy your app**: `./deploy-to-azure.sh`
3. **Test deployment**: `curl https://homework-helper-free-api.azurewebsites.net/health`
4. **Monitor quota request**: `./check-ticket-status.sh`
5. **Upgrade when approved**: Use upgrade commands above

---

**Note**: Free tier is perfect for development and testing. You can always upgrade to production tier once your quota increase is approved.
