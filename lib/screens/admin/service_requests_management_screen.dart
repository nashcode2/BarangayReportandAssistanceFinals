import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/service_request_provider.dart';
import '../../models/service_request_model.dart';
import '../../utils/constants.dart';

/// Admin screen for managing service requests
class ServiceRequestsManagementScreen extends StatefulWidget {
  const ServiceRequestsManagementScreen({super.key});

  @override
  State<ServiceRequestsManagementScreen> createState() =>
      _ServiceRequestsManagementScreenState();
}

class _ServiceRequestsManagementScreenState
    extends State<ServiceRequestsManagementScreen> {
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceRequestProvider>().loadAllRequests();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.warning;
      case 'Scheduled':
        return AppColors.secondary;
      case 'In Progress':
        return AppColors.primary;
      case 'Completed':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.danger;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Requests Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'Pending', 'Scheduled', 'In Progress', 'Completed']
                  .map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = status;
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
      body: Consumer<ServiceRequestProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.allRequests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredRequests = _selectedStatus == 'All'
              ? provider.allRequests
              : provider.allRequests
                  .where((r) => r.status == _selectedStatus)
                  .toList();

          if (filteredRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.build_circle_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No service requests',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAllRequests(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                final request = filteredRequests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(request.status),
                      child: Icon(
                        _getStatusIcon(request.status),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      request.serviceType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Requested by: ${request.userName}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.description.length > 50
                              ? '${request.description.substring(0, 50)}...'
                              : request.description,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(request.status)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                request.status,
                                style: TextStyle(
                                  color: _getStatusColor(request.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('MMM dd, yyyy')
                                  .format(request.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showRequestDetailDialog(context, provider, request);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.pending;
      case 'Scheduled':
        return Icons.schedule;
      case 'In Progress':
        return Icons.work;
      case 'Completed':
        return Icons.check_circle;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _showRequestDetailDialog(BuildContext context,
      ServiceRequestProvider provider, ServiceRequestModel request) {
    String? newStatus = request.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(request.serviceType),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow('Requested by', request.userName),
                _DetailRow('Description', request.description),
                if (request.address != null)
                  _DetailRow('Address', request.address!),
                _DetailRow('Preferred Date',
                    DateFormat('MMM dd, yyyy').format(request.preferredDate)),
                if (request.scheduledDate != null)
                  _DetailRow('Scheduled Date',
                      DateFormat('MMM dd, yyyy').format(request.scheduledDate!)),
                _DetailRow('Status', request.status),
                const SizedBox(height: 16),
                const Text('Update Status:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: newStatus,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    'Pending',
                    'Scheduled',
                    'In Progress',
                    'Completed',
                    'Cancelled'
                  ].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      newStatus = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newStatus != null && newStatus != request.status) {
                  final updatedRequest = request.copyWith(
                    status: newStatus!,
                    scheduledDate: newStatus == 'Scheduled'
                        ? request.preferredDate
                        : request.scheduledDate,
                    completedDate: newStatus == 'Completed'
                        ? DateTime.now()
                        : request.completedDate,
                  );

                  final success =
                      await provider.updateServiceRequest(updatedRequest);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Status updated successfully'
                            : 'Failed to update status'),
                        backgroundColor:
                            success ? AppColors.success : AppColors.danger,
                      ),
                    );
                  }
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text('Update Status'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

