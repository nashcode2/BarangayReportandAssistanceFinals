# Complete Certificate Flow - Resident Request to Download

## Flow Overview

1. **Resident Requests Certificate**
   - Goes to "My Certificates" → "Request Certificate"
   - Fills out form (type, purpose, address)
   - Submits request
   - Status: **PENDING**

2. **Admin Approves Certificate**
   - Admin sees request in "Certificate Management"
   - Clicks "Approve Certificate"
   - Status updates to: **APPROVED**
   - Resident's view updates automatically

3. **Admin Issues Certificate**
   - Admin clicks "Issue Certificate (Generate PDF)"
   - PDF is generated (fast, no QR code)
   - Status updates to: **ISSUED** immediately
   - PDF uploads in background
   - Resident's view updates automatically
   - **Force refresh ensures resident sees update**

4. **Resident Downloads Certificate**
   - Resident opens "My Certificates"
   - Sees certificate with status: **ISSUED**
   - Green banner: "Certificate is ready for download"
   - Clicks "Download Certificate PDF" button
   - PDF opens/downloads

## Key Features

✅ **Real-time Status Updates**
- Stream listener automatically updates resident's view
- Force refresh after admin actions ensures immediate update
- Status badge shows current state (PENDING/APPROVED/ISSUED/REJECTED)

✅ **Download Options**
- If PDF is uploaded: Direct download from Firebase Storage
- If PDF not uploaded yet: Generate on-demand
- Always works, even if upload is slow

✅ **Visual Indicators**
- Status badge with color coding
- Green success banner when issued
- Clear download button

## Troubleshooting

If resident doesn't see "ISSUED" status:

1. **Check Console Logs** (F12 → Console)
   - Look for: "Triggering immediate refresh for user: [userId]"
   - Look for: "Stream received X certificates"
   - Look for: "Certificate [id]: status=issued"

2. **Manual Refresh**
   - Click refresh button (top right)
   - Or pull down to refresh

3. **Verify in Firestore**
   - Check Firebase Console
   - Verify certificate document has `status: "issued"`
   - Verify `userId` matches resident's ID

4. **Check Firestore Rules**
   - Ensure rules allow resident to read their certificates
   - Rules should allow: `resource.data.userId == request.auth.uid`

## Current Implementation

- ✅ Certificate request creation
- ✅ Admin approval workflow
- ✅ Admin issuance with PDF generation
- ✅ Force refresh after updates
- ✅ Real-time stream updates
- ✅ Download functionality (URL or on-demand)
- ✅ Status indicators
- ✅ Error handling

The system is fully functional. The force refresh ensures residents see updates immediately.

