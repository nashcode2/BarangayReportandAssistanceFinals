# 📦 Building Mobile App Installer (APK)
## Barangay Report and Assistance System

This guide explains how to build an APK file (Android installer) for distribution to end users.

---

## 📋 Prerequisites

Before building the APK, ensure you have:

- ✅ Flutter SDK installed and configured
- ✅ Android Studio installed
- ✅ Android SDK configured
- ✅ Project dependencies installed (`flutter pub get`)
- ✅ Firebase configured (google-services.json in place)
- ✅ All features tested and working

---

## 🔧 Step-by-Step Guide

### Step 1: Prepare the Project

1. **Navigate to Project Directory**
   ```bash
   cd C:\Users\nashn\Desktop\BARANGAY
   ```

2. **Clean Previous Builds**
   ```bash
   flutter clean
   ```

3. **Get Dependencies**
   ```bash
   flutter pub get
   ```

4. **Verify Flutter Setup**
   ```bash
   flutter doctor
   ```
   Ensure all checks pass (especially Android toolchain)

---

### Step 2: Configure App Details

#### Update App Version (Optional)

Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1
# Format: version_name+build_number
# Example: 1.0.0+1 means version 1.0.0, build 1
```

#### Update App Name and Icon (Optional)

- App name is in `android/app/src/main/AndroidManifest.xml`
- App icon should be in `assets/icons/app_icon.png`
- Run `flutter pub run flutter_launcher_icons` to generate icons

---

### Step 3: Build Release APK

#### Option A: Standard Release APK (Recommended)

```bash
flutter build apk --release
```

This creates a single APK file that works on all Android devices.

**Output Location:**
```
build/app/outputs/flutter-apk/app-release.apk
```

#### Option B: Split APKs by ABI (Smaller File Size)

```bash
flutter build apk --split-per-abi --release
```

This creates separate APKs for different architectures:
- `app-armeabi-v7a-release.apk` (32-bit)
- `app-arm64-v8a-release.apk` (64-bit)
- `app-x86_64-release.apk` (x86_64)

**Output Location:**
```
build/app/outputs/flutter-apk/
```

**Note**: Use split APKs if file size is a concern. Standard APK works on all devices but is larger.

#### Option C: App Bundle (For Google Play Store)

```bash
flutter build appbundle --release
```

This creates an AAB (Android App Bundle) file for Play Store upload.

**Output Location:**
```
build/app/outputs/bundle/release/app-release.aab
```

---

### Step 4: Verify APK

1. **Check APK File**
   - Navigate to output directory
   - Verify file exists and has reasonable size (usually 20-50 MB)
   - Check file name: `app-release.apk`

2. **Test APK** (Optional but Recommended)
   - Transfer APK to Android device
   - Install and test all features
   - Verify Firebase connection works
   - Test login, reports, and other features

---

### Step 5: Sign APK (For Distribution)

#### For Testing/Internal Distribution:
- APK is already signed with debug key (works for testing)
- Can be installed directly on devices

#### For Production/Public Distribution:

1. **Create Keystore** (First time only)
   ```bash
   keytool -genkey -v -keystore C:\Users\nashn\Desktop\BARANGAY\android\app\release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
   ```
   - Enter password (remember it!)
   - Fill in certificate information
   - Keep the keystore file safe!

2. **Create key.properties File**
   Create `android/key.properties`:
   ```properties
   storePassword=YOUR_STORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=release
   storeFile=C:\\Users\\nashn\\Desktop\\BARANGAY\\android\\app\\release-key.jks
   ```

3. **Update build.gradle**
   Edit `android/app/build.gradle`:
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

4. **Build Signed APK**
   ```bash
   flutter build apk --release
   ```

---

## 📱 Distributing the APK

### Option 1: Direct File Transfer

1. **Via USB**
   - Connect Android device via USB
   - Enable USB debugging
   - Copy APK to device
   - Install on device

2. **Via Email**
   - Email APK to users
   - Users download and install

3. **Via Cloud Storage**
   - Upload to Google Drive, Dropbox, etc.
   - Share download link
   - Users download and install

### Option 2: QR Code Distribution

1. Upload APK to cloud storage
2. Generate QR code for download link
3. Print QR code or display on screen
4. Users scan QR code to download

### Option 3: Website Download

1. Host APK on website
2. Create download page
3. Provide download link
4. Users download directly

---

## 🔒 Security Considerations

### Before Distribution:

1. **Remove Debug Code**
   - Remove print statements
   - Remove test data
   - Remove debug flags

2. **Obfuscate Code** (Optional)
   ```bash
   flutter build apk --release --obfuscate --split-debug-info=./debug-info
   ```

3. **Verify Permissions**
   - Check AndroidManifest.xml
   - Only request necessary permissions

4. **Test Thoroughly**
   - Test on multiple devices
   - Test all features
   - Verify Firebase connection

---

## 📋 Installation Instructions for End Users

Create a simple instruction file for users:

### How to Install APK on Android:

1. **Enable Unknown Sources**
   - Go to Settings → Security
   - Enable "Unknown Sources" or "Install Unknown Apps"
   - Select your file manager/browser

2. **Download APK**
   - Download from provided link
   - Wait for download to complete

3. **Install APK**
   - Open file manager
   - Navigate to Downloads folder
   - Tap on the APK file
   - Tap "Install"
   - Wait for installation

4. **Open App**
   - Tap "Open" or find app in app drawer
   - Grant permissions when prompted
   - Register or login

---

## 🛠️ Troubleshooting Build Issues

### Issue 1: "Gradle build failed"
**Solution:**
- Check Android SDK is installed
- Update Gradle: `cd android && ./gradlew wrapper --gradle-version=7.5`
- Clean build: `flutter clean && flutter pub get`

### Issue 2: "Keystore not found"
**Solution:**
- Verify key.properties file exists
- Check file paths are correct
- Ensure keystore file exists

### Issue 3: "APK too large"
**Solution:**
- Use split APKs: `flutter build apk --split-per-abi`
- Remove unused assets
- Enable ProGuard/R8 code shrinking

### Issue 4: "Build takes too long"
**Solution:**
- First build is always slow
- Subsequent builds are faster
- Close unnecessary applications

### Issue 5: "APK won't install"
**Solution:**
- Uninstall previous version first
- Check device has enough storage
- Verify APK is not corrupted
- Try on different device

---

## ✅ Build Checklist

Before distributing APK:

- [ ] Flutter clean completed
- [ ] Dependencies installed
- [ ] Firebase configured
- [ ] App version updated
- [ ] Release APK built successfully
- [ ] APK tested on device
- [ ] All features working
- [ ] Firebase connection verified
- [ ] APK signed (for production)
- [ ] Installation instructions prepared
- [ ] APK file size acceptable
- [ ] Ready for distribution

---

## 📊 APK File Information

### Typical APK Details:
- **File Name**: `app-release.apk`
- **File Size**: 20-50 MB (depending on assets)
- **Minimum Android Version**: API 21 (Android 5.0)
- **Target Android Version**: Latest
- **Architecture**: Universal (all devices) or Split by ABI

### File Location:
```
BARANGAY/
└── build/
    └── app/
        └── outputs/
            └── flutter-apk/
                └── app-release.apk  ← Your APK file
```

---

## 🚀 Quick Build Commands

### Standard Build:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Split APK Build:
```bash
flutter build apk --split-per-abi --release
```

### App Bundle Build (Play Store):
```bash
flutter build appbundle --release
```

### Obfuscated Build:
```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

---

## 📝 Notes

- **First Build**: Takes longer (5-10 minutes)
- **Subsequent Builds**: Faster (1-3 minutes)
- **File Size**: Standard APK is larger but works on all devices
- **Testing**: Always test APK before distribution
- **Updates**: Increment version number for updates
- **Backup**: Keep keystore file safe (required for updates)

---

## 🎯 Next Steps After Building

1. **Test APK** on multiple devices
2. **Create Installation Guide** for users
3. **Prepare Distribution Method** (email, cloud, website)
4. **Document Version** and changes
5. **Distribute to Users**

---

**APK Build Complete! 🎉**

Your mobile app installer is ready for distribution!


