import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../models/report_model.dart';
import '../../utils/constants.dart';
import 'report_detail_screen.dart';

/// Admin view of report details with management options
class ReportDetailAdminScreen extends StatefulWidget {
  final ReportModel report;

  const ReportDetailAdminScreen({super.key, required this.report});

  @override
  State<ReportDetailAdminScreen> createState() =>
      _ReportDetailAdminScreenState();
}

class _ReportDetailAdminScreenState extends State<ReportDetailAdminScreen> {
  late ReportModel _currentReport;
  final _notesController = TextEditingController();
  final _resolutionController = TextEditingController();
  final _staffNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentReport = widget.report;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _resolutionController.dispose();
    _staffNameController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String newStatus) async {
    final updatedReport = _currentReport.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    final reportProvider =
        Provider.of<ReportProvider>(context, listen: false);
    final success = await reportProvider.updateReport(updatedReport);

    if (success && mounted) {
      setState(() {
        _currentReport = updatedReport;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reportProvider.errorMessage ?? 'Failed to update status',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addNote() async {
    if (_notesController.text.trim().isEmpty) return;

    final notes = _currentReport.notes ?? [];
    notes.add(_notesController.text.trim());

    final updatedReport = _currentReport.copyWith(
      notes: notes,
      updatedAt: DateTime.now(),
    );

    final reportProvider =
        Provider.of<ReportProvider>(context, listen: false);
    final success = await reportProvider.updateReport(updatedReport);

    if (success && mounted) {
      setState(() {
        _currentReport = updatedReport;
        _notesController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _assignStaff() async {
    if (_staffNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter staff name')),
      );
      return;
    }

    final updatedReport = _currentReport.copyWith(
      assignedStaffName: _staffNameController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final reportProvider =
        Provider.of<ReportProvider>(context, listen: false);
    final success = await reportProvider.updateReport(updatedReport);

    if (success && mounted) {
      setState(() {
        _currentReport = updatedReport;
        _staffNameController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Staff assigned successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _addResolution() async {
    if (_resolutionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter resolution details')),
      );
      return;
    }

    final updatedReport = _currentReport.copyWith(
      resolution: _resolutionController.text.trim(),
      status: AppConstants.statusResolved,
      updatedAt: DateTime.now(),
    );

    final reportProvider =
        Provider.of<ReportProvider>(context, listen: false);
    final success = await reportProvider.updateReport(updatedReport);

    if (success && mounted) {
      setState(() {
        _currentReport = updatedReport;
        _resolutionController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resolution added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Report Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                // Report Details (reuse the detail screen widget)
                ReportDetailScreen(report: _currentReport),
                const SizedBox(height: 24),
                // Management Actions
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Management Actions',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Status Update
                  _buildSectionHeader(
                    icon: Icons.update_rounded,
                    title: 'Update Status',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildStatusButton(
                        AppConstants.statusPending,
                        AppColors.warning,
                      ),
                      _buildStatusButton(
                        AppConstants.statusInProgress,
                        AppColors.secondary,
                      ),
                      _buildStatusButton(
                        AppConstants.statusResolved,
                        AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Assign Staff
                  _buildSectionHeader(
                    icon: Icons.person_add_rounded,
                    title: 'Assign Staff',
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _staffNameController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Enter staff name',
                      hintStyle: TextStyle(color: AppColors.textLight),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _assignStaff,
                      icon: const Icon(Icons.person_add_rounded, size: 20),
                      label: const Text(
                        'Assign',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Add Note
                  _buildSectionHeader(
                    icon: Icons.note_add_rounded,
                    title: 'Add Note',
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Enter note',
                      hintStyle: TextStyle(color: AppColors.textLight),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _addNote,
                      icon: const Icon(Icons.note_add_rounded, size: 20),
                      label: const Text(
                        'Add Note',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Add Resolution
                  _buildSectionHeader(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Add Resolution',
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _resolutionController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Enter resolution details',
                      hintStyle: TextStyle(color: AppColors.textLight),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _addResolution,
                      icon: const Icon(Icons.check_circle_rounded, size: 24),
                      label: const Text(
                        'Mark as Resolved',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(String status, Color color) {
    final isCurrentStatus = _currentReport.status == status;
    return Expanded(
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: isCurrentStatus
              ? null
              : () {
                  _updateStatus(status);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: color.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: isCurrentStatus ? 0 : 2,
          ),
          child: Text(
            status,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

