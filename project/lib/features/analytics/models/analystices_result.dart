import 'package:project/features/realtime_dashboard/models/measurement.dart';

import 'statistics.dart';

class AnalyticsResult {
  final List<Measurement> measurements;
  final Statistics statistics;

  const AnalyticsResult({
    required this.measurements,
    required this.statistics,
  });
}