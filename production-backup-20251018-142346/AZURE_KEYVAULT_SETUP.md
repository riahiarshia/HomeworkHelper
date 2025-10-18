# Azure Key Vault Setup Guide for iOS App

This guide will walk you through setting up Azure Key Vault to securely manage your OpenAI API key.

## Prerequisites
- Azure subscription (create free account at https://azure.microsoft.com/free/)
- Azure CLI installed (optional but recommended)
- Your OpenAI API key

---

## Step 1: Create Azure Key Vault (Azure Portal)

### Option A: Using Azure Portal (Recommended for beginners)

1. **Sign in to Azure Portal**
   - Go to https://portal.azure.com
   - Sign in with your Microsoft account

2. **Create a Key Vault**
   - Click "Create a resource" (+ icon in top left)
   - Search for "Key Vault"
   - Click "Create"

3. **Configure Basic Settings**
   - **Subscription**: Select your subscription
   - **Resource Group**: Create new or select existing (e.g., "homework-helper-rg")
   - **Key Vault Name**: Choose a unique name (e.g., "homework-helper-kv-123")
     - Must be globally unique
     - 3-24 characters, alphanumeric and hyphens only
   - **Region**: Choose closest region (e.g., "East US")
   - **Pricing Tier**: Standard (sufficient for this use case)

4. **Access Configuration**
   - Click "Next: Access Policy"
   - Keep "Vault access policy" selected
   - Click "Add Access Policy"
     - **Secret permissions**: Select "Get" and "List"
     - **Select principal**: Click, search for your email/account, select it
     - Click "Add"
   - Click "Review + Create"
   - Click "Create"

5. **Wait for Deployment**
   - Takes 1-2 minutes
   - Click "Go to resource" when complete

### Option B: Using Azure CLI

```bash
# Login to Azure
az login

# Create resource group
az group create --name homework-helper-rg --location eastus

# Create Key Vault
az keyvault create \
  --name homework-helper-kv-123 \
  --resource-group homework-helper-rg \
  --location eastus

# Grant yourself access
az keyvault set-policy \
  --name homework-helper-kv-123 \
  --upn YOUR_EMAIL@example.com \
  --secret-permissions get list
```

---

## Step 2: Store the OpenAI API Key

### Using Azure Portal

1. **Navigate to your Key Vault**
   - In Azure Portal, go to "All resources"
   - Click on your Key Vault (e.g., "homework-helper-kv-123")

2. **Add Secret**
   - In left menu, click "Secrets" (under Settings)
   - Click "+ Generate/Import"
   - **Upload options**: Manual
   - **Name**: `OpenAI-API-Key` (use this exact name)
   - **Value**: Paste your OpenAI API key (starts with sk-...)
   - Leave other options as default
   - Click "Create"

3. **Note the Secret Identifier**
   - Click on your newly created secret
   - Click on the current version
   - Copy the "Secret Identifier" URL
   - Format: `https://homework-helper-kv-123.vault.azure.net/secrets/OpenAI-API-Key/{version}`

### Using Azure CLI

```bash
# Store the secret
az keyvault secret set \
  --vault-name homework-helper-kv-123 \
  --name OpenAI-API-Key \
  --value "sk-proj-YOUR-OPENAI-KEY-HERE"
```

---

## Step 3: Create App Registration (for authentication)

Your iOS app needs to authenticate with Azure to access the Key Vault.

### Using Azure Portal

1. **Go to Azure Active Directory**
   - Search for "Azure Active Directory" in top search bar
   - Click on it

2. **Register New Application**
   - Click "App registrations" in left menu
   - Click "+ New registration"
   - **Name**: "HomeworkHelper-iOS"
   - **Supported account types**: "Accounts in this organizational directory only"
   - **Redirect URI**: Leave blank for now
   - Click "Register"

3. **Note Important Values**
   - On the Overview page, copy these values:
     - **Application (client) ID**: e.g., `12345678-1234-1234-1234-123456789abc`
     - **Directory (tenant) ID**: e.g., `87654321-4321-4321-4321-cba987654321`

4. **Create Client Secret**
   - Click "Certificates & secrets" in left menu
   - Click "+ New client secret"
   - **Description**: "iOS App Secret"
   - **Expires**: Choose duration (recommend 24 months)
   - Click "Add"
   - **IMPORTANT**: Copy the "Value" immediately (you won't see it again!)
   - Save this as your **Client Secret**

5. **Grant Key Vault Access**
   - Go back to your Key Vault resource
   - Click "Access policies" in left menu
   - Click "+ Add Access Policy"
   - **Secret permissions**: Select "Get" and "List"
   - **Select principal**: Search for "HomeworkHelper-iOS", select it
   - Click "Add"
   - Click "Save" (important!)

### Using Azure CLI

```bash
# Create app registration
az ad app create --display-name HomeworkHelper-iOS

# Note the appId from output, then create service principal
az ad sp create --id YOUR_APP_ID

# Create client secret
az ad app credential reset --id YOUR_APP_ID

# Grant Key Vault access
az keyvault set-policy \
  --name homework-helper-kv-123 \
  --spn YOUR_APP_ID \
  --secret-permissions get list
```

---

## Step 4: Configure iOS App

You'll need these values for the iOS app configuration:

1. ✅ **Key Vault Name**: `homework-helper-kv-123`
2. ✅ **Key Vault URL**: `https://homework-helper-kv-123.vault.azure.net/`
3. ✅ **Tenant ID**: `87654321-4321-4321-4321-cba987654321`
4. ✅ **Client ID**: `12345678-1234-1234-1234-123456789abc`
5. ✅ **Client Secret**: `abc123...xyz` (from step 3.4)
6. ✅ **Secret Name**: `OpenAI-API-Key`

**IMPORTANT SECURITY NOTE**: 
- Store Client ID and Tenant ID in the app (these are okay to be in code)
- The Client Secret should ideally be in a backend service, but for this iOS app, we'll use Keychain
- Never commit secrets to git!

---

## Step 5: Update iOS App Code

The code changes will be implemented in the next steps:
- Create `AzureKeyVaultService.swift` to handle Azure authentication and key retrieval
- Update `OpenAIService.swift` to use Azure Key Vault
- Add Azure configuration to `Info.plist`
- Remove hardcoded API key

---

## Step 6: Test the Setup

1. **Verify Key Vault Access**
   - In Azure Portal, go to your Key Vault
   - Click "Secrets"
   - Verify you can see "OpenAI-API-Key"

2. **Verify App Registration**
   - Go to Azure Active Directory > App registrations
   - Find "HomeworkHelper-iOS"
   - Verify it exists and has a client secret

3. **Verify Access Policy**
   - In Key Vault, click "Access policies"
   - Verify "HomeworkHelper-iOS" has Get and List permissions

---

## Security Best Practices

✅ **DO**:
- Use separate Key Vaults for dev/staging/production
- Rotate secrets regularly (every 6-12 months)
- Use managed identities when possible
- Monitor Key Vault access logs
- Keep client secrets in Keychain, never in code

❌ **DON'T**:
- Commit secrets to git
- Share secrets in plain text
- Use the same secrets across environments
- Grant more permissions than needed

---

## Troubleshooting

### "Access Denied" Error
- Verify the app registration has access policy in Key Vault
- Check that you saved the access policy changes
- Verify client secret hasn't expired

### "Secret Not Found"
- Check the secret name matches exactly (case-sensitive)
- Verify the secret was created successfully

### "Authentication Failed"
- Verify Tenant ID and Client ID are correct
- Check that client secret is valid and not expired
- Ensure app registration is in the same tenant as Key Vault

---

## Cost Estimate

Azure Key Vault costs approximately:
- **Standard Tier**: $0.03 per 10,000 operations
- **Secret Storage**: First 10,000 secrets free
- **Estimated monthly cost for this app**: < $1

---

## Next Steps

Once you've completed the Azure setup, we'll:
1. Add Azure SDK dependencies to the iOS project
2. Implement the Key Vault service
3. Update the OpenAI service to fetch the key
4. Remove the hardcoded API key
5. Test the integration

