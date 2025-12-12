# Quick Test: Admin Web Dashboard with Map

## Step-by-Step Test

### 1. Make sure you're running on WEB (Chrome)

```bash
# IMPORTANT: Run on Chrome, NOT mobile device
flutter run -d chrome
```

**Check:** Chrome browser should open, NOT your phone.

### 2. Login as Admin

1. You should see the login screen
2. Click "Login as Barangay Admin" at the bottom
3. Or go directly to admin login
4. Enter admin credentials:
   - Username: `admin` (or your admin username)
   - Password: Your admin password
   - **Note:** The system will use `admin@admin.barangay.com` format

### 3. What You Should See

After logging in as admin on **web browser**, you should see:

✅ **Web Admin Dashboard** with:
- **Sidebar on the left** with navigation options
- **"Reports Map"** should be selected by default (2nd option)
- **Map view on the right** showing:
  - Google Map
  - All reports as colored markers
  - Left sidebar with report list
  - Filter options

### 4. If You Don't See the Map

**Check these:**

1. **Are you on web?**
   - Run: `flutter run -d chrome`
   - NOT: `flutter run` (this might run on phone)

2. **Is your user an admin?**
   - Check Firestore: `users/{userId}` document
   - Field `isAdmin` should be `true`

3. **Do reports have locations?**
   - Reports need `latitude` and `longitude` fields
   - Check Firestore: `reports/{reportId}` documents

4. **Is Google Maps API key set?**
   - Edit `web/index.html`
   - Replace `YOUR_API_KEY` with your actual key

5. **Check browser console (F12)**
   - Look for errors
   - Check if maps API is loading

### 5. Navigation

The sidebar has these options:
- **Dashboard** (index 0) - Statistics overview
- **Reports Map** (index 1) - **MAP VIEW** ← This is what you want!
- **Reports** (index 2) - List view
- **Residents** (index 3)
- **Announcements** (index 4)
- **Analytics** (index 5)
- **Events** (index 6)
- **Service Requests** (index 7)

### 6. Map View Features

When you click "Reports Map" (or it's selected by default), you should see:

- **Left Sidebar:**
  - Filter chips (All, Pending, In Progress, Resolved)
  - List of reports with locations
  - Click any report to see it on map

- **Right Side (Map):**
  - Google Map
  - Colored markers:
    - 🟠 Orange = Pending
    - 🔵 Blue = In Progress
    - 🟢 Green = Resolved
  - Click marker to see report details
  - Map auto-fits to show all reports

---

## Troubleshooting

### "I see mobile interface instead of web"

**Solution:** You're running on mobile device. Run:
```bash
flutter run -d chrome
```

### "I see login screen but no admin option"

**Solution:** On login screen, scroll down and click "Login as Barangay Admin"

### "Map is blank/not loading"

**Solutions:**
1. Check Google Maps API key in `web/index.html`
2. Enable Maps JavaScript API in Google Cloud Console
3. Check browser console (F12) for errors
4. Make sure API key restrictions allow `localhost`

### "No reports showing on map"

**Solutions:**
1. Reports need `latitude` and `longitude` fields
2. Check Firestore: `reports` collection
3. Make sure reports have location data
4. Try creating a new report with location

### "I see web dashboard but no map"

**Solution:** Click "Reports Map" in the sidebar (2nd option)

---

## Expected Result

When everything works, you should see:

```
┌─────────────────────────────────────────────────┐
│  Admin Dashboard                    [Refresh] [X]│
├──────────┬──────────────────────────────────────┤
│ Dashboard│                                       │
│ 📍 Reports│    [Google Map with markers]         │
│   Map    │                                       │
│ Reports  │    [Filter: All | Pending | ...]     │
│ Residents│    [Report List]                      │
│ ...      │    [Selected Report Info Card]       │
└──────────┴──────────────────────────────────────┘
```

---

## Still Not Working?

1. **Check if you're on web:**
   ```dart
   // In your code, add debug print:
   print('Is Web: ${kIsWeb}');
   ```

2. **Check admin status:**
   ```dart
   // After login, check:
   print('Is Admin: ${authProvider.isAdmin}');
   ```

3. **Check reports:**
   - Open Firestore console
   - Check `reports` collection
   - Verify reports have `latitude` and `longitude`

4. **Check browser console:**
   - Press F12
   - Look for errors
   - Check Network tab for API calls

