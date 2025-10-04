# HomeworkHelper - AI-Powered iOS Homework Assistant

An intelligent iOS app that provides step-by-step guidance for homework problems using AI analysis.

## Features

- 📸 **Image Analysis**: Take photos of homework problems for AI analysis
- 🧠 **AI-Powered Guidance**: Get personalized step-by-step solutions
- 📚 **Multiple Subjects**: Supports math, science, history, and more
- 🎯 **Adaptive Learning**: Adjusts to your grade level and learning style
- 💬 **Interactive Chat**: Ask questions and get instant help
- 📊 **Progress Tracking**: Monitor your learning progress

## Recent Updates

### Version 2.0 - Critical Bug Fix
- ✅ **Fixed**: App hanging on "Loading homework steps..." screen
- 🔧 **Root Cause**: Missing step creation in `analyzeImageWithQualityCheck` function
- 🛠️ **Solution**: Added proper `GuidanceStep` creation and `DataManager.addStep` calls
- 📱 **Enhanced**: Added comprehensive debugging and error handling
- 🎯 **Result**: App now works seamlessly on both simulator and physical devices

### Debugging Enhancements
- Added UI debug panel for troubleshooting
- Implemented device-specific logging with `os_log`
- Added timeout handling for long-running operations
- Enhanced error messages and user feedback

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.0+
- Internet connection for AI analysis

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/riahiarshia/HomeworkHelper.git
   ```

2. Open `HomeworkHelper.xcodeproj` in Xcode

3. Build and run on your device or simulator

## Configuration

The app requires configuration for AI services:

1. **Azure Key Vault**: For secure API key management
2. **Backend API**: For image analysis and step generation
3. **OpenAI Integration**: For intelligent problem solving

See the documentation files for detailed setup instructions.

## Architecture

### Core Components

- **HomeView**: Image capture and problem analysis
- **StepGuidanceView**: Interactive step-by-step guidance
- **ChatView**: AI-powered question answering
- **DataManager**: Local data persistence and management
- **BackendAPIService**: Communication with analysis backend
- **AzureKeyVaultService**: Secure credential management

### Key Services

- `BackendAPIService`: Handles homework analysis and step generation
- `OpenAIService`: Direct AI integration for problem solving
- `AzureKeyVaultService`: Secure API key storage and retrieval
- `DataManager`: Local storage for problems, steps, and user progress

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Troubleshooting

### Common Issues

**App hangs on "Loading homework steps..."**
- ✅ **Fixed in v2.0**: This was a critical bug that has been resolved
- The issue was missing step creation in the image analysis process

**Network connectivity issues**
- Ensure your device has internet access
- Check backend API availability
- Verify Azure Key Vault configuration

**Image quality issues**
- Use good lighting when taking photos
- Ensure text is clearly visible
- Try different angles for better results

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in this repository
- Check the documentation files for setup guides
- Review the troubleshooting section above

## Acknowledgments

- Built with SwiftUI and iOS development best practices
- AI analysis powered by OpenAI and custom backend services
- Secure credential management with Azure Key Vault
