# 📍 Where to View the New Features

## 🎯 Quick Summary

We added **3 major capstone features**:
1. ✅ **Certificate Management System** - Request and manage barangay certificates
2. ✅ **Data Export System** - Export reports and analytics to CSV
3. ✅ **Advanced Analytics** - Enhanced analytics with export functionality

---

## 📁 New Files Created

### Certificate Management:
```
lib/
├── providers/
│   └── certificate_provider.dart          ← NEW: State management
├── screens/
│   ├── user/
│   │   ├── certificate_request_screen.dart    ← NEW: Request certificate
│   │   └── my_certificates_screen.dart        ← NEW: View my certificates
│   └── admin/
│       ├── certificate_management_screen.dart ← NEW: Admin management
│       └── certificate_detail_admin_screen.dart ← NEW: Approve/Reject
└── services/
    └── export_service.dart                ← NEW: CSV export service
```

### Modified Files:
- `lib/services/firebase_service.dart` - Added certificate methods
- `lib/services/notification_service.dart` - Added certificate notifications
- `lib/screens/admin/analytics_screen.dart` - Added export button
- `firestore.rules` - Added certificate security rules
- `lib/utils/constants.dart` - Added certificatesCollection

---

## 🚀 How to Access the New Features

### **Option 1: Direct Navigation (Current - Works Now)**

You can navigate directly using MaterialPageRoute:

#### For Users (Mobile):
```dart
// From any screen, navigate to:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const MyCertificatesScreen(),
  ),
);

// Or to request:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const CertificateRequestScreen(),
  ),
);
```

#### For Admins (Web):
```dart
// From admin dashboard:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const CertificateManagementScreen(),
  ),
);

// Analytics with export (already accessible):
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const AnalyticsScreen(),
  ),
);
```

---

### **Option 2: Add Routes (Recommended - Better Integration)**

Add to `lib/main.dart`:

#### Step 1: Add CertificateProvider
```dart
import 'providers/certificate_provider.dart';

// In MultiProvider providers list (around line 78-86):
ChangeNotifierProvider(create: (_) => CertificateProvider()),
```

#### Step 2: Add Routes
```dart
// In MaterialApp routes (around line 92-97):
routes: {
  '/login': (context) => const LoginScreen(),
  '/admin-login': (context) => const AdminLoginScreen(),
  '/home': (context) => const HomeScreen(),
  '/admin-dashboard': (context) => const AdminDashboardScreen(),
  
  // NEW ROUTES:
  '/certificate_request': (context) => const CertificateRequestScreen(),
  '/my_certificates': (context) => const MyCertificatesScreen(),
  '/certificate_management': (context) => const CertificateManagementScreen(),
},
```

#### Step 3: Add Imports
```dart
// Add to imports section (around line 17-22):
import 'screens/user/certificate_request_screen.dart';
import 'screens/user/my_certificates_screen.dart';
import 'screens/admin/certificate_management_screen.dart';
```

---

### **Option 3: Add Navigation from Home Screen**

#### For Users - Add to `lib/screens/user/home_screen.dart`:

Find the `_QuickActions` widget (around line 117) and add:

```dart
// Add certificate option in quick actions or create new section:

// Option A: Add to existing quick actions
ListTile(
  leading: Icon(Icons.description_rounded, color: AppColors.primary),
  title: Text('My Certificates'),
  subtitle: Text('View and request certificates'),
  trailing: Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () => Navigator.pushNamed(context, '/my_certificates'),
),
```

Or add a new section after announcements:

```dart
// Around line 160, add:
_SectionHeader(
  title: 'Certificates',
  actionLabel: 'View all',
  onActionTap: () => Navigator.pushNamed(context, '/my_certificates'),
),
const SizedBox(height: 12),
// Add certificate cards here
```

#### For Admins - Add to `lib/screens/admin/admin_dashboard_screen.dart`:

Find the Quick Links section (around line 130) and add:

```dart
_buildQuickLinkButton(
  context,
  'Certificates',
  Icons.description_rounded,
  Colors.orange,
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CertificateManagementScreen(),
      ),
    );
  },
),
```

---

## 📊 Where Each Feature is Located

### 1. Certificate Management System

**User Features:**
- **Request Certificate**: `lib/screens/user/certificate_request_screen.dart`
  - Navigate to: `/certificate_request` or use MaterialPageRoute
  - Access from: Home screen (after adding navigation)

- **My Certificates**: `lib/screens/user/my_certificates_screen.dart`
  - Navigate to: `/my_certificates` or use MaterialPageRoute
  - Shows: All user's certificate requests with status
  - Features: Download issued certificates, view rejection reasons

**Admin Features:**
- **Certificate Management**: `lib/screens/admin/certificate_management_screen.dart`
  - Navigate to: `/certificate_management` or use MaterialPageRoute
  - Shows: All certificate requests with filters
  - Access from: Admin dashboard (after adding navigation)

- **Certificate Detail**: `lib/screens/admin/certificate_detail_admin_screen.dart`
  - Opens when clicking a certificate in management screen
  - Features: Approve, Issue (generate PDF), Reject

---

### 2. Data Export System

**Location**: `lib/services/export_service.dart`

**Access Points:**
- **Analytics Screen**: `lib/screens/admin/analytics_screen.dart`
  - Look for: Download icon (📥) in the app bar
  - Click to: Export reports CSV or analytics report
  - Navigate to: Admin Dashboard → Analytics

**Export Functions Available:**
- `exportReportsToCSV()` - Export all reports
- `exportCertificatesToCSV()` - Export certificates
- `exportServiceRequestsToCSV()` - Export service requests
- `exportEventsToCSV()` - Export events
- `generateAnalyticsReport()` - Generate summary report

---

### 3. Advanced Analytics

**Location**: `lib/screens/admin/analytics_screen.dart`

**Access:**
- Navigate to: Admin Dashboard → Analytics
- Or directly: `Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()))`

**Features:**
- ✅ Pie chart for issue type distribution
- ✅ Bar chart for status distribution
- ✅ Report statistics
- ✅ **NEW**: Export button in app bar (download icon)
- ✅ **NEW**: Export to CSV functionality

---

## 🧪 Testing the Features

### Test Certificate System:

1. **As User:**
   ```dart
   // Navigate to request screen
   Navigator.push(
     context,
     MaterialPageRoute(builder: (_) => const CertificateRequestScreen()),
   );
   ```

2. **As Admin:**
   ```dart
   // Navigate to management screen
   Navigator.push(
     context,
     MaterialPageRoute(builder: (_) => const CertificateManagementScreen()),
   );
   ```

### Test Data Export:

1. **Go to Analytics:**
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
   );
   ```

2. **Click Export Button** (📥 icon in app bar)

3. **Choose Export Option:**
   - Export Reports (CSV)
   - Export Analytics Report

---

## 📝 Quick Integration Checklist

- [ ] Add CertificateProvider to `main.dart` providers
- [ ] Add certificate routes to `main.dart`
- [ ] Add certificate imports to `main.dart`
- [ ] Add navigation from user home screen
- [ ] Add navigation from admin dashboard
- [ ] Test certificate request flow
- [ ] Test admin approval flow
- [ ] Test export functionality

---

## 🎯 Current Status

✅ **All Features Implemented**
- Certificate Management: ✅ Complete
- Data Export: ✅ Complete  
- Advanced Analytics: ✅ Complete

⏳ **Integration Needed**
- Add provider to main.dart
- Add routes
- Add navigation links

---

## 💡 Quick Access Commands

**In your code, you can test immediately:**

```dart
// Test certificate request (user)
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const CertificateRequestScreen()),
);

// Test certificate management (admin)
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const CertificateManagementScreen()),
);

// Test analytics with export (admin)
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
);
```

---

**All features are ready! Just need to add navigation links to make them easily accessible from the UI.** 🚀

