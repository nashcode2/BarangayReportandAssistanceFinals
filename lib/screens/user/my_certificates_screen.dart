import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
import '../../providers/certificate_provider.dart';
import '../../models/certificate_model.dart';
import '../../services/certificate_service.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state_widget.dart';

/// Screen for users to view their certificate requests
class MyCertificatesScreen extends StatefulWidget {
  const MyCertificatesScreen({super.key});

  @override
  State<MyCertificatesScreen> createState() => _MyCertificatesScreenState();
}

class _MyCertificatesScreenState extends State<MyCertificatesScreen> {
  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  void _loadCertificates() {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final provider = context.read<CertificateProvider>();
          provider.loadUserCertificates(firebaseUser.uid);
        }
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case CertificateStatus.issued:
        return AppColors.success;
      case CertificateStatus.approved:
        return AppColors.secondary;
      case CertificateStatus.rejected:
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  Future<void> _downloadCertificate(String? pdfUrl) async {
    if (pdfUrl == null || pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Certificate PDF not available yet')),
      );
      return;
    }

    try {
      final uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open PDF: $e')),
      );
    }
  }

  Future<void> _generateAndDownloadCertificate(CertificateModel cert) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF...')),
      );

      Uint8List pdfData;
      if (cert.certificateType == CertificateTypes.barangayClearance) {
        pdfData = await CertificateService.generateBarangayClearance(
          residentName: cert.userName,
          address: cert.data['address'] ?? '',
          purpose: cert.purpose ?? '',
          qrCodeData: cert.qrCodeData,
          barangayName: 'Barangay Office',
          issuedBy: cert.issuedByName,
          issuedDate: cert.issuedDate,
        );
      } else if (cert.certificateType == CertificateTypes.certificateOfIndigency) {
        pdfData = await CertificateService.generateCertificateOfIndigency(
          residentName: cert.userName,
          address: cert.data['address'] ?? '',
          purpose: cert.purpose ?? '',
          qrCodeData: cert.qrCodeData,
          barangayName: 'Barangay Office',
          issuedBy: cert.issuedByName,
          issuedDate: cert.issuedDate,
        );
      } else if (cert.certificateType == CertificateTypes.certificateOfResidency) {
        pdfData = await CertificateService.generateCertificateOfResidency(
          residentName: cert.userName,
          address: cert.data['address'] ?? '',
          qrCodeData: cert.qrCodeData,
          barangayName: 'Barangay Office',
          issuedBy: cert.issuedByName,
          issuedDate: cert.issuedDate,
        );
      } else {
        throw Exception('Unknown certificate type');
      }

      // Show PDF preview and allow download/print
      await Printing.layoutPdf(
        onLayout: (format) async => pdfData,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CertificateProvider>();
    final certificates = provider.userCertificates;
    
    // Ensure stream is active when screen is visible
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && !provider.isLoading && certificates.isEmpty) {
      // If no certificates and not loading, ensure stream is set up
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.loadUserCertificates(firebaseUser.uid);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Certificates',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
              if (firebaseUser != null) {
                provider.loadUserCertificates(firebaseUser.uid);
              }
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: provider.isLoading && certificates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : certificates.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.description_outlined,
                  title: 'No certificate requests yet',
                  subtitle: 'Request a certificate to get started',
                  action: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/certificate_request');
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Request Certificate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
                    if (firebaseUser != null) {
                      // Force reload by canceling and restarting the stream
                      await provider.loadUserCertificates(firebaseUser.uid);
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: certificates.length,
                    itemBuilder: (context, index) {
                      final cert = certificates[index];
                      final statusColor = _getStatusColor(cert.status);
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: statusColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.description_rounded,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          CertificateTypes.getDisplayName(cert.certificateType),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          cert.purpose ?? "N/A",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      cert.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: AppColors.textLight,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Requested: ${DateFormat('MMM dd, yyyy').format(cert.createdAt)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                              if (cert.status == CertificateStatus.issued) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.success.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.success,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Certificate is ready for download',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton.icon(
                                    onPressed: cert.pdfUrl != null 
                                        ? () => _downloadCertificate(cert.pdfUrl)
                                        : () => _generateAndDownloadCertificate(cert),
                                    icon: const Icon(Icons.download_rounded),
                                    label: Text(cert.pdfUrl != null 
                                        ? 'Download Certificate PDF' 
                                        : 'Generate & Download PDF'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              if (cert.status == CertificateStatus.rejected && cert.rejectionReason != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: AppColors.danger, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Reason: ${cert.rejectionReason}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.danger,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/certificate_request');
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Request Certificate'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

