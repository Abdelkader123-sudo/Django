import 'package:project/features/realtime_dashboard/models/measurement.dart';
class DashboardData {
  final Measurement current;
  final List<Measurement> history;
  final double avg;
  final double min ;
  final double max;

  DashboardData({
  required this.current,
  required this.history,
  required this.avg,
  required this.min,
  required this.max,
  });
}