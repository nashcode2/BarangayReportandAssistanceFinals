import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/report_model.dart';
import '../models/certificate_model.dart';
import '../models/service_request_model.dart';
import '../models/event_model.dart';

/// Service for exporting data to CSV and generating reports
class ExportService {
  /// Export reports to CSV
  static String exportReportsToCSV(List<ReportModel> reports) {
    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln('ID,User Name,Issue Type,Description,Status,Address,Latitude,Longitude,Created At,Updated At,Assigned Staff');
    
    // CSV Rows
    for (final report in reports) {
      buffer.writeln([
        report.id,
        _escapeCSV(report.userName),
        _escapeCSV(report.issueType),
        _escapeCSV(report.description),
        _escapeCSV(report.status),
        _escapeCSV(report.address ?? ''),
        report.latitude?.toString() ?? '',
        report.longitude?.toString() ?? '',
        DateFormat('yyyy-MM-dd HH:mm:ss').format(report.createdAt),
        report.updatedAt != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(report.updatedAt!)
            : '',
        _escapeCSV(report.assignedStaffName ?? ''),
      ].join(','));
    }
    
    return buffer.toString();
  }

  /// Export certificates to CSV
  static String exportCertificatesToCSV(List<CertificateModel> certificates) {
    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln('ID,User Name,Certificate Type,Status,Purpose,Address,Issued Date,Issued By,PDF URL');
    
    // CSV Rows
    for (final cert in certificates) {
      buffer.writeln([
        cert.id,
        _escapeCSV(cert.userName),
        _escapeCSV(CertificateTypes.getDisplayName(cert.certificateType)),
        _escapeCSV(cert.status),
        _escapeCSV(cert.purpose ?? ''),
        _escapeCSV(cert.data['address'] ?? ''),
        DateFormat('yyyy-MM-dd').format(cert.issuedDate),
        _escapeCSV(cert.issuedByName),
        cert.pdfUrl ?? '',
      ].join(','));
    }
    
    return buffer.toString();
  }

  /// Export service requests to CSV
  static String exportServiceRequestsToCSV(List<ServiceRequestModel> requests) {
    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln('ID,User Name,Service Type,Description,Status,Preferred Date,Scheduled Date,Address,Created At');
    
    // CSV Rows
    for (final request in requests) {
      buffer.writeln([
        request.id,
        _escapeCSV(request.userName),
        _escapeCSV(request.serviceType),
        _escapeCSV(request.description),
        _escapeCSV(request.status),
        DateFormat('yyyy-MM-dd').format(request.preferredDate),
        request.scheduledDate != null
            ? DateFormat('yyyy-MM-dd').format(request.scheduledDate!)
            : '',
        _escapeCSV(request.address ?? ''),
        DateFormat('yyyy-MM-dd HH:mm:ss').format(request.createdAt),
      ].join(','));
    }
    
    return buffer.toString();
  }

  /// Export events to CSV
  static String exportEventsToCSV(List<EventModel> events) {
    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln('ID,Title,Description,Event Type,Start Date,End Date,Location,RSVP Count,Status');
    
    // CSV Rows
    for (final event in events) {
      buffer.writeln([
        event.id,
        _escapeCSV(event.title),
        _escapeCSV(event.description),
        _escapeCSV(event.eventType),
        DateFormat('yyyy-MM-dd HH:mm:ss').format(event.startDate),
        DateFormat('yyyy-MM-dd HH:mm:ss').format(event.endDate),
        _escapeCSV(event.location ?? ''),
        event.rsvpUserIds.length.toString(),
        event.isActive ? 'Active' : 'Inactive',
      ].join(','));
    }
    
    return buffer.toString();
  }

  /// Generate analytics summary report
  static String generateAnalyticsReport({
    required Map<String, int> reportStats,
    required Map<String, int> issueTypeStats,
    required int totalReports,
    required int pendingReports,
    required int inProgressReports,
    required int resolvedReports,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('BARANGAY ANALYTICS REPORT');
    buffer.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('');
    buffer.writeln('=== REPORT STATISTICS ===');
    buffer.writeln('Total Reports: $totalReports');
    buffer.writeln('Pending: $pendingReports');
    buffer.writeln('In Progress: $inProgressReports');
    buffer.writeln('Resolved: $resolvedReports');
    buffer.writeln('');
    buffer.writeln('=== ISSUE TYPE DISTRIBUTION ===');
    
    for (final entry in issueTypeStats.entries) {
      final percentage = totalReports > 0
          ? ((entry.value / totalReports) * 100).toStringAsFixed(1)
          : '0.0';
      buffer.writeln('${entry.key}: ${entry.value} (${percentage}%)');
    }
    
    return buffer.toString();
  }

  /// Escape CSV special characters
  static String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Save CSV to file (for mobile - requires path_provider)
  static Future<void> saveCSVToFile(String csvContent, String filename) async {
    // This would require path_provider package
    // For now, return the CSV string for web download
    throw UnimplementedError('File saving requires path_provider package');
  }
}

