import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../services/export_service.dart';
import '../../providers/report_provider.dart';
import '../../utils/constants.dart';

/// Analytics screen showing reports statistics and trends
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, int> _reportStats = {};
  Map<String, int> _issueTypeStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reportStats = await _firebaseService.getReportStatistics();
      final issueTypeStats = await _firebaseService.getIssueTypeStatistics();

      setState(() {
        _reportStats = reportStats;
        _issueTypeStats = issueTypeStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportData() async {
    try {
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      final reports = reportProvider.reports;
      
      if (reports.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data to export')),
        );
        return;
      }

      // Generate CSV
      final csvContent = ExportService.exportReportsToCSV(reports);
      
      // Generate analytics report
      final analyticsReport = ExportService.generateAnalyticsReport(
        reportStats: _reportStats,
        issueTypeStats: _issueTypeStats,
        totalReports: _reportStats['total'] ?? 0,
        pendingReports: _reportStats['pending'] ?? 0,
        inProgressReports: _reportStats['inProgress'] ?? 0,
        resolvedReports: _reportStats['resolved'] ?? 0,
      );

      // Show export options
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.table_chart_rounded),
                title: const Text('Export Reports (CSV)'),
                subtitle: Text('${reports.length} reports'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadCSV(csvContent, 'reports_export.csv');
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics_rounded),
                title: const Text('Export Analytics Report'),
                subtitle: const Text('Summary statistics'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadText(analyticsReport, 'analytics_report.txt');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  void _downloadCSV(String content, String filename) {
    // For web, create download link
    // For mobile, would need path_provider
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV exported: $filename\n(Web download would be implemented here)'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _downloadText(String content, String filename) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report exported: $filename\n(Web download would be implemented here)'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export Data',
            onPressed: _exportData,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report Status Statistics
                    const Text(
                      'Report Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildStatRow(
                              'Total Reports',
                              _reportStats['total']?.toString() ?? '0',
                              Colors.blue,
                            ),
                            const Divider(),
                            _buildStatRow(
                              'Pending',
                              _reportStats['pending']?.toString() ?? '0',
                              Colors.orange,
                            ),
                            const Divider(),
                            _buildStatRow(
                              'In Progress',
                              _reportStats['inProgress']?.toString() ?? '0',
                              Colors.blue,
                            ),
                            const Divider(),
                            _buildStatRow(
                              'Resolved',
                              _reportStats['resolved']?.toString() ?? '0',
                              Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Issue Type Statistics with Pie Chart
                    const Text(
                      'Issue Type Distribution',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _issueTypeStats.isEmpty
                            ? const Text('No data available')
                            : Column(
                                children: [
                                  SizedBox(
                                    height: 200,
                                    child: _IssueTypePieChart(
                                      data: _issueTypeStats,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ..._issueTypeStats.entries.map((entry) {
                                    final color = _getColorForIssueType(entry.key);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              entry.key,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          Text(
                                            entry.value.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Status Distribution Bar Chart
                    const Text(
                      'Status Distribution',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          height: 200,
                          child: _StatusBarChart(data: _reportStats),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForIssueType(String type) {
    switch (type) {
      case 'Garbage':
        return Colors.brown;
      case 'Streetlight':
        return Colors.amber;
      case 'Flooding':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

/// Pie Chart for Issue Type Distribution
class _IssueTypePieChart extends StatelessWidget {
  final Map<String, int> data;

  const _IssueTypePieChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final total = data.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) {
      return const Center(child: Text('No data available'));
    }

    int index = 0;
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
      AppColors.danger,
    ];

    return PieChart(
      PieChartData(
        sections: data.entries.map((entry) {
          final percentage = (entry.value / total) * 100;
          final color = colors[index % colors.length];
          index++;
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: '${percentage.toStringAsFixed(1)}%',
            color: color,
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}

/// Bar Chart for Status Distribution
class _StatusBarChart extends StatelessWidget {
  final Map<String, int> data;

  const _StatusBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final statusData = [
      {'label': 'Pending', 'value': data['pending'] ?? 0, 'color': AppColors.warning},
      {'label': 'In Progress', 'value': data['inProgress'] ?? 0, 'color': AppColors.secondary},
      {'label': 'Resolved', 'value': data['resolved'] ?? 0, 'color': AppColors.success},
    ];

    final maxValue = statusData.map((e) => e['value'] as int).reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) {
      return const Center(child: Text('No data available'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue > 0 ? maxValue.toDouble() + (maxValue * 0.2) : 10,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < statusData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      statusData[index]['label'] as String,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: statusData.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (item['value'] as int).toDouble(),
                color: item['color'] as Color,
                width: 40,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

