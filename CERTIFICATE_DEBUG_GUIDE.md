# Certificate Debug Guide

## Issue: Certificate Still Pending / No Certificate Showing

### Step 1: Check Browser Console (F12)

When you:
1. Request a certificate (as resident)
2. Approve it (as admin)
3. Check "My Certificates" (as resident)

Look for these console messages:

**When requesting:**
- "Creating certificate request..."
- "Certificate request created successfully"

**When approving:**
- "=== APPROVING CERTIFICATE ==="
- "Certificate ID: [id]"
- "Updating status to: approved"
- "Certificate updated in Firestore"
- "Triggering immediate refresh for user: [userId]"

**When viewing (resident):**
- "=== Setting up NEW stream listener for user: [userId] ==="
- "Stream snapshot received: X documents"
- "Document [id]: status=approved, userId=[userId]"
- "Stream received X certificates for user: [userId]"

### Step 2: Check Firestore Console

1. Go to Firebase Console → Firestore Database
2. Open the `certificates` collection
3. Find your certificate document
4. Verify:
   - `userId` matches the resident's user ID
   - `status` is "approved" (not "pending")
   - `createdAt` exists
   - All fields are present

### Step 3: Common Issues

#### Issue A: Certificate Not Created
**Symptoms:** No certificate in Firestore
**Fix:** Check Firestore rules allow creation

#### Issue B: Status Not Updating
**Symptoms:** Certificate exists but status is still "pending"
**Fix:** 
- Check admin has permission to update
- Check Firestore rules allow updates
- Verify `updateCertificate` is being called

#### Issue C: Query Not Finding Certificates
**Symptoms:** Certificate exists in Firestore but not showing in app
**Fix:**
- Verify `userId` in certificate matches logged-in user
- Check console for query errors
- Verify Firestore rules allow reading

#### Issue D: Stream Not Updating
**Symptoms:** Status updates in Firestore but UI doesn't refresh
**Fix:**
- Check console for stream errors
- Try manual refresh (refresh button)
- Check if stream listener is active

### Step 4: Manual Test

1. **As Resident:**
   - Request a certificate
   - Note the certificate ID from console
   - Go to "My Certificates"
   - Should see certificate with "pending" status

2. **As Admin:**
   - Go to Certificate Management
   - Find the certificate
   - Click "Approve"
   - Check console for update messages

3. **As Resident:**
   - Go back to "My Certificates"
   - Click refresh button
   - Should see "approved" status within 3 seconds

### Step 5: If Still Not Working

Check these files:
- `lib/services/firebase_service.dart` - `getUserCertificates` method
- `lib/providers/certificate_provider.dart` - `loadUserCertificates` method
- `lib/screens/user/my_certificates_screen.dart` - `_loadCertificates` method
- `firestore.rules` - Security rules

### Quick Fixes Applied

1. ✅ Removed `orderBy` from query (no index required)
2. ✅ Added manual sorting in code
3. ✅ Added periodic refresh (every 3 seconds)
4. ✅ Added detailed logging
5. ✅ Fixed missing `firebaseUser` variable

### Next Steps

If certificates still don't show:
1. Share console output (F12 → Console)
2. Share Firestore document data
3. Check if userId matches between certificate and logged-in user

