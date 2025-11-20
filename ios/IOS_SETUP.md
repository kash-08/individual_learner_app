# iOS Setup Instructions

## For iOS Developers (with macOS):

### 1. Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Add iOS app to your project
3. Bundle ID: `com.example.individualLearnerApp`
4. Download `GoogleService-Info.plist`
5. Replace `ios/Runner/GoogleService-Info.plist`

### 2. Install Dependencies
```bash
cd ios
pod install
cd ..