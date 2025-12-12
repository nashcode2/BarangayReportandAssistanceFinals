import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/event_model.dart';
import '../../utils/constants.dart';

/// Screen showing event details with RSVP functionality
class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();
    final hasRsvpd = auth.currentUser != null
        ? eventProvider.hasUserRsvpd(event.id, auth.currentUser!.id)
        : false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    event.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.surface,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 64),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                event.eventType,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Start Date',
              value: DateFormat('MMM dd, yyyy • hh:mm a').format(event.startDate),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.event,
              label: 'End Date',
              value: DateFormat('MMM dd, yyyy • hh:mm a').format(event.endDate),
            ),
            if (event.location != null) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.location_on,
                label: 'Location',
                value: event.location!,
              ),
            ],
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.people,
              label: 'Attendees',
              value: '${event.rsvpUserIds.length} people',
            ),
            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            if (auth.currentUser != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (hasRsvpd) {
                      final success = await eventProvider.cancelRsvp(
                        event.id,
                        auth.currentUser!.id,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'RSVP cancelled'
                                : 'Failed to cancel RSVP'),
                            backgroundColor:
                                success ? AppColors.success : AppColors.danger,
                          ),
                        );
                      }
                    } else {
                      final success = await eventProvider.rsvpToEvent(
                        event.id,
                        auth.currentUser!.id,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'RSVP successful!'
                                : 'Failed to RSVP'),
                            backgroundColor:
                                success ? AppColors.success : AppColors.danger,
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(hasRsvpd ? Icons.cancel : Icons.check_circle),
                  label: Text(hasRsvpd ? 'Cancel RSVP' : 'RSVP to Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasRsvpd ? AppColors.danger : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textLight),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

