# Troubleshooting White Screen on Web

## Quick Fixes to Try

### 1. **Comment Out Google Maps Script** (Already Done)
The Google Maps API script with invalid key might be blocking the page. I've commented it out in `web/index.html`.

### 2. **Check Browser Console**
Press **F12** in Chrome and check:
- **Console tab** - Look for red errors
- **Network tab** - Check if files are loading
- **Application tab** - Check if Firebase is initialized

### 3. **Clear Browser Cache**
- Press **Ctrl+Shift+Delete**
- Clear cached images and files
- Or use **Incognito mode** (Ctrl+Shift+N)

### 4. **Check Terminal Output**
Look for error messages in the terminal where you ran `flutter run -d chrome`

### 5. **Try Hard Refresh**
- Press **Ctrl+Shift+R** (Windows) or **Cmd+Shift+R** (Mac)
- This forces a full reload

## Common Issues

### Issue 1: Firebase Not Initialized
**Symptoms:** White screen, no errors
**Solution:** Check Firebase configuration in `firebase_options.dart`

### Issue 2: Google Maps API Error
**Symptoms:** White screen, console shows Maps API errors
**Solution:** Maps script is already commented out. Uncomment only when you have a valid API key.

### Issue 3: JavaScript Errors
**Symptoms:** White screen, console shows JS errors
**Solution:** Check browser console (F12) for specific errors

### Issue 4: CORS Issues
**Symptoms:** Network errors in console
**Solution:** Make sure Firebase is configured for web

## Debug Steps

1. **Open Browser Console (F12)**
   - Look for any red errors
   - Check if `flutter_bootstrap.js` loaded

2. **Check Network Tab**
   - See if all files are loading (200 status)
   - Check if any files failed to load (404, 500, etc.)

3. **Check Terminal**
   - Look for "Firebase initialized successfully"
   - Look for "Running on web - skipping Firebase Messaging"
   - Look for any error messages

4. **Try Minimal Test**
   - The app should at least show "Loading..." text
   - If you see nothing, it's a JavaScript/Flutter initialization issue

## Expected Console Output

When working correctly, you should see in browser console:
```
Firebase initialized successfully
Running on web - skipping Firebase Messaging
AuthWrapper: Web platform detected
```

## Still Not Working?

1. **Check Firebase Web Configuration:**
   - Verify `firebase_options.dart` has web config
   - Check Firebase project settings

2. **Try Fresh Build:**
   ```bash
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

3. **Check Flutter Web Support:**
   ```bash
   flutter doctor
   ```
   Make sure web is enabled

4. **Try Different Browser:**
   - Try Firefox or Edge instead of Chrome
   - Sometimes browser extensions cause issues

## What Should Happen

1. Chrome opens
2. You see "Loading..." text (not just white)
3. Then login screen appears
4. Or dashboard if already logged in

If you see "Loading..." but it never changes, the issue is with Firebase Auth or data loading.

