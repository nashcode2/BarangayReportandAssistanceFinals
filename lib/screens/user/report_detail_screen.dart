import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/report_model.dart';
import '../../utils/constants.dart';

/// Detailed view of a report
class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(report.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                report.status,
                style: TextStyle(
                  color: _getStatusColor(report.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Issue Type
            _buildDetailRow('Issue Type', report.issueType),
            const SizedBox(height: 16),
            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report.description,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            // Photo
            if (report.photoUrl != null) ...[
              const Text(
                'Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    report.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, size: 48),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Location
            if (report.latitude != null && report.longitude != null) ...[
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (report.address != null)
                Text(
                  report.address!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(report.latitude!, report.longitude!),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('report_location'),
                        position: LatLng(report.latitude!, report.longitude!),
                      ),
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Date
            _buildDetailRow(
              'Submitted',
              DateFormat('MMM dd, yyyy HH:mm').format(report.createdAt),
            ),
            if (report.updatedAt != null) ...[
              const SizedBox(height: 16),
              _buildDetailRow(
                'Last Updated',
                DateFormat('MMM dd, yyyy HH:mm').format(report.updatedAt!),
              ),
            ],
            // Assigned Staff
            if (report.assignedStaffName != null) ...[
              const SizedBox(height: 16),
              _buildDetailRow('Assigned To', report.assignedStaffName!),
            ],
            // Notes
            if (report.notes != null && report.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...report.notes!.map((note) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '• $note',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  )),
            ],
            // Resolution
            if (report.resolution != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Resolution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.resolution!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return Colors.orange;
      case AppConstants.statusInProgress:
        return Colors.blue;
      case AppConstants.statusResolved:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

