import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/certificate_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/certificate_model.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state_widget.dart';
import 'certificate_detail_admin_screen.dart';

/// Screen for admins to manage certificate requests
class CertificateManagementScreen extends StatefulWidget {
  const CertificateManagementScreen({super.key});

  @override
  State<CertificateManagementScreen> createState() => _CertificateManagementScreenState();
}

class _CertificateManagementScreenState extends State<CertificateManagementScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CertificateProvider>().loadAllCertificates();
    });
  }

  List<CertificateModel> _getFilteredCertificates(List<CertificateModel> certificates) {
    if (_selectedFilter == 'All') {
      return certificates;
    }
    return certificates.where((c) => c.status == _selectedFilter.toLowerCase()).toList();
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CertificateProvider>();
    final certificates = provider.certificates;
    final filteredCertificates = _getFilteredCertificates(certificates);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Certificate Management',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'Pending', 'Approved', 'Issued', 'Rejected']
                  .map((status) {
                final isSelected = _selectedFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = status;
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: provider.isLoading && certificates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : filteredCertificates.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.description_outlined,
                  title: 'No certificate requests found',
                  subtitle: 'Certificate requests will appear here',
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadAllCertificates(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCertificates.length,
                    itemBuilder: (context, index) {
                      final cert = filteredCertificates[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            CertificateTypes.getDisplayName(cert.certificateType),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Requested by: ${cert.userName}'),
                              Text('Purpose: ${cert.purpose ?? "N/A"}'),
                              Text(
                                'Date: ${DateFormat('MMM dd, yyyy').format(cert.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(cert.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              cert.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(cert.status),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CertificateDetailAdminScreen(
                                  certificate: cert,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

