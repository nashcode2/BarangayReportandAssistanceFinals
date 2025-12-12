import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Service for SMS and Email notifications
/// Note: Actual SMS/Email sending requires Cloud Functions backend
class CommunicationService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  /// Send SMS notification
  /// Requires Cloud Function: sendSMS
  static Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Call Cloud Function for SMS
      final result = await _functions.httpsCallable('sendSMS').call({
        'phoneNumber': phoneNumber,
        'message': message,
      });

      return result.data['success'] == true;
    } catch (e) {
      // Log error
      print('SMS sending failed: $e');
      return false;
    }
  }

  /// Send Email notification
  /// Requires Cloud Function: sendEmail
  static Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    String? htmlBody,
  }) async {
    try {
      // Call Cloud Function for Email
      final result = await _functions.httpsCallable('sendEmail').call({
        'to': to,
        'subject': subject,
        'body': body,
        'htmlBody': htmlBody,
      });

      return result.data['success'] == true;
    } catch (e) {
      // Log error
      print('Email sending failed: $e');
      return false;
    }
  }

  /// Send appointment reminder via SMS
  static Future<bool> sendAppointmentReminderSMS({
    required String phoneNumber,
    required String residentName,
    required DateTime appointmentDate,
    required String serviceType,
  }) async {
    final message =
        'Hi $residentName, this is a reminder for your appointment on '
        '${appointmentDate.toString().split(' ')[0]} at ${appointmentDate.toString().split(' ')[1].substring(0, 5)} '
        'for $serviceType. Barangay Office';

    return await sendSMS(phoneNumber: phoneNumber, message: message);
  }

  /// Send certificate ready notification via Email
  static Future<bool> sendCertificateReadyEmail({
    required String email,
    required String residentName,
    required String certificateType,
    required String downloadUrl,
  }) async {
    final subject = 'Your $certificateType is Ready';
    final htmlBody = '''
      <html>
        <body>
          <h2>Certificate Ready</h2>
          <p>Dear $residentName,</p>
          <p>Your $certificateType has been approved and is ready for download.</p>
          <p><a href="$downloadUrl">Download Certificate</a></p>
          <p>Thank you,<br>Barangay Office</p>
        </body>
      </html>
    ''';

    return await sendEmail(
      to: email,
      subject: subject,
      body: 'Your $certificateType is ready. Download link: $downloadUrl',
      htmlBody: htmlBody,
    );
  }

  /// Send report status update via SMS
  static Future<bool> sendReportStatusUpdateSMS({
    required String phoneNumber,
    required String residentName,
    required String reportType,
    required String status,
  }) async {
    final message =
        'Hi $residentName, your $reportType report status has been updated to $status. '
        'Check the app for details. Barangay Office';

    return await sendSMS(phoneNumber: phoneNumber, message: message);
  }

  /// Store notification in Firestore for tracking
  static Future<void> logNotification({
    required String userId,
    required String type, // 'sms', 'email'
    required String recipient,
    required String message,
    required bool success,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications_log').add({
        'userId': userId,
        'type': type,
        'recipient': recipient,
        'message': message,
        'success': success,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error silently
      print('Failed to log notification: $e');
    }
  }
}

/// Cloud Functions Setup Instructions:
/// 
/// 1. Install Firebase CLI: npm install -g firebase-tools
/// 2. Initialize Functions: firebase init functions
/// 3. Create functions/index.js:
/// 
/// const functions = require('firebase-functions');
/// const admin = require('firebase-admin');
/// const twilio = require('twilio'); // For SMS
/// const nodemailer = require('nodemailer'); // For Email
/// 
/// exports.sendSMS = functions.https.onCall(async (data, context) => {
///   // Implement SMS sending using Twilio
///   // Return { success: true/false }
/// });
/// 
/// exports.sendEmail = functions.https.onCall(async (data, context) => {
///   // Implement Email sending using nodemailer
///   // Return { success: true/false }
/// });
/// 
/// 4. Deploy: firebase deploy --only functions

