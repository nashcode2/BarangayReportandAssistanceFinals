import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/announcement_provider.dart';
import '../../models/announcement_model.dart';
import '../../widgets/announcement_card.dart';
import '../../utils/constants.dart';

class AnnouncementsScreen extends StatefulWidget {
  final AnnouncementModel? initialAnnouncement;
  const AnnouncementsScreen({super.key, this.initialAnnouncement});
  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Provider.of<AnnouncementProvider>(context, listen: false).loadAnnouncements());
  }
  @override
  Widget build(BuildContext context) {
    final announcementProvider = Provider.of<AnnouncementProvider>(context);
    final announcements = announcementProvider.announcements;
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
          'Announcements',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => await announcementProvider.loadAnnouncements(),
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: announcementProvider.isLoading && announcements.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : announcements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.announcement_outlined,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No announcements yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Stay tuned for updates!',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = announcements[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AnnouncementCard(
                          announcement: announcement,
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) =>
                                _AnnouncementDetailDialog(
                              announcement: announcement,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class _AnnouncementDetailDialog extends StatelessWidget {
  final AnnouncementModel announcement;
  const _AnnouncementDetailDialog({required this.announcement});
  @override
  Widget build(BuildContext context) {
    return Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(announcement.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark))), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]), const SizedBox(height: 16), if (announcement.imageUrl != null) ...[ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(announcement.imageUrl!, fit: BoxFit.cover, loadingBuilder: (context, child, loadingProgress) => loadingProgress == null ? child : Container(color: AppColors.surface, child: Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)))), errorBuilder: (context, error, stackTrace) => Container(color: AppColors.surface, child: Icon(Icons.error_outline, color: AppColors.textLight)))), const SizedBox(height: 16)], Text(announcement.fullDescription ?? announcement.description, style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.5)), const SizedBox(height: 16), Row(children: [Icon(Icons.calendar_today, size: 16, color: AppColors.textLight), const SizedBox(width: 8), Text(DateFormat('MMM dd, yyyy').format(announcement.createdAt), style: TextStyle(fontSize: 12, color: AppColors.textLight))])]))));
  }
}

