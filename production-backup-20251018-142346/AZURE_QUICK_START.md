# Azure Key Vault Quick Start

After completing the Azure setup (see `AZURE_KEYVAULT_SETUP.md`), follow these steps to configure the iOS app:

## Step 1: Update Info.plist

1. Open `HomeworkHelper/Info.plist` in Xcode
2. Find the Azure Key Vault Configuration section (near the bottom)
3. Uncomment the Azure configuration lines (remove `<!--` and `-->`)
4. Replace the placeholder values with your actual Azure values:

```xml
<key>AzureKeyVaultName</key>
<string>homework-helper-kv-123</string>  <!-- Your Key Vault name -->
<key>AzureTenantId</key>
<string>87654321-4321-4321-4321-cba987654321</string>  <!-- Your Tenant ID -->
<key>AzureClientId</key>
<string>12345678-1234-1234-1234-123456789abc</string>  <!-- Your Client ID -->
<key>AzureSecretName</key>
<string>OpenAI-API-Key</string>  <!-- Leave as-is unless you named it differently -->
```

## Step 2: Set Client Secret on First Launch

1. Build and run the app
2. Navigate to **Settings** tab
3. In the **Azure Client Secret** section, enter your Azure client secret
4. Tap **Update Client Secret**

**Important**: You only need to do this once. The client secret is stored securely in the device Keychain.

## Step 3: Verify Azure Integration

1. Still in Settings, you should see:
   - ✅ "Azure Key Vault Configured" badge
   - Status showing if the key was loaded successfully
   
2. If you see an error:
   - Check that Info.plist values are correct
   - Verify the client secret was entered correctly
   - Ensure your Azure app has access to the Key Vault (check Access Policies in Azure Portal)
   - Tap "Refresh from Azure" to retry

## Step 4: Test the App

1. Go to the **Home** tab
2. Upload a homework image
3. The app should process it normally using the API key from Azure

## Fallback Mode

If Azure Key Vault is not configured or unavailable, the app will:
- Show a message in Settings: "Azure Key Vault not configured. Using manual API key entry."
- Fall back to manual API key entry (the original behavior)
- Store the API key locally in Keychain

This ensures the app works even without Azure setup.

## Rotating Secrets

When you rotate your Azure client secret:

1. Generate a new client secret in Azure Portal
2. Open the app → Settings
3. Enter the new client secret
4. Tap "Update Client Secret"
5. Tap "Refresh from Azure" to test

## Troubleshooting

### "Azure Key Vault not configured"
- Verify Info.plist has been updated with your Azure values
- Make sure you saved the Info.plist file
- Restart the app

### "Client secret is missing"
- Go to Settings → Azure Client Secret
- Enter your client secret from Azure setup
- Tap "Update Client Secret"

### "Authentication failed"
- Verify Tenant ID and Client ID in Info.plist are correct
- Check that client secret hasn't expired in Azure Portal
- Ensure it's the correct secret (Value, not Secret ID)

### "Failed to fetch secret from Key Vault"
- Verify the app registration has access to the Key Vault
- Check Access Policies in Azure Portal
- Ensure you granted "Get" and "List" permissions
- Verify you clicked "Save" after adding the access policy

### "Secret not found"
- Check that `AzureSecretName` in Info.plist matches the secret name in Azure
- Default is "OpenAI-API-Key" (case-sensitive)

## Security Notes

✅ **What's safe in Info.plist:**
- Key Vault Name
- Tenant ID
- Client ID
- Secret Name

❌ **NEVER put in Info.plist or code:**
- Client Secret (use Settings to enter it)
- API Keys
- Any passwords or tokens

✅ **Where secrets are stored:**
- Client Secret: Device Keychain (encrypted)
- OpenAI API Key: Device Keychain (encrypted)
- Cached from Azure: App memory (cleared on app restart)

## Benefits of Azure Key Vault Integration

✅ **Centralized Management**: Update the API key once in Azure, all devices get the new key
✅ **Rotation**: Easily rotate API keys without updating the app
✅ **Security**: API key never stored in code or configuration files
✅ **Monitoring**: Azure logs all access attempts
✅ **Fallback**: App still works if Azure is unavailable (uses cached/manual key)

## Cost

With typical usage (a few API key fetches per day):
- **Estimated cost**: < $0.10/month
- **Free tier**: First 10,000 secret operations free

---

For detailed Azure setup instructions, see `AZURE_KEYVAULT_SETUP.md`

