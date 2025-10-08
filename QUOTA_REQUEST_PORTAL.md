# Azure Quota Increase Request - Portal Guide

## 🚨 Current Status
- **East US**: 0 Free VMs, 0 Basic VMs
- **All regions checked**: No available quota
- **Solution**: Manual quota request via Azure Portal

## 🎯 Step-by-Step Portal Request

### Step 1: Access Azure Portal
1. **Go to**: https://portal.azure.com
2. **Sign in** with your Azure account
3. **Navigate to**: Subscriptions → Azure subscription 1

### Step 2: Create Support Request
1. **Click**: Support + troubleshooting → New support request
2. **Select**: Technical → Quota → Compute
3. **Click**: Next

### Step 3: Fill Out Request Form

#### Problem Details:
- **Subscription**: Azure subscription 1 (f4eeb4ad-0461-480f-a5cf-5dff05e536b5)
- **Service type**: Compute
- **Problem type**: Quota
- **Problem subtype**: Basic VMs or Free VMs
- **Location**: East US
- **New quota limit**: 10

#### Business Justification:
```
Development of Homework Helper educational app using Azure App Service.
Need quota for creating web applications to serve API endpoints for
homework analysis functionality. This is for educational purposes and
will help students learn mathematics and science concepts.

The application provides AI-powered homework assistance for students.
We need reliable compute resources to serve API endpoints that analyze
homework images and provide step-by-step guidance. This supports
educational technology initiatives.
```

#### Contact Information:
- **First name**: Homework
- **Last name**: Helper
- **Email**: homework@arshia.com
- **Preferred contact method**: Email
- **Country**: United States
- **Preferred support language**: English
- **Time zone**: Pacific Standard Time

#### Priority:
- **Severity**: C - Minimal impact
- **Priority**: Normal

### Step 4: Submit Request
1. **Review** all details
2. **Click**: Create
3. **Note**: You'll receive a support ticket number

## 📋 Request Details Summary

### For Free VMs (Development):
- **Service**: Compute
- **Quota type**: Free VMs
- **Location**: East US
- **Current limit**: 0
- **Requested limit**: 10
- **Justification**: Educational app development

### For Basic VMs (Production):
- **Service**: Compute
- **Quota type**: Basic VMs
- **Location**: East US
- **Current limit**: 0
- **Requested limit**: 10
- **Justification**: Production deployment of educational app

## ⏰ Timeline Expectations

| Priority | Expected Approval Time |
|----------|----------------------|
| Normal | 1-2 business days |
| High | 4-8 hours |
| Emergency | 1-2 hours |

## 🔍 Monitor Request Status

### Check Status:
1. **Go to**: Support + troubleshooting → All support requests
2. **Find**: Your quota increase request
3. **Check**: Status updates and responses

### Portal Links:
- **Support Center**: https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade
- **All Support Requests**: https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/newsupportrequest
- **Usage + Quotas**: https://portal.azure.com/#blade/Microsoft_Azure_Billing/UsageAndQuotasBlade

## 🚀 After Approval

Once quota is approved:
1. **Run setup**: `./setup-azure-backend.sh`
2. **Deploy**: `./deploy-to-azure.sh`
3. **Test**: `curl https://homework-helper-api-f.azurewebsites.net/health`

## 🔧 Alternative: Different Region

If East US approval is slow, try these regions:
- **West US 2** (often faster approval)
- **Central US**
- **North Europe**
- **West Europe**

### To use different region:
```bash
# Update setup script for new region
sed -i.bak 's/eastus/westus2/g' setup-azure-backend.sh

# Run setup with new region
./setup-azure-backend.sh
```

## 📞 Support Contacts

- **Azure Portal**: https://portal.azure.com
- **Support Documentation**: https://docs.microsoft.com/en-us/azure/azure-supportability/regional-quota-requests
- **Contact Email**: homework@arshia.com

## 💡 Tips

1. **Start with Free VM quota** - easier to get approved
2. **Request 10 units** - gives you room to grow
3. **Use educational justification** - often gets faster approval
4. **Try multiple regions** - some have higher quotas
5. **Check existing quotas** - you might already have some in other regions

## 🎯 Quick Commands

```bash
# Check current quota status
./check-quota-status.sh

# Check support ticket status
./check-tickets.sh

# Try different region
az vm list-usage --location westus2 --output table
```

---

**Next Step**: Go to Azure Portal and submit the quota increase request as described above. This is the fastest way to resolve your quota issue.
