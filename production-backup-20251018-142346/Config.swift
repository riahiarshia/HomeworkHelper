//
//  Config.swift
//  HomeworkHelper
//
//  Environment Configuration
//  Manages API endpoints and settings across Development, Staging, and Production

import Foundation

enum AppEnvironment {
    case development
    case staging
    case production
    
    // MARK: - Current Environment
    // Change this to switch between environments
    static let current: AppEnvironment = .production
    
    // MARK: - Environment URLs
    var apiBaseURL: String {
        switch self {
        case .development:
            // Local development - backend running on your Mac
            return "http://10.253.17.4:3000"
            
        case .staging:
            // Azure staging environment for testing
            return "https://homework-helper-staging.azurewebsites.net"
            
        case .production:
            // Azure production environment
            return "https://homework-helper-api.azurewebsites.net"
        }
    }
    
    // MARK: - Environment Settings
    var displayName: String {
        switch self {
        case .development: return "Development"
        case .staging: return "Staging"
        case .production: return "Production"
        }
    }
    
    var isDebug: Bool {
        return self != .production
    }
    
    var logLevel: LogLevel {
        switch self {
        case .development: return .verbose
        case .staging: return .info
        case .production: return .error
        }
    }
    
    // MARK: - API Timeouts
    var requestTimeout: TimeInterval {
        switch self {
        case .development:
            return 300.0 // 5 minutes - longer for debugging
        case .staging, .production:
            return 240.0 // 4 minutes - increased for better reliability
        }
    }
    
    var resourceTimeout: TimeInterval {
        switch self {
        case .development:
            return 900.0 // 15 minutes - longer for debugging
        case .staging, .production:
            return 600.0 // 10 minutes - increased for better reliability
        }
    }
}

// MARK: - Log Levels
enum LogLevel: Int {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    
    var emoji: String {
        switch self {
        case .verbose: return "💬"
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

// MARK: - Global Config
struct Config {
    static let environment = AppEnvironment.current
    static let apiBaseURL = environment.apiBaseURL
    static let isDebug = environment.isDebug
    
    // MARK: - Logging
    static func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        guard level.rawValue >= environment.logLevel.rawValue else { return }
        
        let filename = (file as NSString).lastPathComponent
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        
        print("\(level.emoji) [\(timestamp)] [\(environment.displayName)] \(filename):\(line) \(function) - \(message)")
    }
    
    // MARK: - Feature Flags
    struct Features {
        // Enable/disable features based on environment
        static let enableAnalytics = environment == .production
        static let enableCrashReporting = environment != .development
        static let showDebugMenu = environment.isDebug
        static let mockPayments = environment == .development
        static let verboseLogging = environment == .development
    }
    
    // MARK: - API Configuration
    struct API {
        static let baseURL = Config.apiBaseURL
        static let requestTimeout = environment.requestTimeout
        static let resourceTimeout = environment.resourceTimeout
        
        // API Endpoints
        struct Endpoints {
            static let auth = "/api/auth"
            static let subscription = "/api/subscription"
            static let imageAnalysis = "/api/analyze-image"
            static let validateImage = "/api/validate-image"
            static let homework = "/api/homework"
            static let usage = "/api/usage"
            static let admin = "/api/admin"
        }
    }
    
    // MARK: - Build Info
    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }
    
    static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }
    
    static var versionString: String {
        "\(appVersion) (\(buildNumber)) - \(environment.displayName)"
    }
}

// MARK: - Usage Example
/*
 
 HOW TO USE:
 
 1. Switch Environments:
    Open Config.swift and change line 16:
    
    For local development:
    static let current: Environment = .development
    
    For staging tests:
    static let current: Environment = .staging
    
    For production release:
    static let current: Environment = .production
 
 2. In your code:
    let url = "\(Config.apiBaseURL)/api/endpoint"
    Config.log("User logged in", level: .info)
 
 3. Access feature flags:
    if Config.Features.showDebugMenu {
        // Show debug options
    }
 
 */
