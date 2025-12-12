import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/certificate_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/certificate_model.dart';
import '../../utils/constants.dart';

/// Screen for admins to view and manage certificate details
class CertificateDetailAdminScreen extends StatefulWidget {
  final CertificateModel certificate;

  const CertificateDetailAdminScreen({
    super.key,
    required this.certificate,
  });

  @override
  State<CertificateDetailAdminScreen> createState() => _CertificateDetailAdminScreenState();
}

class _CertificateDetailAdminScreenState extends State<CertificateDetailAdminScreen> {
  final _rejectionReasonController = TextEditingController();
  bool _showRejectDialog = false;

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _approveCertificate() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<CertificateProvider>();
    final user = auth.currentUser;

    if (user == null) return;

    final success = await provider.approveCertificate(
      widget.certificate,
      user.id,
      user.name,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificate approved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to approve certificate'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _issueCertificate() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<CertificateProvider>();
    final user = auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Generating certificate PDF...'),
              const SizedBox(height: 8),
              Text(
                'This should only take a moment',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
        ),
      ),
    );

    try {
      final success = await provider.issueCertificate(
        widget.certificate,
        user.id,
        user.name,
        'Barangay Office', // TODO: Get from settings
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Certificate issued successfully!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context); // Go back to certificate list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to issue certificate'),
              backgroundColor: AppColors.danger,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _rejectCertificate() async {
    if (_rejectionReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rejection reason')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final provider = context.read<CertificateProvider>();
    final user = auth.currentUser;

    if (user == null) return;

    final success = await provider.rejectCertificate(
      widget.certificate,
      user.id,
      user.name,
      _rejectionReasonController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificate rejected'),
            backgroundColor: AppColors.danger,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to reject certificate'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cert = widget.certificate;
    final provider = context.watch<CertificateProvider>();
    final canApprove = cert.status == CertificateStatus.pending;
    final canIssue = cert.status == CertificateStatus.approved;

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
          'Certificate Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: StatusColorMapper.colorForStatus(cert.status),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    cert.status == CertificateStatus.issued
                        ? Icons.check_circle
                        : cert.status == CertificateStatus.rejected
                            ? Icons.cancel
                            : Icons.pending,
                    color: StatusColorMapper.colorForStatus(cert.status),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${cert.status.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (cert.rejectionReason != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Reason: ${cert.rejectionReason}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Certificate Info
            _buildInfoCard('Certificate Type', CertificateTypes.getDisplayName(cert.certificateType)),
            _buildInfoCard('Requested By', cert.userName),
            _buildInfoCard('Address', cert.data['address'] ?? 'N/A'),
            _buildInfoCard('Purpose', cert.purpose ?? 'N/A'),
            _buildInfoCard('Requested Date', DateFormat('MMM dd, yyyy').format(cert.createdAt)),
            if (cert.issuedByName.isNotEmpty)
              _buildInfoCard('Issued By', cert.issuedByName),
            if (cert.pdfUrl != null)
              _buildInfoCard('PDF', 'Available', isLink: true, link: cert.pdfUrl),
            
            const SizedBox(height: 24),
            
            // Actions
            if (canApprove || canIssue) ...[
              if (canApprove) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: provider.isSubmitting ? null : _approveCertificate,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Approve Certificate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (canIssue) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: provider.isSubmitting ? null : _issueCertificate,
                    icon: const Icon(Icons.description_rounded),
                    label: const Text('Issue Certificate (Generate PDF)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: provider.isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _showRejectDialog = true;
                          });
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Reject Certificate'),
                              content: TextField(
                                controller: _rejectionReasonController,
                                decoration: const InputDecoration(
                                  labelText: 'Rejection Reason',
                                  hintText: 'Enter reason for rejection',
                                ),
                                maxLines: 3,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showRejectDialog = false;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _rejectCertificate();
                                  },
                                  child: const Text('Reject'),
                                ),
                              ],
                            ),
                          );
                        },
                  icon: const Icon(Icons.cancel_rounded),
                  label: const Text('Reject Certificate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, {bool isLink = false, String? link}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
              ),
            ),
          ),
          Expanded(
            child: isLink && link != null
                ? InkWell(
                    onTap: () {
                      // Open PDF URL
                    },
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

