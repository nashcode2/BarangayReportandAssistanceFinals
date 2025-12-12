import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/service_request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/service_request_model.dart';
import '../../utils/constants.dart';
import 'request_service_screen.dart';

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key});
  @override
  State<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState extends State<ServiceRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) context.read<ServiceRequestProvider>().loadUserRequests(user.id);
    });
  }
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return AppColors.warning;
      case 'Scheduled': return AppColors.secondary;
      case 'In Progress': return AppColors.primary;
      case 'Completed': return AppColors.success;
      case 'Cancelled': return AppColors.danger;
      default: return Colors.grey;
    }
  }
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending': return Icons.pending;
      case 'Scheduled': return Icons.schedule;
      case 'In Progress': return Icons.build;
      case 'Completed': return Icons.check_circle;
      case 'Cancelled': return Icons.cancel;
      default: return Icons.help;
    }
  }
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceRequestProvider>();
    final requests = provider.userRequests;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Service Requests',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: provider.isLoading && requests.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.build_circle_outlined,
                        size: 64,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No service requests yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Request a service to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    final user = context.read<AuthProvider>().currentUser;
                    if (user != null) {
                      await provider.loadUserRequests(user.id);
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      final statusColor = _getStatusColor(request.status);
                      return Card(
                        key: ValueKey(request.id),
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: statusColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) =>
                                _RequestDetailDialog(request: request),
                          ),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getStatusIcon(request.status),
                                    color: statusColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request.serviceType,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        request.description.length > 60
                                            ? '${request.description.substring(0, 60)}...'
                                            : request.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
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
                                              request.status,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            DateFormat('MMM dd, yyyy')
                                                .format(request.createdAt),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (request.scheduledDate != null) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.schedule,
                                              size: 14,
                                              color: AppColors.textLight,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Scheduled: ${DateFormat('MMM dd, yyyy').format(request.scheduledDate!)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textLight,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RequestServiceScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Request Service'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class _RequestDetailDialog extends StatelessWidget {
  final ServiceRequestModel request;
  const _RequestDetailDialog({required this.request});
  @override
  Widget build(BuildContext context) {
    Color _getStatusColor(String status) {
      switch (status) {
        case 'Pending': return AppColors.warning;
        case 'Scheduled': return AppColors.secondary;
        case 'In Progress': return AppColors.primary;
        case 'Completed': return AppColors.success;
        case 'Cancelled': return AppColors.danger;
        default: return Colors.grey;
      }
    }
    return Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(request.serviceType, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark))), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]), const SizedBox(height: 16), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: _getStatusColor(request.status).withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text(request.status, style: TextStyle(color: _getStatusColor(request.status), fontWeight: FontWeight.bold))), const SizedBox(height: 16), Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)), const SizedBox(height: 8), Text(request.description, style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.5)), if (request.address != null && request.address!.isNotEmpty) ...[const SizedBox(height: 16), Row(children: [Icon(Icons.location_on, size: 16, color: AppColors.textLight), const SizedBox(width: 8), Expanded(child: Text(request.address!, style: TextStyle(fontSize: 14, color: AppColors.textDark)))])], if (request.scheduledDate != null) ...[const SizedBox(height: 16), Row(children: [Icon(Icons.schedule, size: 16, color: AppColors.textLight), const SizedBox(width: 8), Text('Scheduled: ${DateFormat('MMM dd, yyyy').format(request.scheduledDate!)}', style: TextStyle(fontSize: 14, color: AppColors.textDark))])], const SizedBox(height: 16), Row(children: [Icon(Icons.calendar_today, size: 16, color: AppColors.textLight), const SizedBox(width: 8), Text('Requested: ${DateFormat('MMM dd, yyyy').format(request.createdAt)}', style: TextStyle(fontSize: 12, color: AppColors.textLight))])]))));
  }
}

