import 'package:flutter/material.dart';
import 'package:project/features/realtime_dashboard/models/dashboard_data.dart';
import 'package:project/features/realtime_dashboard/presentation/widgets/metric_card.dart';

class MetricsGrid extends StatelessWidget {
  final bool isMobile;
  final DashboardData? data;
  final double avg;
  final double min;
  final double max;
  final int points;

  const MetricsGrid({
    super.key,
    required this.isMobile,
    this.data,
    this.avg = 0,
    this.min = 0,
    this.max = 0,
    this.points = 0,
  });

  double get _avg => data?.avg ?? avg;
  double get _min => data?.min ?? min;
  double get _max => data?.max ?? max;
  int get _points => data?.history.length ?? points;

  @override
  Widget build(BuildContext context) {
    final cards = [
      MetricCard(
        title: 'Average',
        value: _avg.toStringAsFixed(2),
      ),
      MetricCard(
        title: 'Maximum',
        value: _max.toStringAsFixed(2),
      ),
      MetricCard(
        title: 'Minimum',
        value: _min.toStringAsFixed(2),
      ),
      MetricCard(
        title: 'Points',
        value: _points.toString(),
      ),
    ];

    if (isMobile) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: cards,
      );
    }

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: cards,
    );
  }
}