import 'dart:convert';

import 'package:project/features/realtime_dashboard/models/measurement.dart';

List<Measurement> parseMeasurements(String responseBody) {
  final List<dynamic> data = jsonDecode(responseBody);

  return data.map((json) => Measurement.fromJson(json)).toList();
}