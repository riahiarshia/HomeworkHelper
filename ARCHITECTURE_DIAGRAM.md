# HomeworkHelper iOS App - Architecture Diagram

## 🏗️ System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                iOS CLIENT                                       │
│  ┌─────────────────────────────────────────────────────────────────────────────┐│
│  │                         SwiftUI App Layer                                  ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      ││
│  │  │  HomeView   │  │ StepGuidance│  │  ChatView   │  │ProgressView │      ││
│  │  │             │  │    View     │  │             │  │             │      ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘      ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      ││
│  │  │ProblemsList │  │ SettingsView│  │Authentication│  │ PaywallView │      ││
│  │  │    View     │  │             │  │    View     │  │             │      ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘      ││
│  └─────────────────────────────────────────────────────────────────────────────┘│
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐│
│  │                        Service Layer                                        ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      ││
│  │  │BackendAPI   │  │Authentication│  │Subscription │  │ AzureKeyVault│      ││
│  │  │  Service    │  │  Service     │  │  Service    │  │  Service    │      ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘      ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                       ││
│  │  │ DataManager │  │KeychainHelper│  │   Config    │                       ││
│  │  │             │  │             │  │             │                       ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘                       ││
│  └─────────────────────────────────────────────────────────────────────────────┘│
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐│
│  │                        Data Layer                                           ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      ││
│  │  │   Models    │  │FileManager  │  │  Keychain   │  │ UserDefaults │      ││
│  │  │             │  │ (JSON Files)│  │ (Secure)    │  │             │      ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘      ││
│  └─────────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTPS/API Calls
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            BACKEND SERVER                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────┐│
│  │                         Express.js Server                                  ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      ││
│  │  │   Routes    │  │ Middleware  │  │   CORS      │  │Static Files │      ││
│  │  │             │  │             │  │             │  │             │      ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘      ││
│  └─────────────────────────────────────────────────────────────────────────────┘│
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐│
│  │                        API Endpoints                                       ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      ││
│  │  │   /api/auth │  │/api/analyze │  │/api/subscription│/api/admin  │      ││
│  │  │             │  │ -homework   │  │             │  │             │      ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘      ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      ││
│  │  │/api/payment │  │/api/homework│  │/api/usage   │  │/api/health  │      ││
│  │  │             │  │             │  │             │  │             │      ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘      ││
│  └─────────────────────────────────────────────────────────────────────────────┘│
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐│
│  │                        Service Layer                                       ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      ││
│  │  │OpenAI       │  │Subscription │  │Email        │  │Azure        │      ││
│  │  │Service      │  │Service      │  │Service      │  │Service      │      ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘      ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      ││
│  │  │Homework     │  │Usage        │  │Device       │  │Entitlements │      ││
│  │  │Tracking     │  │Tracking     │  │Tracking     │  │Ledger       │      ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘      ││
│  └─────────────────────────────────────────────────────────────────────────────┘│
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐│
│  │                        Database Layer                                      ││
│  │  ┌─────────────────────────────────────────────────────────────────────────┐││
│  │  │                        PostgreSQL Database                              │││
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │││
│  │  │  │    Users    │  │ Subscriptions│  │  Homework   │  │   Devices   │  │││
│  │  │  │   Table     │  │    Table     │  │    Table    │  │   Table     │  │││
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘  │││
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │││
│  │  │  │   Usage     │  │ Entitlements│  │   Admin     │  │   Activity  │  │││
│  │  │  │   Table     │  │   Ledger    │  │    Table    │  │   Logs      │  │││
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘  │││
│  │  └─────────────────────────────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTPS
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            EXTERNAL SERVICES                                   │
│  ┌─────────────────────────────────────────────────────────────────────────────┐│
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      ││
│  │  │   OpenAI    │  │   Stripe    │  │ Azure Key   │  │ SendGrid    │      ││
│  │  │     API     │  │   Payments  │  │   Vault     │  │   Email     │      ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘      ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      ││
│  │  │   Apple     │  │   Google    │  │   Azure AD  │  │   Azure     │      ││
│  │  │  Sign-In    │  │  Sign-In    │  │             │  │ App Service │      ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘      ││
│  └─────────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow Architecture

### 1. Authentication Flow
```
User → iOS App → AuthenticationService → Backend API → PostgreSQL
     ← Auth Token ← JWT Token ← User Data ← Database
```

### 2. Homework Analysis Flow
```
User Upload → HomeView → BackendAPIService → Backend Server → OpenAI API
     ↓              ↓              ↓              ↓
Image/Text → DataManager → Image Analysis → GPT-4o-mini
     ↓              ↓              ↓              ↓
Local Storage ← Step Creation ← Problem Analysis ← AI Response
```

### 3. Subscription Management Flow
```
User → PaywallView → SubscriptionService → Backend → Stripe API
     ↓              ↓              ↓              ↓
Purchase → Apple IAP → Payment Processing → Subscription Update
     ↓              ↓              ↓              ↓
Local Update ← Backend Update ← Webhook ← Stripe Confirmation
```

## 📱 iOS App Components

### **Views (SwiftUI)**
- **HomeView**: Image capture and homework submission
- **StepGuidanceView**: Interactive step-by-step problem solving
- **ChatView**: AI-powered Q&A during homework
- **ProgressView**: User progress tracking and statistics
- **ProblemsListView**: History of all homework problems
- **SettingsView**: User preferences and API key management
- **AuthenticationView**: Login/signup with multiple providers
- **PaywallView**: Subscription management and purchases

### **Services**
- **BackendAPIService**: Main API communication layer
- **AuthenticationService**: Handles all authentication methods
- **SubscriptionService**: Manages in-app purchases and subscriptions
- **AzureKeyVaultService**: Secure API key management
- **DataManager**: Local data persistence and management
- **KeychainHelper**: Secure credential storage

### **Models**
- **User**: User profile and authentication data
- **HomeworkProblem**: Homework problem data structure
- **GuidanceStep**: Individual step in problem solving
- **ChatMessage**: Chat conversation data
- **UserProgress**: Progress tracking data

## 🖥️ Backend Architecture

### **Server (Express.js)**
- RESTful API with comprehensive endpoints
- Middleware for authentication, CORS, and request parsing
- Static file serving for admin dashboard
- Environment-specific configuration

### **API Routes**
- `/api/auth/*`: Authentication (email, Google, Apple Sign-In)
- `/api/analyze-homework`: AI-powered homework analysis
- `/api/subscription/*`: Subscription management
- `/api/payment/*`: Stripe payment processing
- `/api/admin/*`: Admin dashboard and management
- `/api/homework/*`: Homework tracking and statistics
- `/api/usage/*`: Usage tracking and analytics

### **Services**
- **openaiService**: GPT-4o-mini integration for homework analysis
- **subscriptionService**: Subscription lifecycle management
- **emailService**: SendGrid integration for notifications
- **azureService**: Azure Key Vault for secure secrets
- **homeworkTrackingService**: Analytics and progress tracking
- **deviceTrackingService**: Device management and abuse prevention

### **Database (PostgreSQL)**
- **users**: User accounts and profiles
- **subscriptions**: Subscription status and billing
- **homework_submissions**: Homework tracking and analytics
- **devices**: Device registration and tracking
- **usage_tracking**: Usage analytics and limits
- **entitlements_ledger**: Subscription entitlements
- **admin_users**: Admin dashboard access
- **activity_logs**: Audit trail and monitoring

## 🔐 Security Architecture

### **iOS App Security**
- API keys stored in iOS Keychain (encrypted)
- Azure Key Vault integration for centralized key management
- JWT token-based authentication
- Secure credential storage with KeychainHelper

### **Backend Security**
- JWT token validation middleware
- Password hashing with bcrypt
- CORS configuration for iOS app
- Environment variable protection
- Azure Key Vault for production secrets

### **External Service Security**
- OpenAI API key rotation via Azure Key Vault
- Stripe webhook signature verification
- OAuth 2.0 for Google/Apple Sign-In
- Azure AD authentication for admin access

## 🚀 Deployment Architecture

### **iOS App**
- Native iOS app built with SwiftUI
- Supports iOS 16.0+
- Optimized for iPhone 16
- App Store distribution ready

### **Backend Deployment**
- **Azure App Service**: Hosted backend API
- **PostgreSQL Database**: Azure Database for PostgreSQL
- **Azure Key Vault**: Secure secret management
- **Staging Environment**: Separate staging deployment
- **Production Environment**: Live production deployment

### **External Integrations**
- **OpenAI API**: GPT-4o-mini for homework analysis
- **Stripe**: Payment processing and subscriptions
- **Apple App Store**: In-app purchase validation
- **Google Sign-In**: OAuth authentication
- **Apple Sign-In**: OAuth authentication
- **SendGrid**: Email notifications

## 📊 Data Flow Summary

1. **User Authentication**: Multiple OAuth providers + email/password
2. **Homework Submission**: Image/text → AI analysis → Step-by-step guidance
3. **Progress Tracking**: Local storage + backend analytics
4. **Subscription Management**: Apple IAP → Stripe → Backend sync
5. **Admin Dashboard**: Web-based management interface
6. **Security**: End-to-end encryption with Azure Key Vault

## 🔧 Key Features

- **Multi-modal Input**: Camera, photo library, and text input
- **AI-Powered Analysis**: GPT-4o-mini for intelligent problem solving
- **Interactive Guidance**: Step-by-step problem solving with hints
- **Progress Tracking**: Detailed analytics and progress monitoring
- **Subscription System**: Freemium model with usage limits
- **Multi-platform Auth**: Google, Apple, and email authentication
- **Admin Dashboard**: Comprehensive management interface
- **Device Tracking**: Abuse prevention and usage monitoring
- **Secure Architecture**: Enterprise-grade security with Azure integration
