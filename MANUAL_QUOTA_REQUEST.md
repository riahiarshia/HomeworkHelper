# Manual Azure Quota Increase Request

## 🚨 Current Issue
Your Azure subscription has **0 quota** for both Basic and Free VMs, which prevents creating any App Service resources.

## 🎯 Solution: Request Quota Increase

### Step 1: Go to Azure Portal
1. Open: https://portal.azure.com
2. Sign in with your Azure account
3. Navigate to: **Subscriptions** → **Azure subscription 1**

### Step 2: Access Usage + Quotas
1. In the left sidebar, click **Usage + quotas**
2. This will show all your current quota limits

### Step 3: Request Quota Increase
1. **Search for**: `Free` or `Basic` in the filter box
2. **Select**: The quota you want to increase:
   - **Free VMs** (recommended for development)
   - **Basic VMs** (for production)
3. **Click**: **Request increase** button

### Step 4: Fill Out the Request Form

#### For Free VMs (Recommended for Development):
- **Subscription**: Azure subscription 1
- **Service type**: Compute
- **Location**: East US
- **New quota limit**: 10
- **Business justification**: 
  ```
  Development of Homework Helper educational app using Azure App Service. 
  Need quota for creating web applications to serve API endpoints for 
  homework analysis functionality. This is for educational purposes and 
  will help students learn mathematics and science concepts.
  ```
- **Priority**: Normal
- **Contact email**: homework@arshia.com

#### For Basic VMs (Production):
- **Subscription**: Azure subscription 1
- **Service type**: Compute
- **Location**: East US
- **New quota limit**: 10
- **Business justification**:
  ```
  Production deployment of Homework Helper educational app. The application 
  provides AI-powered homework assistance for students. We need reliable 
  compute resources to serve API endpoints that analyze homework images and 
  provide step-by-step guidance. This supports educational technology 
  initiatives.
  ```
- **Priority**: Normal
- **Contact email**: homework@arshia.com

### Step 5: Submit the Request
1. **Review** all details
2. **Click**: **Submit**
3. **Note**: You'll receive a support ticket number

## ⏰ Timeline Expectations

| Priority | Expected Approval Time |
|----------|----------------------|
| Normal | 1-2 business days |
| High | 4-8 hours |
| Emergency | 1-2 hours |

## 📋 Alternative: Use Different Region

If East US has quota issues, try these regions:
- **West US 2** (often has higher quotas)
- **Central US**
- **North Europe**
- **West Europe**

### To try different region:
```bash
# Update the setup script
sed -i.bak 's/eastus/westus2/g' setup-azure-backend.sh

# Run setup with new region
./setup-azure-backend.sh
```

## 🔍 Check Request Status

After submitting:
1. Go to **Support + troubleshooting** → **New support request**
2. Click **All support requests**
3. Find your quota increase request
4. Check status updates

## 🚀 Once Approved

After quota is approved:
1. **Run setup script**: `./setup-azure-backend.sh`
2. **Deploy backend**: `./deploy-to-azure.sh`
3. **Test deployment**: `curl https://homework-helper-api-f.azurewebsites.net/health`

## 📞 Support Contacts

If you need help:
- **Azure Portal**: https://portal.azure.com
- **Support Center**: https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade
- **Documentation**: https://docs.microsoft.com/en-us/azure/azure-supportability/regional-quota-requests

## 💡 Tips

1. **Start with Free VM quota** - easier to get approved
2. **Request 10 units** - gives you room to grow
3. **Use educational justification** - often gets faster approval
4. **Try multiple regions** - some have higher quotas
5. **Check existing quotas** - you might already have some in other regions

## 🔧 Quick Commands

```bash
# Check current quota status
az vm list-usage --location eastus --output table

# Try different region
az vm list-usage --location westus2 --output table

# Check all regions for available quota
for region in eastus westus2 centralus northeurope westeurope; do
  echo "=== $region ==="
  az vm list-usage --location $region --query "[?contains(name.value, 'Free') || contains(name.value, 'Basic')].{Name:name.value, Current:currentValue, Limit:limit}" --output table
done
```

---

**Next Step**: Go to Azure Portal and submit the quota increase request as described above. This is the fastest way to resolve your quota issue.
