import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/features/realtime_dashboard/models/dashboard_data.dart';
import 'package:project/features/realtime_dashboard/models/measurement.dart';
import 'package:project/features/realtime_dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  testWidgets('connection error offers retry', (WidgetTester tester) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardConnectionError(onRetry: () => retried = true),
        ),
      ),
    );

    expect(find.text('Connexion au serveur impossible'), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    expect(retried, isTrue);
  });

  testWidgets('dashboard body displays current sensor data', (
    WidgetTester tester,
  ) async {
    final measurement = Measurement(
      value: 23.5,
      timestamp: DateTime(2026),
      measurementType: MeasurementType.temperature,
    );
    final data = DashboardData(
      current: measurement,
      history: [measurement],
      avg: 23.5,
      min: 23.5,
      max: 23.5,
    );

    await tester.pumpWidget(MaterialApp(home: DashboardBody(data: data)));

    expect(find.text('23.5'), findsOneWidget);
    expect(find.text('Average'), findsOneWidget);
    expect(find.text('Maximum'), findsOneWidget);
    expect(find.text('Minimum'), findsOneWidget);
  });
}
