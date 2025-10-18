HOMEWORK HELPER - iOS NATIVE APP
=================================

A native iOS application built with Swift and SwiftUI for iPhone 16 (iOS 16+).
Provides AI-powered homework tutoring with step-by-step guidance.

FEATURES:
---------
✓ Upload homework images from camera or photo library
✓ Text-only homework submissions
✓ Combined text + image submissions
✓ AI-powered problem analysis and step-by-step guidance
✓ Interactive chat with AI tutor
✓ Skip questions feature (reduced points when skipped)
✓ Progress tracking by subject
✓ Points and streak system
✓ All data stored locally on device (FileManager)
✓ Secure API key storage (iOS Keychain)
✓ Direct OpenAI API integration (no backend server needed)

REQUIREMENTS:
-------------
- macOS with Xcode 14.0 or later
- iOS 16.0+ deployment target
- iPhone 16 optimized (works on all iPhones running iOS 16+)
- OpenAI API Key (get one at https://platform.openai.com/api-keys)

HOW TO OPEN AND BUILD:
----------------------
1. Download the entire "ios-app" folder to your Mac

2. Open the project in Xcode:
   - Double-click "HomeworkHelper.xcodeproj" 
   OR
   - Open Xcode and select "Open a project or file"
   - Navigate to ios-app/HomeworkHelper.xcodeproj

3. Configure signing:
   - Select the 'HomeworkHelper' project in the navigator
   - Select the 'HomeworkHelper' target
   - Go to 'Signing & Capabilities' tab
   - Select your Team
   - Xcode will automatically manage provisioning

4. Verify Info.plist permissions (should already be included):
   - NSCameraUsageDescription: "We need camera access to capture homework problems"
   - NSPhotoLibraryUsageDescription: "We need photo library access to select homework images"

5. Connect your iPhone or select a simulator:
   - In Xcode, click the device selector at the top
   - Choose your connected iPhone or a simulator (iPhone 16 recommended)

6. Build and Run:
   - Press Cmd + R (or click the Play button)
   - The app will compile and install on your device

FIRST TIME SETUP:
-----------------
1. Launch the app on your iPhone
2. Go to Settings tab (rightmost icon)
3. Enter your OpenAI API Key
4. Tap "Save API Key"
   - API key is securely stored in iOS Keychain
   - Never stored in plain text or UserDefaults

USING THE APP:
--------------
1. HOME TAB:
   - Tap "Camera" to take a photo of your homework
   - OR tap "Photo Library" to select an existing image
   - OR type your homework problem in the text field
   - You can provide both text and image together
   - Tap "Get Step-by-Step Help"

2. STEP GUIDANCE:
   - Read each question carefully
   - Select an answer from the multiple choice options
   - Tap "Continue" to check your answer
   - Tap "Need a hint?" if you're stuck
   - Tap "Skip" to move to the next step (reduces points by 5)
   - Use the chat icon to ask the AI tutor questions

3. PROBLEMS TAB:
   - View all your homework problems
   - Filter by All, In Progress, or Completed
   - Tap a problem to see details and continue

4. PROGRESS TAB:
   - See your total points and streak
   - View progress by subject
   - Track problems solved and average scores

5. SETTINGS TAB:
   - Manage your OpenAI API Key (securely stored in Keychain)
   - View account statistics
   - Reset all data if needed

EDITING IN CURSOR:
------------------
You can edit the Swift files in Cursor IDE:
1. Open the entire "ios-app" folder in Cursor
2. Edit any .swift files as needed
3. Return to Xcode to build and test changes
4. Xcode will automatically detect file changes

PROJECT STRUCTURE:
------------------
ios-app/
├── HomeworkHelper.xcodeproj/    (Xcode project file)
└── HomeworkHelper/
    ├── HomeworkHelperApp.swift  (Main app entry point)
    ├── ContentView.swift        (Main navigation with tab bar)
    ├── Info.plist               (App configuration)
    ├── Models/                  (Data models - all Codable)
    │   ├── User.swift
    │   ├── HomeworkProblem.swift
    │   ├── GuidanceStep.swift
    │   ├── ChatMessage.swift
    │   └── UserProgress.swift
    ├── Views/                   (SwiftUI screens)
    │   ├── HomeView.swift
    │   ├── StepGuidanceView.swift
    │   ├── ChatView.swift
    │   ├── ProgressView.swift
    │   ├── ProblemsListView.swift
    │   └── SettingsView.swift
    └── Services/                (Business logic)
        ├── DataManager.swift    (Local file persistence)
        ├── OpenAIService.swift  (AI integration)
        └── KeychainHelper.swift (Secure storage utility)

DATA STORAGE & ARCHITECTURE:
----------------------------
PERSISTENCE:
- FileManager-based storage in app's Documents directory
- Separate JSON files for each data type:
  * user.json - User profile with points and streak
  * problems.json - All homework problems
  * steps.json - Guidance steps (keyed by problemId)
  * messages.json - Chat messages (keyed by problemId)
  * progress.json - Subject-based progress tracking
- Images stored as separate files (named by problem UUID)
- ISO8601 date encoding for compatibility
- Dictionary keys use String (UUID.uuidString) for JSON serialization

SECURITY:
- OpenAI API key stored in iOS Keychain (not UserDefaults)
- Uses kSecClassGenericPassword for secure storage
- API key never logged or exposed
- No backend server - all data stays on device

AI INTEGRATION:
- Direct OpenAI API calls using GPT-4o-mini model
- Supports multimodal inputs (text + image)
- Image verification before analysis
- Problem breakdown into guided steps
- Interactive chat tutoring
- Hint generation for stuck students
- JSON response format for structured data

TESTING RECOMMENDATIONS:
-----------------------
Test these scenarios to verify all features:
1. Text-only homework submission (no image)
2. Image-only homework submission (camera or library)
3. Combined text + image submission
4. Skip functionality in step guidance (verify points reduction)
5. Chat tutor interaction with follow-up questions
6. Progress tracking after completing multiple problems
7. API key persistence after app restart
8. Error handling with invalid API key
9. Navigation between all tabs
10. Dark mode compatibility

TROUBLESHOOTING:
----------------
If the app crashes when accessing camera/photos:
→ Verify Info.plist has NSCameraUsageDescription and NSPhotoLibraryUsageDescription
→ Check that permissions are granted in iOS Settings

If API calls fail:
→ Verify API key is entered correctly in Settings
→ Check internet connection
→ Verify OpenAI API key has sufficient credits
→ Check error message - app now displays detailed API errors

If data doesn't persist:
→ Check device storage space
→ Ensure app has write permissions to Documents directory
→ Check Console logs in Xcode for DataManager errors

If the app doesn't build:
→ Use Xcode 14.0 or later
→ Check deployment target is iOS 16.0
→ Clean build folder (Cmd + Shift + K)
→ Try rebuilding (Cmd + B)
→ Verify all Swift files are included in the target

TECHNICAL NOTES:
----------------
- Minimum deployment: iOS 16.0
- Uses SwiftUI for all UI components
- No external dependencies (native Swift/iOS APIs only)
- Compatible with dark mode
- All data structures use Codable for JSON serialization
- Dictionary keys are Strings for JSON compatibility
- Images compressed to JPEG at 80% quality
- Supports both landscape and portrait orientations
- Tab-based navigation pattern

KEY IMPROVEMENTS FROM WEB VERSION:
----------------------------------
✓ Native iOS performance and animations
✓ Offline access to saved problems
✓ iOS Keychain for secure API key storage
✓ FileManager for robust data persistence
✓ Native camera and photo library integration
✓ No server maintenance required
✓ All data stays on device for privacy

FUTURE ENHANCEMENTS:
--------------------
- More subjects and categories
- Streak notifications
- Achievement system
- Export progress reports (PDF/CSV)
- Offline mode with queued submissions
- iCloud sync between devices
- Widget for quick problem submission
- Parent/teacher dashboard integration

SUPPORT & DOCUMENTATION:
------------------------
- OpenAI API Docs: https://platform.openai.com/docs
- Swift Documentation: https://swift.org/documentation
- SwiftUI Tutorials: https://developer.apple.com/tutorials/swiftui
- Inline code comments throughout the project

For questions about the codebase, check the inline documentation in each Swift file.
All major functions include comments explaining their purpose and usage.
