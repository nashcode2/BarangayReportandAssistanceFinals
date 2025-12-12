# Barangay Report & Assistance System

Modern Flutter app for residents and barangay admins: submit and track reports, request services, manage certificates, view announcements/events, and run admin operations on the web.

## ✨ Features
- **Residents (Mobile/Web)**: Login/Register, Dashboard stats, Report Issue (photo + location), My Reports tracking, Service Requests, Events & RSVP, Certificates (request/download), Emergency Assistance, Announcements, Reviews, AI Chat Assistant, Offline viewing.
- **Admins (Web)**: Admin Dashboard, Report Management, Certificate Management, Events Management, Service Requests Management, Resident Database, Announcements Management, Analytics/Charts, Push notifications on status updates.

## 🛠 Tech Stack
- **Flutter** (mobile + web), **Provider** (state management)
- **Firebase**: Auth, Firestore, Storage, Cloud Messaging, Hosting (web)
- **Maps/Location**: Google Maps / flutter_map, geolocator, geocoding
- **Others**: pdf/printing (certificates), fl_chart (analytics), sqflite (offline)

## 📦 Prerequisites
- Flutter SDK ≥ 3.0.0
- Firebase project (Auth, Firestore, Storage, FCM)
- Android Studio or VS Code with Flutter extensions
- Google Maps API key (for maps/location features)

## 🚀 Setup & Run
```bash
git clone <repo-url>
cd BARANGAY
flutter pub get
```

### Firebase config
- Android: place `android/app/google-services.json`
- iOS: place `ios/Runner/GoogleService-Info.plist`
- Web: ensure `lib/firebase_options.dart` has your web config
- Deploy rules: use `firestore.rules` and `storage.rules` in Firebase Console

### Maps API key
- Android: add to `android/app/src/main/AndroidManifest.xml`
- iOS: add to `ios/Runner/AppDelegate.swift`

### Run (pick your platform)
```bash
flutter run -d chrome       # Web
flutter run -d <device-id>  # Android/iOS
```

### Build installers
- APK: `flutter build apk --release`
- Web: `flutter build web --release` (output in `build/web`)

## 👤 Create an Admin Account
1) Register/login a user.
2) In Firebase Console → Firestore → `users` collection → open user doc.
3) Set `isAdmin: true` (Boolean). Re-login; admin dashboard will appear.

## 📂 Key Structure
```
lib/
  main.dart            # App entry, routes, providers
  screens/             # UI (user + admin)
  providers/           # State management
  services/            # Firebase, notifications, location, certificates
  widgets/             # Reusable UI components
  utils/               # Constants, themes, helpers
assets/                # Icons, images
firestore.rules        # Firestore security rules
storage.rules          # Storage security rules
```

## 📚 Helpful Docs in Repo
- `INSTALLATION_GUIDE.md` — Dev & user installation steps
- `USER_GUIDE.md` — Full user manual
- `BUILD_MOBILE_INSTALLER.md` — Build/distribute APK
- `VIDEO_PRESENTATION_SCRIPT.md` — 5–10 min presentation script
- `HOW_TO_RUN.md` — Detailed run instructions
- `ADMIN_WEB_SETUP.md` — Admin web notes

## 🐛 Troubleshooting
- Run `flutter clean && flutter pub get`
- Verify Firebase configs are in place
- Check Maps API key is set
- Deploy Firestore/Storage rules
- For web, hard refresh: Ctrl+Shift+R

## 🤝 Contributing
PRs are welcome. Please open an issue to discuss major changes.

## 📜 License
MIT License.
