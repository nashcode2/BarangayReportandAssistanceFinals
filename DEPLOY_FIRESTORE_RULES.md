# Deploy Firestore Security Rules

## Issue
If you're getting a `permission-denied` error when creating certificate requests, the Firestore security rules need to be deployed to Firebase.

## Solution

### Option 1: Using Firebase CLI (Recommended)

1. **Install Firebase CLI** (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase** (if not already done):
   ```bash
   firebase init firestore
   ```
   - Select your Firebase project
   - Use the existing `firestore.rules` file

4. **Deploy the rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

### Option 2: Using Firebase Console (Web)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** → **Rules** tab
4. Copy the contents of `firestore.rules` file
5. Paste into the rules editor
6. Click **Publish**

### Option 3: Quick Test (Development Only)

⚠️ **WARNING: Only for development/testing!**

If you need to test quickly and are in development mode, you can temporarily use these permissive rules:

```javascript
// Certificates collection - TEMPORARY DEVELOPMENT RULES
match /certificates/{certificateId} {
  allow read, write: if request.auth != null;
}
```

**Remember to replace with proper rules before production!**

## Verify Rules Are Deployed

After deploying, try creating a certificate request again. The permission error should be resolved.

## Current Rules Summary

The deployed rules allow:
- ✅ **Read**: Authenticated users can read their own certificates; admins can read all
- ✅ **Create**: Authenticated users can create certificates with their own userId and status 'pending'
- ✅ **Update**: Only admins can update certificates
- ✅ **Delete**: Only admins can delete certificates

