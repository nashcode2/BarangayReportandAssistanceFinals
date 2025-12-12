import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../models/report_model.dart';
import '../../utils/constants.dart';
import 'report_detail_screen.dart';

class ReportsMapScreen extends StatefulWidget {
  const ReportsMapScreen({super.key});

  @override
  State<ReportsMapScreen> createState() => _ReportsMapScreenState();
}

class _ReportsMapScreenState extends State<ReportsMapScreen> {
  final MapController _mapController = MapController();
  String _selectedFilter = 'All';
  ReportModel? _selectedReport;
  String? _lastFitSignature;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).loadAllReports();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.warning;
      case 'In Progress':
        return AppColors.primary;
      case 'Resolved':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.pending;
      case 'In Progress':
        return Icons.build;
      case 'Resolved':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  List<ReportModel> _getFilteredReports(List<ReportModel> reports) {
    if (_selectedFilter == 'All') {
      return reports;
    }
    return reports.where((r) => r.status == _selectedFilter).toList();
  }

  void _fitBounds(List<ReportModel> reports) {
    if (reports.isEmpty) return;

    final validReports = reports
        .where((r) => r.latitude != null && r.longitude != null)
        .toList();

    if (validReports.isEmpty) return;

    double minLat = validReports.first.latitude!;
    double maxLat = validReports.first.latitude!;
    double minLng = validReports.first.longitude!;
    double maxLng = validReports.first.longitude!;

    for (var report in validReports) {
      if (report.latitude! < minLat) minLat = report.latitude!;
      if (report.latitude! > maxLat) maxLat = report.latitude!;
      if (report.longitude! < minLng) minLng = report.longitude!;
      if (report.longitude! > maxLng) maxLng = report.longitude!;
    }

    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  void _fitBoundsIfNeeded(List<ReportModel> reports) {
    final validReports =
        reports.where((r) => r.latitude != null && r.longitude != null).toList();
    if (validReports.isEmpty) return;
    validReports.sort((a, b) => (a.id ?? '').compareTo(b.id ?? ''));

    // Build a lightweight signature so we only fit when the visible markers change
    final signature = StringBuffer()
      ..write(_selectedFilter)
      ..write('|')
      ..write(validReports.length);
    for (final report in validReports) {
      signature
        ..write(report.id ?? '')
        ..write(':')
        ..write(report.latitude)
        ..write(':')
        ..write(report.longitude)
        ..write('|');
    }

    final nextSignature = signature.toString();
    if (_lastFitSignature == nextSignature) return;
    _lastFitSignature = nextSignature;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitBounds(validReports);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);
    final allReports = reportProvider.reports;
    final filteredReports = _getFilteredReports(allReports);

    _fitBoundsIfNeeded(filteredReports);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Reports Map',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                reportProvider.loadAllReports();
              },
              tooltip: 'Refresh Reports',
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Filter Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.textLight.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Icon(
                              Icons.filter_list,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Filter by Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['All', 'Pending', 'In Progress', 'Resolved']
                            .map((status) {
                          final isSelected = _selectedFilter == status;
                          return FilterChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = status;
                                _selectedReport = null;
                              });
                            },
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                // Report count
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.textLight.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.report_problem,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${filteredReports.length}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Reports List
                Expanded(
                  child: reportProvider.isLoading && allReports.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : filteredReports.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.map_outlined,
                                      size: 64,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'No reports found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try selecting a different filter',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredReports.length,
                              itemBuilder: (context, index) {
                                final report = filteredReports[index];
                                final isSelected = _selectedReport?.id == report.id;
                                return Container(
                                  key: ValueKey(report.id),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.08)
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textLight.withOpacity(0.1),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedReport = report;
                                        });
                                        if (report.latitude != null &&
                                            report.longitude != null) {
                                          _mapController.move(
                                            LatLng(
                                              report.latitude!,
                                              report.longitude!,
                                            ),
                                            16,
                                          );
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(report.status),
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _getStatusColor(report.status)
                                                        .withOpacity(0.3),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                _getStatusIcon(report.status),
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    report.issueType,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                      color: AppColors.textDark,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.person_outline,
                                                        size: 14,
                                                        color: AppColors.textLight,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          report.userName,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: AppColors.textLight,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getStatusColor(report.status)
                                                          .withOpacity(0.15),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      report.status,
                                                      style: TextStyle(
                                                        color: _getStatusColor(report.status),
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right,
                                              color: AppColors.textLight,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          // Map View
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  key: ValueKey('${filteredReports.length}_$_selectedFilter'),
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(14.5995, 120.9842),
                    initialZoom: 13.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.barangay.reportassistance',
                      maxZoom: 19,
                      errorTileCallback: (tile, error, stackTrace) {
                        debugPrint('Tile load error $tile: $error');
                      },
                    ),
                    MarkerLayer(
                      markers: filteredReports
                          .where((r) => r.latitude != null && r.longitude != null)
                          .map((report) {
                        return Marker(
                          point: LatLng(report.latitude!, report.longitude!),
                          width: 50,
                          height: 50,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedReport = report;
                              });
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: ReportDetailScreen(report: report),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getStatusColor(report.status),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getStatusIcon(report.status),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                // Selected report info card
                if (_selectedReport != null)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Card(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _getStatusColor(_selectedReport!.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getStatusIcon(_selectedReport!.status),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedReport!.issueType,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedReport!.userName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _selectedReport = null;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.info_outline),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: ReportDetailScreen(report: _selectedReport!),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
