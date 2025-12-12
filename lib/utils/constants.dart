import 'package:flutter/material.dart';

/// Application-wide constants
class AppConstants {
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String reportsCollection = 'reports';
  static const String announcementsCollection = 'announcements';
  static const String emergencyContactsCollection = 'emergency_contacts';
  static const String reviewsCollection = 'reviews';
  static const String eventsCollection = 'events';
  static const String serviceRequestsCollection = 'service_requests';
  static const String notificationsCollection = 'notifications';
  static const String certificatesCollection = 'certificates';
  
  // Report Status
  static const String statusPending = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusResolved = 'Resolved';
  
  // Issue Types
  static const List<String> issueTypes = [
    'Garbage',
    'Streetlight',
    'Flooding',
    'Others',
  ];
  
  // Emergency Types
  static const String emergencyHealth = 'Health';
  static const String emergencyFire = 'Fire';
  static const String emergencyPolice = 'Police';
  
  // Storage Paths
  static const String reportPhotosPath = 'report_photos';
  static const String announcementImagesPath = 'announcement_images';
  static const String profileImagesPath = 'profile_images';
  static const String eventImagesPath = 'event_images';
  
  // Service Request Types
  static const List<String> serviceRequestTypes = [
    'Waste Collection',
    'Street Cleaning',
    'Tree Trimming',
    'Drainage Cleaning',
    'Document Request',
    'Other',
  ];
  
  // Event Types
  static const List<String> eventTypes = [
    'Meeting',
    'Festival',
    'Clean-up Drive',
    'Health Program',
    'Sports Event',
    'Community Gathering',
    'Other',
  ];
  
  // Map Configuration
  static const double defaultLatitude = 14.5995; // Default to Manila
  static const double defaultLongitude = 120.9842;
  static const double defaultZoom = 15.0;
}

/// Centralized color palette for the app UI
class AppColors {
  static const Color primary = Color(0xFF1F4CB7);
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color accent = Color(0xFFF97316);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color background = Color(0xFFF7F8FB);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF9CA3AF);
}

/// Common spacing helpers for consistent padding and margins
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: md, vertical: lg);
}

/// Quick helper for status → color mapping
class StatusColorMapper {
  static Color colorForStatus(String status) {
    switch (status) {
      case AppConstants.statusResolved:
        return AppColors.success;
      case AppConstants.statusInProgress:
        return AppColors.secondary;
      case AppConstants.statusPending:
      default:
        return AppColors.warning;
    }
  }
}

