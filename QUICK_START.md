# 🚀 Quick Start Guide - Presentation Ready

## ⚡ 5-Minute Setup

### Step 1: Deploy Firestore Rules (CRITICAL!)
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: `barangayreportandassistance`
3. Firestore Database → Rules tab
4. Copy ALL content from `firestore.rules` file
5. Paste and click **Publish**

### Step 2: Create Admin Account
1. Register a user through the app
2. In Firebase Console → Firestore → `users` collection
3. Find the user document
4. Edit document → Add field: `isAdmin` = `true` (boolean)
5. Save

### Step 3: Add Test Data
**As Admin:**
- Create 2 announcements
- Create 1 event

**As User:**
- Submit 1 report
- Submit 1 service request
- Write 1 review

### Step 4: Test Run
```bash
flutter run
```

## 🎯 Presentation Demo Order

1. **User Login** → Show home screen
2. **Submit Report** → Show photo, location, submit
3. **View Events** → Show list, RSVP to one
4. **Request Service** → Fill form, submit
5. **Write Review** → Rate and comment
6. **Chatbot** → Ask questions
7. **Admin Login** → Show dashboard
8. **Manage Reports** → Update status
9. **Create Event** → Show form
10. **Analytics** → Show charts

## ✅ Final Checks

- [ ] Firestore rules deployed
- [ ] Admin account created
- [ ] Test data added
- [ ] App runs without errors
- [ ] All features accessible
- [ ] Charts display correctly

## 🎤 You're Ready to Present!

Good luck! 🚀
