# Certificate Status Update Fix

## Problem
Resident's certificate status was not updating from "pending" to "issued" after admin issues the certificate.

## Root Causes Identified
1. Stream listener might not be properly updating
2. `_isSubmitting` check was preventing stream updates
3. Loading state was blocking UI updates

## Fixes Applied

### 1. Fixed Stream Listener (`lib/providers/certificate_provider.dart`)
- Removed `_isSubmitting` check that was blocking updates
- Added `cancelOnError: false` to keep stream alive
- Improved loading state management
- Added debug logging

### 2. Enhanced Update Method (`lib/services/firebase_service.dart`)
- Added debug logging to track updates
- Ensured all fields are properly updated
- Better error handling

### 3. Improved UI (`lib/screens/user/my_certificates_screen.dart`)
- Fixed loading state display
- Better refresh handling
- Stream properly watches provider

## How It Works Now

1. **Resident Requests Certificate**
   - Status: "pending"
   - Stream listener is active

2. **Admin Approves Certificate**
   - Status updates to "approved"
   - Firestore document updated
   - Stream automatically detects change
   - Resident's view updates in real-time

3. **Admin Issues Certificate**
   - Status updates to "issued" immediately
   - Firestore document updated
   - Stream automatically detects change
   - Resident's view updates in real-time
   - PDF uploads in background

## Testing Checklist

- [ ] Resident requests certificate → Shows "pending"
- [ ] Admin approves → Resident sees "approved" automatically
- [ ] Admin issues → Resident sees "issued" automatically
- [ ] Pull to refresh works
- [ ] Download button appears for issued certificates
- [ ] Stream updates in real-time without manual refresh

## Debug Logging

Check console for:
- "User certificates updated: X certificates"
- "Updating certificate [id] with status: [status]"
- "Certificate [id] updated successfully"
- "Firestore stream update: X certificates for user [userId]"

If status is still not updating, check:
1. Firestore rules allow updates
2. Stream is properly subscribed
3. Certificate ID matches
4. User ID matches in query

