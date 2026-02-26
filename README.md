# Flutter iOS App - Codemagic Ready

This is a Flutter iOS application configured to build on Codemagic CI/CD.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio (for local development)
- Git
- Codemagic account (for iOS builds)

### 🎯 Quick Start with Android Studio

**For detailed step-by-step instructions, see [ANDROID_STUDIO_SETUP.md](ANDROID_STUDIO_SETUP.md)**

1. **Install Android Studio**
   - Download from: https://developer.android.com/studio
   - Install Flutter plugin: `File` → `Settings` → `Plugins` → Search "Flutter" → Install

2. **Install Flutter SDK**
   - Download from: https://flutter.dev/docs/get-started/install/windows
   - Extract to `C:\src\flutter` (or similar)
   - Add to PATH: `C:\src\flutter\bin`

3. **Open Project in Android Studio**
   - `File` → `Open` → Select this project folder
   - Android Studio will detect it as a Flutter project

4. **Get Dependencies**
   - Open Terminal in Android Studio (bottom panel)
   - Run: `flutter pub get`

5. **Run the App**
   - Create an Android emulator: `Tools` → `Device Manager` → `Create Device`
   - Click the green "Run" button (▶) or press `Shift + F10`
   - Your app will launch on the Android emulator!

### Local Development (Command Line)

1. **Verify Flutter installation**:
   ```bash
   flutter doctor
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app** (on Android emulator or connected device):
   ```bash
   flutter run
   ```

## 📱 Building for iOS on Codemagic

### Setup Steps:

1. **Push to Git Repository**:
   - Initialize git (if not already):
     ```bash
     git init
     git add .
     git commit -m "Initial commit"
     ```
   - Push to GitHub, GitLab, or Bitbucket

2. **Connect to Codemagic**:
   - Go to [codemagic.io](https://codemagic.io)
   - Sign up/Login
   - Click "Add application"
   - Select your repository
   - Codemagic will automatically detect the `codemagic.yaml` file

3. **Configure iOS Code Signing**:
   - In Codemagic dashboard, go to your app settings
   - Navigate to "Code signing"
   - Upload your iOS distribution certificate and provisioning profile
   - Or use Codemagic's automatic code signing

4. **Update Codemagic Configuration**:
   - Edit `codemagic.yaml` and update:
     - Email recipients for build notifications
     - Bundle identifier (currently: `com.example.iosApp`)
     - Any additional build configurations

5. **Start Building**:
   - Click "Start new build" in Codemagic
   - Select the workflow: "iOS Workflow"
   - Your app will be built in the cloud!

### Codemagic Configuration

The `codemagic.yaml` file is pre-configured with:
- ✅ Flutter stable channel
- ✅ Latest Xcode version
- ✅ CocoaPods dependency installation
- ✅ iOS IPA build
- ✅ Email notifications

### Customization

**Update Bundle Identifier**:
1. Edit `ios/Runner.xcodeproj/project.pbxproj`
2. Search for `PRODUCT_BUNDLE_IDENTIFIER` and change `com.example.iosApp` to your bundle ID
3. Or use Xcode (on Mac) to change it in the project settings

**Update App Name**:
1. Edit `ios/Runner/Info.plist`
2. Change `CFBundleDisplayName` value

**Add Dependencies**:
1. Edit `pubspec.yaml`
2. Add your packages under `dependencies:`
3. Run `flutter pub get` locally

## 📁 Project Structure

```
.
├── lib/
│   └── main.dart              # Main app code
├── android/                   # Android native configuration
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   ├── build.gradle
│   └── settings.gradle
├── ios/                       # iOS native configuration
│   ├── Runner/
│   │   ├── Info.plist
│   │   └── AppDelegate.swift
│   ├── Podfile
│   └── Runner.xcodeproj/
├── pubspec.yaml               # Flutter dependencies
├── codemagic.yaml             # Codemagic CI/CD configuration
├── ANDROID_STUDIO_SETUP.md    # Detailed Android Studio setup guide
└── README.md
```

## 🔧 Troubleshooting

**Build fails on Codemagic?**
- Check that your bundle identifier is unique
- Ensure code signing certificates are properly configured
- Verify all dependencies in `pubspec.yaml` are compatible

**Local development issues?**
- Run `flutter doctor` to check for issues
- Run `flutter clean` and `flutter pub get`
- Ensure you're using Flutter stable channel

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Codemagic Documentation](https://docs.codemagic.io)
- [Flutter iOS Setup](https://flutter.dev/docs/deployment/ios)

## 📝 Notes

- **Android Development**: Test and develop locally on Windows using Android Studio ✅
- **iOS Builds**: Build iOS apps on Codemagic (no Mac needed) ✅
- The app uses Material Design 3 by default
- Minimum iOS version: 12.0
- Minimum Android version: API 21 (Android 5.0)

---

Happy coding! 🎉

