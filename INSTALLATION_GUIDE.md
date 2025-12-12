# 📱 Installation Guide
## Barangay Report and Assistance System

This guide provides step-by-step instructions for installing and setting up the Barangay Report and Assistance System on different platforms.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [For Developers (Source Code Setup)](#for-developers-source-code-setup)
3. [For End Users (Mobile App Installation)](#for-end-users-mobile-app-installation)
4. [For Administrators (Web Access)](#for-administrators-web-access)
5. [Firebase Configuration](#firebase-configuration)
6. [Troubleshooting](#troubleshooting)

---

## 🔧 Prerequisites

### Required Software:
- **Flutter SDK** (version 3.0.0 or higher)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** (for cloning repository)
- **Firebase Account** (for backend services)

### For Android Development:
- **Android SDK** (API level 21 or higher)
- **Java Development Kit (JDK)** 11 or higher

### For iOS Development (Mac only):
- **Xcode** (latest version)
- **CocoaPods**

### For Web Development:
- Modern web browser (Chrome, Firefox, Edge, Safari)

---

## 👨‍💻 For Developers: Source Code Setup

### Step 1: Clone the Repository
```bash
git clone <repository-url>
cd BARANGAY
```

### Step 2: Install Flutter Dependencies
```bash
flutter pub get
```

### Step 3: Firebase Setup

#### 3.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add Project"
3. Enter project name: "Barangay Report Assistance"
4. Follow the setup wizard

#### 3.2 Configure Android App
1. In Firebase Console, click "Add App" → Android
2. Enter package name: `com.barangay.reportassistance` (check `android/app/build.gradle` for actual package)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

#### 3.3 Configure iOS App (if applicable)
1. In Firebase Console, click "Add App" → iOS
2. Enter bundle ID: `com.barangay.reportassistance` (check `ios/Runner/Info.plist`)
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

#### 3.4 Configure Web App
1. In Firebase Console, click "Add App" → Web
2. Copy the Firebase configuration
3. Update `lib/firebase_options.dart` with your config

### Step 4: Configure Google Maps API

#### 4.1 Get API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing
3. Enable "Maps SDK for Android" and "Maps SDK for iOS"
4. Create API key
5. Restrict API key (recommended for production)

#### 4.2 Add to Android
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY_HERE"/>
</application>
```

#### 4.3 Add to iOS
Edit `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Step 5: Deploy Firestore Rules
1. Go to Firebase Console → Firestore Database → Rules
2. Copy contents from `firestore.rules` file
3. Paste and click "Publish"

### Step 6: Deploy Storage Rules
1. Go to Firebase Console → Storage → Rules
2. Copy contents from `storage.rules` file
3. Paste and click "Publish"

### Step 7: Run the Application

#### For Android:
```bash
flutter run
# Or specify device
flutter run -d <device-id>
```

#### For iOS (Mac only):
```bash
flutter run
# Or specify device
flutter run -d <device-id>
```

#### For Web:
```bash
flutter run -d chrome
# Or
flutter run -d web-server --web-port 8080
```

---

## 📲 For End Users: Mobile App Installation

### Option 1: Install from Google Play Store (Production)
1. Open Google Play Store on your Android device
2. Search for "Barangay Report Assistance"
3. Click "Install"
4. Wait for installation to complete
5. Open the app and register/login

### Option 2: Install APK File (Development/Testing)

#### Step 1: Build APK
```bash
# Navigate to project directory
cd BARANGAY

# Build release APK
flutter build apk --release

# Or build app bundle (for Play Store)
flutter build appbundle --release
```

The APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

#### Step 2: Transfer APK to Device
- **Via USB**: Connect device, enable USB debugging, copy APK to device
- **Via Email**: Email APK to yourself, open on device
- **Via Cloud Storage**: Upload to Google Drive/Dropbox, download on device

#### Step 3: Install APK
1. On Android device, go to Settings → Security
2. Enable "Unknown Sources" or "Install Unknown Apps"
3. Open file manager and locate the APK file
4. Tap the APK file
5. Click "Install"
6. Wait for installation
7. Click "Open" or find app in app drawer

#### Step 4: First Launch
1. Open the app
2. Grant necessary permissions (Camera, Location, Storage, Notifications)
3. Register a new account or login
4. Start using the app!

---

## 💻 For Administrators: Web Access

### Option 1: Access Deployed Web App
1. Open web browser (Chrome, Firefox, Edge, Safari)
2. Navigate to: `https://your-app-url.web.app` (or provided URL)
3. Click "Admin Login"
4. Enter admin credentials
5. Access admin dashboard

### Option 2: Run Locally (Development)
```bash
# Navigate to project directory
cd BARANGAY

# Run web app
flutter run -d chrome

# Or build for production
flutter build web --release
```

The built web files will be in:
```
build/web/
```

Deploy to Firebase Hosting:
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize (if not done)
firebase init hosting

# Deploy
firebase deploy --only hosting
```

---

## 🔥 Firebase Configuration

### Required Firebase Services:

1. **Authentication**
   - Enable Email/Password authentication
   - Enable Phone authentication (optional)

2. **Firestore Database**
   - Create database in production mode
   - Deploy security rules from `firestore.rules`

3. **Storage**
   - Enable Firebase Storage
   - Deploy storage rules from `storage.rules`

4. **Cloud Messaging**
   - Enable Firebase Cloud Messaging
   - Configure for Android and iOS

5. **Hosting** (for web)
   - Enable Firebase Hosting
   - Deploy web app

### Creating Admin User:
1. Register a user through the app
2. Go to Firebase Console → Firestore Database
3. Find the user document in `users` collection
4. Set `isAdmin: true` in the user document
5. User can now login as admin

---

## 🐛 Troubleshooting

### Common Issues:

#### Issue 1: "Firebase not initialized"
**Solution:**
- Check if `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in correct location
- Verify Firebase project is properly configured
- Run `flutter clean` and `flutter pub get`

#### Issue 2: "Maps not showing"
**Solution:**
- Verify Google Maps API key is correctly added
- Check API key restrictions
- Ensure Maps SDK is enabled in Google Cloud Console

#### Issue 3: "Build failed"
**Solution:**
- Run `flutter doctor` to check for issues
- Update Flutter: `flutter upgrade`
- Clean build: `flutter clean`
- Get dependencies: `flutter pub get`

#### Issue 4: "Permission denied"
**Solution:**
- Check AndroidManifest.xml for required permissions
- Grant permissions manually in device settings
- For iOS, check Info.plist permissions

#### Issue 5: "APK installation failed"
**Solution:**
- Enable "Unknown Sources" in device settings
- Check if device has enough storage
- Try uninstalling previous version first
- Verify APK is not corrupted

#### Issue 6: "Web app not loading"
**Solution:**
- Check Firebase Hosting deployment
- Verify Firebase configuration in `firebase_options.dart`
- Clear browser cache
- Check browser console for errors

### Getting Help:
- Check Flutter documentation: https://flutter.dev/docs
- Check Firebase documentation: https://firebase.google.com/docs
- Review project README.md
- Check existing documentation files in project

---

## ✅ Installation Checklist

### For Developers:
- [ ] Flutter SDK installed and configured
- [ ] Firebase project created
- [ ] `google-services.json` added (Android)
- [ ] `GoogleService-Info.plist` added (iOS)
- [ ] Google Maps API key configured
- [ ] Firestore rules deployed
- [ ] Storage rules deployed
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App runs successfully on device/emulator

### For End Users:
- [ ] APK file downloaded or app installed from Play Store
- [ ] Permissions granted (Camera, Location, Storage, Notifications)
- [ ] Account registered or logged in
- [ ] App functions correctly

### For Administrators:
- [ ] Web app accessible
- [ ] Admin account created (`isAdmin: true`)
- [ ] Can login to admin dashboard
- [ ] All admin features accessible

---

## 📞 Support

For technical support or questions:
- Review project documentation
- Check Firebase Console for backend issues
- Review Flutter and Firebase official documentation

---

**Installation Complete! 🎉**

You're now ready to use the Barangay Report and Assistance System!


