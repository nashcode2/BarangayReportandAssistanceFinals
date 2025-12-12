# Barangay Report and Assistance Mobile Application

A comprehensive Flutter mobile application for managing barangay reports, emergency assistance, and announcements.

## Features

### User Side
- **Login/Register**: Email/Phone authentication
- **Home/Dashboard**: Quick access to all features with personalized stats
- **Report Issue**: Submit issues with photos, location, and descriptions
- **My Reports**: View and track submitted reports with real-time status updates
- **Emergency Assistance**: Quick access to Health, Fire, and Police services
- **Announcements**: View barangay announcements with images
- **Resident Reviews**: Write and view reviews with star ratings (1-5 stars)
- **Events**: View and RSVP to barangay events (Upcoming, Ongoing, All)
- **Service Requests**: Request and track barangay services (Waste Collection, Street Cleaning, etc.)
- **AI Chat Assistant**: 24/7 chatbot for help and FAQs
- **Push Notifications**: Real-time notifications for status changes
- **Offline Support**: View cached data when offline

### Admin Side
- **Admin Dashboard**: Overview with statistics and quick links
- **Report Management**: Manage and update report statuses with filters
- **Resident Database**: Search and manage resident information
- **Announcements Management**: Create and manage announcements
- **Events Management**: Create, edit, and manage barangay events with RSVP tracking
- **Service Requests Management**: Manage and schedule service requests with status updates
- **Advanced Analytics**: Visual analytics with pie charts and bar charts
- **Push Notifications**: Automatic notifications for status changes

## Setup Instructions

1. **Install Flutter**: Ensure Flutter SDK is installed (>=3.0.0)

2. **Firebase Setup**:
   - Create a Firebase project at https://console.firebase.google.com
   - Add Android and iOS apps to your Firebase project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Configure Maps** (for location features):
   - Get Google Maps API key from https://console.cloud.google.com
   - Add to `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_API_KEY"/>
     ```
   - Add to `ios/Runner/AppDelegate.swift`:
     ```swift
     GMSServices.provideAPIKey("YOUR_API_KEY")
     ```

5. **Run the App**:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart
├── models/          # Data models
├── screens/         # UI screens
│   ├── user/       # User-side screens
│   └── admin/      # Admin-side screens
├── widgets/         # Reusable widgets
├── services/        # Backend services
├── providers/       # State management
└── utils/           # Utilities and constants
```

## Notes

- Ensure proper permissions are granted for camera, location, and storage
- Configure push notifications in Firebase Console
- Update Firebase rules for Firestore and Storage security

