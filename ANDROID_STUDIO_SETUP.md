# 🚀 Android Studio Setup Guide for Flutter

This guide will help you set up Android Studio to develop your Flutter iOS app on Windows.

## Step 1: Install Android Studio

1. **Download Android Studio**
   - Go to: https://developer.android.com/studio
   - Click "Download Android Studio"
   - Run the installer (`android-studio-*.exe`)

2. **Installation Steps**
   - Choose "Standard" installation type
   - Let it download Android SDK components (this may take a while)
   - Click "Finish" when done

## Step 2: Install Flutter SDK

1. **Download Flutter**
   - Go to: https://flutter.dev/docs/get-started/install/windows
   - Download the Flutter SDK ZIP file
   - Extract it to a location like `C:\src\flutter` (avoid spaces in path)

2. **Add Flutter to PATH**
   - Press `Win + X` and select "System"
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Under "User variables", find "Path" and click "Edit"
   - Click "New" and add: `C:\src\flutter\bin` (or your Flutter path)
   - Click "OK" on all dialogs

3. **Verify Flutter Installation**
   - Open PowerShell or Command Prompt
   - Run: `flutter doctor`
   - This will check your setup

## Step 3: Install Flutter Plugin in Android Studio

1. **Open Android Studio**
   - Launch Android Studio
   - If it's your first time, complete the setup wizard

2. **Install Flutter Plugin**
   - Go to `File` → `Settings` (or `Ctrl + Alt + S`)
   - In the left panel, click `Plugins`
   - Click the "Marketplace" tab
   - Search for "Flutter"
   - Click "Install" (this will also install "Dart" plugin)
   - Click "OK" and restart Android Studio when prompted

## Step 4: Configure Flutter in Android Studio

1. **Set Flutter SDK Path**
   - Go to `File` → `Settings` → `Languages & Frameworks` → `Flutter`
   - Click the folder icon next to "Flutter SDK path"
   - Navigate to your Flutter installation (e.g., `C:\src\flutter`)
   - Click "OK"

2. **Verify Setup**
   - Go to `File` → `Settings` → `Languages & Frameworks` → `Flutter`
   - You should see a green checkmark if Flutter is detected correctly

## Step 5: Open Your Project

1. **Open Project in Android Studio**
   - Click `File` → `Open`
   - Navigate to: `C:\Users\chriskar\Downloads\Cursor Test`
   - Select the folder and click "OK"
   - Android Studio will recognize it as a Flutter project

2. **Wait for Indexing**
   - Android Studio will index your project (first time may take a few minutes)
   - You'll see progress in the bottom status bar

## Step 6: Get Dependencies

1. **Open Terminal in Android Studio**
   - Click the "Terminal" tab at the bottom of Android Studio
   - Or go to `View` → `Tool Windows` → `Terminal`

2. **Run Flutter Commands**
   ```bash
   flutter pub get
   ```
   - This downloads all dependencies
   - You should see "Running 'flutter pub get' in ios_app..."

## Step 7: Set Up Android Emulator

1. **Open AVD Manager**
   - Click the device dropdown (top toolbar) → `Device Manager`
   - Or go to `Tools` → `Device Manager`

2. **Create Virtual Device**
   - Click "Create Device"
   - Select a device (e.g., "Pixel 5")
   - Click "Next"
   - Select a system image (e.g., "Tiramisu" API 33)
   - Click "Download" if needed, then "Next"
   - Click "Finish"

3. **Start Emulator**
   - Click the play button (▶) next to your device
   - Wait for the emulator to boot (first time may take a few minutes)

## Step 8: Run Your App

1. **Select Device**
   - In the top toolbar, click the device dropdown
   - Select your Android emulator

2. **Run the App**
   - Click the green "Run" button (▶) in the toolbar
   - Or press `Shift + F10`
   - Or right-click `lib/main.dart` → `Run 'main.dart'`

3. **First Run**
   - Android Studio will build the app (may take a few minutes)
   - The app will launch on the emulator
   - You should see "Welcome to your Flutter iOS App!"

## 🎉 You're All Set!

### Quick Tips:

- **Hot Reload**: Press `Ctrl + \` or click the 🔥 icon to see changes instantly
- **Hot Restart**: Press `Ctrl + Shift + \` to restart the app
- **Stop App**: Press `Ctrl + F2` or click the stop button

### Common Commands in Terminal:

```bash
flutter pub get          # Get dependencies
flutter clean            # Clean build files
flutter doctor           # Check Flutter setup
flutter devices          # List available devices
flutter run              # Run the app
```

### Troubleshooting:

**"Flutter SDK not found"**
- Make sure Flutter is added to your PATH
- Restart Android Studio after adding to PATH
- Check Flutter SDK path in Settings

**"No devices found"**
- Make sure Android emulator is running
- Or connect a physical Android device via USB
- Enable USB debugging on physical device

**"Gradle build failed"**
- Go to `File` → `Invalidate Caches` → `Invalidate and Restart`
- Run `flutter clean` in terminal
- Run `flutter pub get` again

**App won't run**
- Check the "Run" tab at the bottom for error messages
- Make sure you selected a device/emulator
- Try `flutter doctor` to check for issues

## 📱 Testing on Android vs iOS

- **Android**: Test locally in Android Studio using Android emulator ✅
- **iOS**: Build on Codemagic (no Mac needed) ✅

You can develop and test on Android, then build iOS versions on Codemagic!

---

Need help? Check the main README.md or Flutter documentation: https://flutter.dev/docs

