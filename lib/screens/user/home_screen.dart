import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../utils/constants.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/smooth_loading.dart';
import 'announcements_screen.dart';
import 'emergency_assistance_screen.dart';
import 'my_reports_screen.dart';
import 'report_issue_screen.dart';
import 'chatbot_screen.dart';
import 'reviews_screen.dart';
import 'events_screen.dart';
import 'service_requests_screen.dart';
import 'my_certificates_screen.dart';

/// Home/Dashboard screen for users
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _reportsLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().loadAnnouncements();
      _loadReports();
    });
  }

  void _loadReports() {
    if (_reportsLoaded) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      context.read<ReportProvider>().loadUserReports(user.id);
      _reportsLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only watch auth for user name - use read for others to avoid unnecessary rebuilds
    final auth = context.watch<AuthProvider>();
    final userName = auth.currentUser?.name ?? 'Community hero';
    
    // Use Selector for granular rebuilds - only rebuild when specific data changes
    return Selector<ReportProvider, Map<String, int>>(
      selector: (_, provider) => {
        'total': provider.userReports.length,
        'active': provider.userReports
            .where((r) => r.status != AppConstants.statusResolved)
            .length,
        'resolved': provider.userReports
            .where((r) => r.status == AppConstants.statusResolved)
            .length,
      },
      builder: (context, stats, _) {
        final totalReports = stats['total'] ?? 0;
        final activeReports = stats['active'] ?? 0;
        final resolvedReports = stats['resolved'] ?? 0;
        
        return Selector<AnnouncementProvider, bool>(
          selector: (_, provider) => provider.isLoading,
          shouldRebuild: (prev, next) => prev != next,
          builder: (context, isLoading, _) {
            final announcements = context.read<AnnouncementProvider>();

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $userName',
                      style: TextStyle(
                        fontSize: kIsWeb ? 20 : 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      "Here's what's happening today",
                      style: TextStyle(
                        fontSize: kIsWeb ? 14 : 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    tooltip: 'Logout',
                    onPressed: () async {
                      await auth.signOut();
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                  ),
                ],
              ),
              body: _buildMobileLayout(
                context,
                userName,
                totalReports,
                activeReports,
                resolvedReports,
                announcements,
              ),
              floatingActionButton: FloatingActionButton.extended(
                      onPressed: () {
                        context.pushSlide(const ChatbotScreen());
                      },
                      backgroundColor: AppColors.primary,
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                      label: const Text(
                        'Chat Assistant',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  /// Mobile layout - keep current UI/UX exactly as is
  Widget _buildMobileLayout(
    BuildContext context,
    String userName,
    int totalReports,
    int activeReports,
    int resolvedReports,
    AnnouncementProvider announcements,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await announcements.loadAnnouncements();
        _loadReports();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DashboardHero(
              name: userName,
              onReportTap: () => context.pushSlide(
                const ReportIssueScreen(),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _StatsRow(
                total: totalReports,
                active: activeReports,
                resolved: resolvedReports,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _QuickActions(
                onReportTap: () => context.pushSlide(
                  const ReportIssueScreen(),
                ),
                onEmergencyTap: () => context.pushSlide(
                  const EmergencyAssistanceScreen(),
                ),
                onMyReportsTap: () => context.pushSlide(
                  const MyReportsScreen(),
                ),
                onReviewsTap: () => context.pushSlide(
                  ReviewsScreen(),
                ),
                onEventsTap: () => context.pushSlide(
                  const EventsScreen(),
                ),
                onServicesTap: () => context.pushSlide(
                  ServiceRequestsScreen(),
                ),
                onCertificatesTap: () => context.pushSlide(
                  const MyCertificatesScreen(),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _SectionHeader(
              title: 'Announcements',
              actionLabel: 'View all',
              onActionTap: () => context.pushSlide(
                AnnouncementsScreen(),
              ),
            ),
            const SizedBox(height: 12),
              if (announcements.isLoading)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: kIsWeb
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : const SmoothLoading(message: 'Loading announcements...'),
                )
            else if (announcements.announcements.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: _EmptyState(
                  message: 'No announcements yet. Stay tuned!',
                ),
              )
            else
              SizedBox(
                height: 220,
                child: RepaintBoundary(
                  child: PageView.builder(
                    controller: PageController(viewportFraction: .85),
                    padEnds: false,
                    physics: kIsWeb 
                        ? const NeverScrollableScrollPhysics() 
                        : const PageScrollPhysics(),
                    itemCount: announcements.announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = announcements.announcements[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: RepaintBoundary(
                          child: AnnouncementCard(
                            announcement: announcement,
                            onTap: () => context.pushSlide(
                              AnnouncementsScreen(
                                initialAnnouncement: announcement,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Web layout - optimized for web with better spacing and layout
  Widget _buildWebLayout(
    BuildContext context,
    String userName,
    int totalReports,
    int activeReports,
    int resolvedReports,
    AnnouncementProvider announcements,
  ) {
    // Remove RefreshIndicator on web - it causes performance issues
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                _DashboardHero(
                  name: userName,
                  onReportTap: () => context.pushSlide(
                    const ReportIssueScreen(),
                  ),
                ),
                const SizedBox(height: 32),
                // Stats Row
                RepaintBoundary(
                  child: _StatsRow(
                    total: totalReports,
                    active: activeReports,
                    resolved: resolvedReports,
                  ),
                ),
                const SizedBox(height: 40),
                // Two Column Layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column - Quick Actions
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 20),
                          RepaintBoundary(
                            child: _QuickActionsGrid(
                              onReportTap: () => context.pushSlide(
                                const ReportIssueScreen(),
                              ),
                              onEmergencyTap: () => context.pushSlide(
                                const EmergencyAssistanceScreen(),
                              ),
                              onMyReportsTap: () => context.pushSlide(
                                const MyReportsScreen(),
                              ),
                              onReviewsTap: () => context.pushSlide(
                                ReviewsScreen(),
                              ),
                              onEventsTap: () => context.pushSlide(
                                const EventsScreen(),
                              ),
                              onServicesTap: () => context.pushSlide(
                                ServiceRequestsScreen(),
                              ),
                              onCertificatesTap: () => context.pushSlide(
                                const MyCertificatesScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    // Right Column - Announcements & Chatbot
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Announcements',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.pushSlide(
                                  AnnouncementsScreen(),
                                ),
                                child: const Text('View all'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (announcements.isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (announcements.announcements.isEmpty)
                            const _EmptyState(
                              message: 'No announcements yet. Stay tuned!',
                            )
                          else
                            ...announcements.announcements.take(3).map(
                                  (announcement) => RepaintBoundary(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: AnnouncementCard(
                                        announcement: announcement,
                                        onTap: () => context.pushSlide(
                                          AnnouncementsScreen(
                                            initialAnnouncement: announcement,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 24),
                          // Chatbot Button for Web
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.pushSlide(
                                    const ChatbotScreen(),
                                  );
                                },
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('Chat Assistant'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
  }
}

class _DashboardHero extends StatelessWidget {
  final String name;
  final VoidCallback onReportTap;

  const _DashboardHero({
    required this.name,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Barangay Connect',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Good day, $name!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Need to report something or ask for help? We’re here for you 24/7.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onReportTap,
              icon: const Icon(Icons.message_outlined),
              label: const Text('Report an issue'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int total;
  final int active;
  final int resolved;

  const _StatsRow({
    required this.total,
    required this.active,
    required this.resolved,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(label: 'Total', value: total, color: AppColors.primary),
        const SizedBox(width: 12),
        _StatChip(label: 'Active', value: active, color: AppColors.warning),
        const SizedBox(width: 12),
        _StatChip(label: 'Resolved', value: resolved, color: AppColors.success),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onReportTap;
  final VoidCallback onEmergencyTap;
  final VoidCallback onMyReportsTap;
  final VoidCallback onReviewsTap;
  final VoidCallback onEventsTap;
  final VoidCallback onServicesTap;
  final VoidCallback onCertificatesTap;

  const _QuickActions({
    required this.onReportTap,
    required this.onEmergencyTap,
    required this.onMyReportsTap,
    required this.onReviewsTap,
    required this.onEventsTap,
    required this.onServicesTap,
    required this.onCertificatesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _ActionCard(
          title: 'Report issue',
          description: 'Submit garbage, flooding or lighting concerns.',
          icon: Icons.report_gmailerrorred_rounded,
          color: AppColors.primary,
          onTap: onReportTap,
        ),
        _ActionCard(
          title: 'Emergency',
          description: 'Contact health, fire or police instantly.',
          icon: Icons.emergency_share,
          color: AppColors.danger,
          onTap: onEmergencyTap,
        ),
        _ActionCard(
          title: 'My reports',
          description: 'Track your submissions and updates.',
          icon: Icons.list_alt,
          color: AppColors.secondary,
          onTap: onMyReportsTap,
        ),
        _ActionCard(
          title: 'Reviews',
          description: 'Read and write resident reviews.',
          icon: Icons.rate_review,
          color: AppColors.accent,
          onTap: onReviewsTap,
        ),
        _ActionCard(
          title: 'Events',
          description: 'View and RSVP to barangay events.',
          icon: Icons.event,
          color: AppColors.secondary,
          onTap: onEventsTap,
        ),
        _ActionCard(
          title: 'Services',
          description: 'Request barangay services.',
          icon: Icons.build_circle,
          color: AppColors.success,
          onTap: onServicesTap,
        ),
        _ActionCard(
          title: 'Certificates',
          description: 'Request and view certificates.',
          icon: Icons.description_rounded,
          color: AppColors.warning,
          onTap: onCertificatesTap,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 56) / 2,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          TextButton(onPressed: onActionTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.notifications_off,
              size: 32, color: AppColors.textLight),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textLight),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final VoidCallback onReportTap;
  final VoidCallback onEmergencyTap;
  final VoidCallback onMyReportsTap;
  final VoidCallback onReviewsTap;
  final VoidCallback onEventsTap;
  final VoidCallback onServicesTap;
  final VoidCallback onCertificatesTap;

  const _QuickActionsGrid({
    required this.onReportTap,
    required this.onEmergencyTap,
    required this.onMyReportsTap,
    required this.onReviewsTap,
    required this.onEventsTap,
    required this.onServicesTap,
    required this.onCertificatesTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _ActionCard(
          title: 'Report issue',
          description: 'Submit concerns',
          icon: Icons.report_gmailerrorred_rounded,
          color: AppColors.primary,
          onTap: onReportTap,
        ),
        _ActionCard(
          title: 'Emergency',
          description: 'Quick help',
          icon: Icons.emergency_share,
          color: AppColors.danger,
          onTap: onEmergencyTap,
        ),
        _ActionCard(
          title: 'My reports',
          description: 'Track status',
          icon: Icons.list_alt,
          color: AppColors.secondary,
          onTap: onMyReportsTap,
        ),
        _ActionCard(
          title: 'Reviews',
          description: 'Share feedback',
          icon: Icons.rate_review,
          color: AppColors.accent,
          onTap: onReviewsTap,
        ),
        _ActionCard(
          title: 'Events',
          description: 'View & RSVP',
          icon: Icons.event,
          color: AppColors.secondary,
          onTap: onEventsTap,
        ),
        _ActionCard(
          title: 'Services',
          description: 'Request help',
          icon: Icons.build_circle,
          color: AppColors.success,
          onTap: onServicesTap,
        ),
        _ActionCard(
          title: 'Certificates',
          description: 'Get documents',
          icon: Icons.description_rounded,
          color: AppColors.warning,
          onTap: onCertificatesTap,
        ),
      ],
    );
  }
}
