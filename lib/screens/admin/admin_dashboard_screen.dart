import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import 'report_management_screen.dart';
import 'resident_database_screen.dart';
import 'announcements_management_screen.dart';
import 'analytics_screen.dart';
import 'events_management_screen.dart';
import 'service_requests_management_screen.dart';
import 'certificate_management_screen.dart';

/// Admin dashboard screen
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, int> _statistics = {
    'total': 0,
    'pending': 0,
    'inProgress': 0,
    'resolved': 0,
  };
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
    // Load all reports
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).loadAllReports();
    });
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final stats = await _firebaseService.getReportStatistics();
      setState(() {
        _statistics = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Tiles
              if (_isLoadingStats)
                const Center(child: CircularProgressIndicator())
              else
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio:
                      MediaQuery.of(context).size.width > 380 ? 1.35 : 1.15,
                  children: [
                    _buildStatCard(
                      'Total Reports',
                      _statistics['total']?.toString() ?? '0',
                      Colors.blue,
                      Icons.report_problem,
                    ),
                    _buildStatCard(
                      'Pending',
                      _statistics['pending']?.toString() ?? '0',
                      Colors.orange,
                      Icons.pending,
                    ),
                    _buildStatCard(
                      'In Progress',
                      _statistics['inProgress']?.toString() ?? '0',
                      Colors.blue,
                      Icons.work,
                    ),
                    _buildStatCard(
                      'Resolved',
                      _statistics['resolved']?.toString() ?? '0',
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              // Quick Links
              const Text(
                'Quick Links',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickLinkButton(
                context,
                'Reports',
                Icons.report_problem,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportManagementScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuickLinkButton(
                context,
                'Residents',
                Icons.people,
                Colors.purple,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResidentDatabaseScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuickLinkButton(
                context,
                'Announcements',
                Icons.announcement,
                Colors.orange,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AnnouncementsManagementScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuickLinkButton(
                context,
                'Analytics',
                Icons.analytics,
                Colors.teal,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnalyticsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuickLinkButton(
                context,
                'Events',
                Icons.event,
                AppColors.secondary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EventsManagementScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuickLinkButton(
                context,
                'Service Requests',
                Icons.build_circle,
                AppColors.success,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ServiceRequestsManagementScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuickLinkButton(
                context,
                'Certificates',
                Icons.description_rounded,
                AppColors.warning,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CertificateManagementScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinkButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
