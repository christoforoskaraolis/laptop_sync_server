# ⚡ Quick Start Checklist

Follow these steps to get your Flutter app running in Android Studio:

## ✅ Setup Checklist

### 1. Install Android Studio
- [ ] Download from https://developer.android.com/studio
- [ ] Install Android Studio
- [ ] Complete first-time setup wizard

### 2. Install Flutter SDK
- [ ] Download Flutter from https://flutter.dev/docs/get-started/install/windows
- [ ] Extract to `C:\src\flutter` (avoid spaces in path)
- [ ] Add Flutter to PATH: `C:\src\flutter\bin`
- [ ] Verify: Open PowerShell and run `flutter doctor`

### 3. Install Flutter Plugin in Android Studio
- [ ] Open Android Studio
- [ ] Go to `File` → `Settings` → `Plugins`
- [ ] Search for "Flutter" and click "Install"
- [ ] Restart Android Studio when prompted

### 4. Configure Flutter SDK Path
- [ ] In Android Studio: `File` → `Settings` → `Languages & Frameworks` → `Flutter`
- [ ] Set Flutter SDK path to your Flutter installation (e.g., `C:\src\flutter`)
- [ ] Click "OK"

### 5. Open Your Project
- [ ] In Android Studio: `File` → `Open`
- [ ] Navigate to: `C:\Users\chriskar\Downloads\Cursor Test`
- [ ] Select the folder and click "OK"
- [ ] Wait for Android Studio to index the project

### 6. Get Dependencies
- [ ] Open Terminal in Android Studio (bottom panel)
- [ ] Run: `flutter pub get`
- [ ] Wait for dependencies to download

### 7. Create Android Emulator
- [ ] In Android Studio: `Tools` → `Device Manager`
- [ ] Click "Create Device"
- [ ] Select a device (e.g., "Pixel 5")
- [ ] Select a system image (e.g., "Tiramisu" API 33)
- [ ] Click "Finish"

### 8. Run Your App
- [ ] Start the emulator (click ▶ next to your device)
- [ ] Wait for emulator to boot
- [ ] In Android Studio, select your emulator from device dropdown
- [ ] Click the green "Run" button (▶) or press `Shift + F10`
- [ ] Wait for the app to build and launch

## 🎉 Success!

If you see "Welcome to your Flutter iOS App!" on the emulator, you're all set!

## 🆘 Need Help?

- **Detailed guide**: See [ANDROID_STUDIO_SETUP.md](ANDROID_STUDIO_SETUP.md)
- **Troubleshooting**: Check the main [README.md](README.md)
- **Flutter docs**: https://flutter.dev/docs

## 💡 Pro Tips

- **Hot Reload**: Press `Ctrl + \` to see code changes instantly
- **Stop App**: Press `Ctrl + F2`
- **View Logs**: Check the "Run" tab at the bottom

---

**Next Steps**: Once you can run the app on Android, you can build iOS versions on Codemagic!

