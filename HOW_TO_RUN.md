# How to Run: Admin on Web & Resident on Phone

## Quick Overview

- **Admin Interface**: Runs in web browser (Chrome, Firefox, etc.)
- **Resident Interface**: Runs on mobile phone (Android/iOS)

The app automatically detects the platform and shows the appropriate interface.

---

## Step 1: Setup Google Maps API Key (Required for Web)

Before running the web version, you need to configure Google Maps:

1. Get API key from [Google Cloud Console](https://console.cloud.google.com)
2. Enable **Maps JavaScript API**
3. Edit `web/index.html` and replace `YOUR_API_KEY`:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_ACTUAL_API_KEY&libraries=places"></script>
```

---

## Step 2: Run Admin Interface on Web

### Option A: Using Flutter Run Command

```bash
# Navigate to project directory
cd BARANGAY

# Run on Chrome (web browser)
flutter run -d chrome
```

This will:
- Open Chrome browser automatically
- Show the login screen
- If you login as admin → Shows web dashboard with map view

### Option B: Build and Serve

```bash
# Build for web
flutter build web

# Serve locally (requires Python or Node.js)
# Using Python:
cd build/web
python -m http.server 8000

# Then open: http://localhost:8000
```

---

## Step 3: Run Resident Interface on Phone

### For Android Phone:

```bash
# Connect your Android phone via USB
# Enable USB debugging on phone

# List available devices
flutter devices

# Run on connected Android device
flutter run -d <device-id>
```

### For iOS Phone (Mac only):

```bash
# Connect your iPhone via USB
# Trust the computer on iPhone

# List available devices
flutter devices

# Run on connected iOS device
flutter run -d <device-id>
```

### For Android Emulator:

```bash
# Start Android emulator first
# Then run:
flutter run
```

### For iOS Simulator (Mac only):

```bash
# Open iOS Simulator
open -a Simulator

# Run Flutter app
flutter run
```

---

## Step 4: Login Instructions

### Login as Admin (Web):

1. Open the app in Chrome/web browser
2. You'll see the login screen
3. Click "Admin Login" or navigate to admin login
4. Use admin credentials:
   - **Email format**: `username@admin.barangay.com`
   - **Password**: Your admin password
5. After login → You'll see the **Web Admin Dashboard** with:
   - Sidebar navigation
   - Statistics cards
   - **Reports Map View** (click "Reports Map" in sidebar)
   - All admin features

### Login as Resident (Mobile):

1. Open the app on your phone
2. You'll see the regular login screen
3. Use resident credentials:
   - **Email**: `resident@example.com` (or your registered email)
   - **Password**: Your password
4. After login → You'll see the **Mobile Home Screen** with:
   - Report Issue button
   - Request Service button
   - View Reports
   - Announcements
   - All resident features

---

## Step 5: Testing Both Interfaces

### Test Admin on Web:

```bash
# Terminal 1: Run web version
flutter run -d chrome
```

Then:
- Login with admin account
- You should see the web dashboard
- Click "Reports Map" in sidebar to see map view
- All reports with locations will show as markers

### Test Resident on Phone:

```bash
# Terminal 2: Run mobile version
flutter run -d <your-phone-id>
```

Then:
- Login with resident account
- You should see the mobile home screen
- Can report issues, request services, etc.

---

## Platform Detection

The app automatically detects where it's running:

| Platform | User Type | Interface Shown |
|----------|-----------|----------------|
| **Web Browser** | Admin | Web Dashboard (with map) |
| **Web Browser** | Resident | Mobile Interface (responsive) |
| **Mobile Phone** | Admin | Mobile Admin Dashboard |
| **Mobile Phone** | Resident | Mobile Home Screen |

---

## Troubleshooting

### Maps Not Showing on Web:

1. **Check API Key**: Make sure you replaced `YOUR_API_KEY` in `web/index.html`
2. **Enable API**: Verify Maps JavaScript API is enabled in Google Cloud Console
3. **Check Console**: Open browser DevTools (F12) → Console tab → Look for errors
4. **API Restrictions**: Make sure API key restrictions allow `localhost` for development

### Admin Not Seeing Web Dashboard:

1. **Check Platform**: Make sure you're running in a web browser, not mobile emulator
2. **Check User**: Verify the user has `isAdmin: true` in Firestore
3. **Clear Cache**: Try clearing browser cache or use incognito mode

### Resident Not Seeing Mobile Interface:

1. **Check Platform**: Make sure you're running on a phone/emulator, not web
2. **Check User**: Verify the user has `isAdmin: false` in Firestore

---

## Development Workflow

### Run Both Simultaneously:

**Terminal 1 (Web - Admin):**
```bash
flutter run -d chrome
```

**Terminal 2 (Mobile - Resident):**
```bash
flutter run -d <phone-id>
```

This allows you to test both interfaces at the same time!

---

## Quick Commands Reference

```bash
# List all available devices
flutter devices

# Run on Chrome (web)
flutter run -d chrome

# Run on specific device
flutter run -d <device-id>

# Run on first available device
flutter run

# Build web for production
flutter build web

# Hot reload (while app is running)
Press 'r' in terminal

# Hot restart (while app is running)
Press 'R' in terminal
```

---

## Expected Results

### ✅ Admin on Web Should Show:
- Web-optimized dashboard with sidebar
- Statistics cards at top
- "Reports Map" option in sidebar
- Interactive map with all report markers
- Desktop-friendly layout

### ✅ Resident on Phone Should Show:
- Mobile home screen
- Bottom navigation bar
- Report Issue button
- Request Service button
- Mobile-optimized interface

---

## Need Help?

- Check `WEB_SETUP.md` for Google Maps configuration
- Check `SETUP_GUIDE.md` for Firebase setup
- Check browser console (F12) for errors
- Check Flutter logs in terminal

