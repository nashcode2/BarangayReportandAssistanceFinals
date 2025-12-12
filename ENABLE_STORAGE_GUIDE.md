# How to Enable Firebase Storage

If you can't find the "Enable Storage" option in Firebase Console, follow these steps:

## Method 1: Via Firebase Console (Recommended)

1. **Go to Firebase Console**
   - Open: https://console.firebase.google.com/project/barangayreportandassistance/overview

2. **Navigate to Storage**
   - In the left sidebar, look for **"Storage"** (it might be under "Build" section)
   - If you don't see it, click on **"Build"** in the left menu to expand it
   - Then click on **"Storage"**

3. **Enable Storage**
   - If Storage is not enabled, you'll see a **"Get started"** or **"Create bucket"** button
   - Click on it
   - Choose your storage location (select the closest region to your users, e.g., `us-central` or `asia-southeast1`)
   - Click **"Done"** or **"Enable"**

4. **After Storage is Enabled**
   - Once Storage is enabled, you can deploy the storage rules by running:
   ```bash
   firebase deploy --only storage
   ```

## Method 2: Direct Link

Try this direct link to your Storage page:
https://console.firebase.google.com/project/barangayreportandassistance/storage

If Storage is not enabled, you should see a "Get started" button on that page.

## Method 3: Via Google Cloud Console

1. Go to: https://console.cloud.google.com/storage/browser?project=barangayreportandassistance
2. If prompted, enable the Storage API
3. Then go back to Firebase Console and Storage should be available

## Troubleshooting

- **Can't see Storage in sidebar?** 
  - Make sure you're logged in with the correct account
  - Try refreshing the page
  - Check if you have the correct project selected (top left dropdown)

- **Storage option is grayed out?**
  - You might need to upgrade your Firebase plan (Storage is available on all plans, including Spark/free tier)
  - Check if there are any billing issues

## After Enabling Storage

Once Storage is enabled, deploy the storage rules:

```bash
firebase deploy --only storage
```

This will apply the security rules that allow authenticated users to upload report photos.

