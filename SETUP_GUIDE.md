# Barangay Report and Assistance - Setup Guide

## Prerequisites

1. **Flutter SDK**: Install Flutter (>=3.0.0) from [flutter.dev](https://flutter.dev)
2. **Firebase Account**: Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
3. **Google Maps API Key**: Get from [Google Cloud Console](https://console.cloud.google.com)

## Step-by-Step Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add Project"
3. Follow the setup wizard

#### Add Android App
1. In Firebase Console, click "Add App" → Android
2. Register app with package name (e.g., `com.barangay.reportassistance`)
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

#### Add iOS App
1. In Firebase Console, click "Add App" → iOS
2. Register app with bundle ID
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

#### Enable Firebase Services
- **Authentication**: Enable Email/Password sign-in
- **Firestore Database**: Create database in test mode (update rules for production)
- **Storage**: Enable Firebase Storage
- **Cloud Messaging**: Enable for push notifications

### 3. Google Maps Setup

#### Get API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a project or select existing
3. Enable "Maps SDK for Android" and "Maps SDK for iOS"
4. Create API key
5. Restrict API key (recommended for production)

#### Configure Android
Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_ANDROID_API_KEY"/>
    </application>
</manifest>
```

#### Configure iOS
Edit `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_IOS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 4. Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to mark report locations</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos for reports</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select photos for reports</string>
```

### 5. Firestore Security Rules

Update Firestore rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Reports collection
    match /reports/{reportId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
      allow delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Announcements collection
    match /announcements/{announcementId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

### 6. Storage Security Rules

Update Storage rules in Firebase Console:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /report_photos/{reportId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /announcement_images/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        firebase.auth != null && 
        firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

### 7. Run the App

```bash
flutter run
```

## Creating Admin Users

To create an admin user:

1. Register a regular user through the app
2. In Firebase Console → Firestore → `users` collection
3. Find the user document
4. Set `isAdmin` field to `true`

Or use Firebase Admin SDK:

```javascript
// In Firebase Functions or Admin SDK
admin.firestore().collection('users').doc(userId).update({
  isAdmin: true
});
```

## Testing

### Test User Flow
1. Register a new account
2. Login
3. Submit a report with photo and location
4. View reports in "My Reports"
5. View announcements

### Test Admin Flow
1. Create admin user (see above)
2. Login with admin credentials
3. Access admin dashboard
4. Manage reports, residents, and announcements
5. View analytics

## Troubleshooting

### Firebase Not Initialized
- Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in correct locations
- Run `flutter clean` and `flutter pub get`

### Maps Not Showing
- Verify API key is correct
- Check API key restrictions
- Ensure Maps SDK is enabled in Google Cloud Console

### Location Not Working
- Check permissions in device settings
- Verify location permissions in manifest/Info.plist

### Image Upload Fails
- Check Firebase Storage rules
- Verify storage is enabled in Firebase Console
- Check file size limits

## Production Checklist

- [ ] Update Firestore security rules for production
- [ ] Update Storage security rules for production
- [ ] Restrict Google Maps API key
- [ ] Enable Firebase App Check
- [ ] Set up proper error logging
- [ ] Configure push notification certificates (iOS)
- [ ] Test on both Android and iOS devices
- [ ] Set up CI/CD pipeline
- [ ] Configure app signing for release builds

## Additional Notes

- The app uses Provider for state management
- All data is stored in Firebase (Firestore + Storage)
- Push notifications require additional setup for production
- Google/Facebook sign-in requires additional package setup (currently placeholder)

