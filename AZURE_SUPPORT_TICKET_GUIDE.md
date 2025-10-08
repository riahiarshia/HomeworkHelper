# Azure Support Ticket Guide - Homework Helper

## 🎯 Objective
Request quota increase for **Standard A0-A7 Family vCPUs** to enable Azure App Service deployment.

## 🚨 Current Issue
- **Location**: East US
- **Current Limit**: 0 Standard A0-A7 Family vCPUs
- **Required**: 10 Standard A0-A7 Family vCPUs
- **Purpose**: Azure App Service hosting for Homework Helper API

## 🔗 Quick Access
- **Support Ticket URL**: https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/newsupportrequest
- **Open Browser**: Run `./open-support-ticket.sh`

## 📝 Step-by-Step Instructions

### Step 1: Access Support Portal
1. Go to: https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/newsupportrequest
2. Sign in with your Azure account

### Step 2: Select Problem Type
1. **Problem type**: Technical
2. **Service**: Compute
3. **Problem subtype**: Quota
4. **Quota type**: Standard A0-A7 Family vCPUs

### Step 3: Fill Basic Information
- **Subscription**: Azure subscription 1
- **Service type**: Compute
- **Problem type**: Quota
- **Problem subtype**: Standard A0-A7 Family vCPUs
- **Location**: East US
- **New quota limit**: 10

### Step 4: Contact Information
- **First name**: Homework
- **Last name**: Helper
- **Email**: homework@arshia.com
- **Preferred contact method**: Email
- **Country**: United States
- **Preferred support language**: English
- **Time zone**: Pacific Standard Time

### Step 5: Business Justification
Copy and paste this text:

```
Development of Homework Helper educational app using Azure App Service.
Need Standard A0-A7 Family vCPU quota to create App Service resources
for serving API endpoints that analyze homework images and provide
step-by-step guidance for students. This is for educational purposes
and will help students learn mathematics and science concepts.
```

### Step 6: Priority Settings
- **Severity**: C - Minimal impact
- **Priority**: Normal

### Step 7: Submit Request
1. Review all information
2. Click **Create**
3. Note the support ticket number

## ⏰ Timeline
- **Normal priority**: 1-2 business days
- **High priority**: 4-8 hours
- **Emergency**: 1-2 hours

## 🔍 Monitor Progress
1. Go to: Support + troubleshooting → All support requests
2. Find your quota increase request
3. Check status updates

## 🚀 After Approval
Once quota is approved:
1. Run: `./setup-azure-backend.sh`
2. Deploy: `./deploy-to-azure.sh`
3. Test: `curl https://homework-helper-api-f.azurewebsites.net/health`

## 📞 Support Contacts
- **Azure Portal**: https://portal.azure.com
- **Support Center**: https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade
- **Email**: homework@arshia.com

## 💡 Tips
1. **Start with Standard A0-A7 Family** - this is what App Service needs
2. **Request 10 units** - gives you room to grow
3. **Use educational justification** - often gets faster approval
4. **Check status regularly** - approval can be quick

## 🔧 Alternative Quota Types
If Standard A0-A7 Family is not available, also request:
- **Basic A Family vCPUs**: Alternative for Basic tier
- **Standard A0-A7 Family vCPUs**: Primary requirement

## 📋 Files Created
- `support-ticket-template.txt` - Complete form details
- `open-support-ticket.sh` - Browser launcher
- `AZURE_SUPPORT_TICKET_GUIDE.md` - This guide
