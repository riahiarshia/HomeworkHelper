import Foundation
import UIKit

// Azure Key Vault Configuration
struct AzureKeyVaultConfig {
    let keyVaultName: String
    let tenantId: String
    let clientId: String
    let secretName: String
    
    var keyVaultURL: String {
        "https://\(keyVaultName).vault.azure.net"
    }
    
    // Load configuration from Info.plist
    static func loadFromPlist() -> AzureKeyVaultConfig? {
        guard let keyVaultName = Bundle.main.object(forInfoDictionaryKey: "AzureKeyVaultName") as? String,
              let tenantId = Bundle.main.object(forInfoDictionaryKey: "AzureTenantId") as? String,
              let clientId = Bundle.main.object(forInfoDictionaryKey: "AzureClientId") as? String,
              let secretName = Bundle.main.object(forInfoDictionaryKey: "AzureSecretName") as? String,
              !keyVaultName.isEmpty,
              !tenantId.isEmpty,
              !clientId.isEmpty else {
            return nil
        }
        
        return AzureKeyVaultConfig(
            keyVaultName: keyVaultName,
            tenantId: tenantId,
            clientId: clientId,
            secretName: secretName
        )
    }
}

class AzureKeyVaultService {
    static let shared = AzureKeyVaultService()
    
    private let config: AzureKeyVaultConfig?
    private let keychain = KeychainHelper.shared
    private let clientSecretKeychainKey = "AzureClientSecret"
    
    // Cache for the API key to avoid repeated Azure calls
    private var cachedAPIKey: String?
    private var cacheTimestamp: Date?
    private let cacheValidityDuration: TimeInterval = 3600 // 1 hour
    
    private init() {
        self.config = AzureKeyVaultConfig.loadFromPlist()
        
        // Device-specific debugging
        print("🔍 DEBUG AzureKeyVaultService init:")
        print("   Device: \(UIDevice.current.model)")
        print("   iOS Version: \(UIDevice.current.systemVersion)")
        print("   Configuration loaded: \(config != nil)")
        
        // Pre-configure client secret for seamless App Store experience
        // This allows Azure Key Vault to work automatically without user setup
        if config != nil && getClientSecret() == nil {
            // Note: Client secret should be set via setClientSecret() method
            // For production, use setClientSecret() with the actual secret
            print("🔍 DEBUG AzureKeyVaultService: Client secret should be configured via setClientSecret() method")
        }
        
        if let config = config {
            print("🔍 DEBUG AzureKeyVaultService: Configuration details:")
            print("   Key Vault Name: \(config.keyVaultName)")
            print("   Tenant ID: \(config.tenantId)")
            print("   Client ID: \(config.clientId)")
            print("   Secret Name: \(config.secretName)")
        } else {
            print("❌ DEBUG AzureKeyVaultService: No Azure configuration found")
        }
    }
    
    // Set the Azure client secret (should be called once during app setup)
    func setClientSecret(_ secret: String) {
        _ = keychain.save(secret, forKey: clientSecretKeychainKey)
    }
    
    // Get the Azure client secret from keychain
    private func getClientSecret() -> String? {
        return keychain.load(forKey: clientSecretKeychainKey)
    }
    
    // Check if Azure Key Vault is configured
    func isConfigured() -> Bool {
        guard config != nil else { return false }
        guard let clientSecret = getClientSecret(), !clientSecret.isEmpty else { return false }
        return true
    }
    
    // Fetch OpenAI API key from Azure Key Vault
    func fetchAPIKey() async throws -> String {
        print("🔍 DEBUG AzureKeyVaultService.fetchAPIKey:")
        
        // Return cached key if still valid
        if let cached = cachedAPIKey,
           let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) < cacheValidityDuration {
            print("🔍 DEBUG AzureKeyVaultService: Using cached API key")
            return cached
        }
        
        print("🔍 DEBUG AzureKeyVaultService: Cache miss or expired, fetching from Azure")
        
        guard let config = config else {
            print("❌ DEBUG AzureKeyVaultService: Configuration not found")
            throw AzureKeyVaultError.notConfigured
        }
        
        print("🔍 DEBUG AzureKeyVaultService: Configuration found:")
        print("   Key Vault Name: \(config.keyVaultName)")
        print("   Tenant ID: \(config.tenantId)")
        print("   Client ID: \(config.clientId)")
        print("   Secret Name: \(config.secretName)")
        
        guard let clientSecret = getClientSecret(), !clientSecret.isEmpty else {
            print("❌ DEBUG AzureKeyVaultService: Client secret missing or empty")
            throw AzureKeyVaultError.clientSecretMissing
        }
        
        print("🔍 DEBUG AzureKeyVaultService: Client secret found, length: \(clientSecret.count)")
        
        // Step 1: Get Azure AD access token
        print("🔍 DEBUG AzureKeyVaultService: Getting access token...")
        let accessToken = try await getAccessToken(
            tenantId: config.tenantId,
            clientId: config.clientId,
            clientSecret: clientSecret
        )
        print("🔍 DEBUG AzureKeyVaultService: Access token received, length: \(accessToken.count)")
        
        // Step 2: Fetch secret from Key Vault
        print("🔍 DEBUG AzureKeyVaultService: Fetching secret from Key Vault...")
        let apiKey = try await getSecretFromKeyVault(
            keyVaultURL: config.keyVaultURL,
            secretName: config.secretName,
            accessToken: accessToken
        )
        print("🔍 DEBUG AzureKeyVaultService: API key received, length: \(apiKey.count)")
        
        // Cache the result
        cachedAPIKey = apiKey
        cacheTimestamp = Date()
        print("🔍 DEBUG AzureKeyVaultService: API key cached successfully")
        
        return apiKey
    }
    
    // Clear cached API key (useful for forcing refresh)
    func clearCache() {
        cachedAPIKey = nil
        cacheTimestamp = nil
    }
    
    // MARK: - Private Methods
    
    private func getAccessToken(tenantId: String, clientId: String, clientSecret: String) async throws -> String {
        let tokenURL = URL(string: "https://login.microsoftonline.com/\(tenantId)/oauth2/v2.0/token")!
        
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParameters = [
            "grant_type": "client_credentials",
            "client_id": clientId,
            "client_secret": clientSecret,
            "scope": "https://vault.azure.net/.default"
        ]
        
        let bodyString = bodyParameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AzureKeyVaultError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AzureKeyVaultError.authenticationFailed(message: errorMessage)
        }
        
        struct TokenResponse: Codable {
            let access_token: String
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        return tokenResponse.access_token
    }
    
    private func getSecretFromKeyVault(keyVaultURL: String, secretName: String, accessToken: String) async throws -> String {
        // Azure Key Vault API version
        let apiVersion = "7.4"
        let secretURL = URL(string: "\(keyVaultURL)/secrets/\(secretName)?api-version=\(apiVersion)")!
        
        var request = URLRequest(url: secretURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AzureKeyVaultError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AzureKeyVaultError.secretFetchFailed(message: errorMessage)
        }
        
        struct SecretResponse: Codable {
            let value: String
        }
        
        let secretResponse = try JSONDecoder().decode(SecretResponse.self, from: data)
        return secretResponse.value
    }
}

// MARK: - Error Types

enum AzureKeyVaultError: LocalizedError {
    case notConfigured
    case clientSecretMissing
    case invalidResponse
    case authenticationFailed(message: String)
    case secretFetchFailed(message: String)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Azure Key Vault is not configured. Please check Info.plist settings."
        case .clientSecretMissing:
            return "Azure client secret is missing. Please configure it in Settings."
        case .invalidResponse:
            return "Invalid response from Azure."
        case .authenticationFailed(let message):
            return "Azure authentication failed: \(message)"
        case .secretFetchFailed(let message):
            return "Failed to fetch secret from Key Vault: \(message)"
        }
    }
}

