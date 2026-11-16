import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/features/realtime_dashboard/models/dashboard_data.dart';
import 'package:project/features/realtime_dashboard/presentation/widgets/current_temperature_card.dart';
import 'package:project/features/realtime_dashboard/presentation/widgets/mertics_grid.dart';
import 'package:project/features/realtime_dashboard/presentation/widgets/realtime_chart.dart';
import 'package:project/features/realtime_dashboard/services/dashboard_service.dart';
import 'package:project/features/realtime_dashboard/services/websocket_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardService _dashboardService;

  @override
  void initState() {
    super.initState();
    _startDashboardService();
  }

  void _startDashboardService() {
    _dashboardService = DashboardService(WebSocketService())..start();
  }

  void _retryConnection() {
    final previousService = _dashboardService;
    setState(_startDashboardService);
    unawaited(previousService.dispose());
  }

  @override
  void dispose() {
    unawaited(_dashboardService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Dashboard'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/analytics'),
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('Analytics'),
          ),
        ],
      ),
      body: StreamBuilder<DashboardData>(
        stream: _dashboardService.dashboardStream,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return DashboardConnectionError(onRetry: _retryConnection);
          }

          if (!asyncSnapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connexion aux mesures...'),
                ],
              ),
            );
          }

          final data = asyncSnapshot.data!;
          return DashboardBody(data: data);
        },
      ),
    );
  }
}

class DashboardConnectionError extends StatelessWidget {
  final VoidCallback onRetry;

  const DashboardConnectionError({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Connexion au serveur impossible',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Vérifiez que Django et Redis sont démarrés, puis réessayez.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardBody extends StatelessWidget {
  final DashboardData data;

  const DashboardBody({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CurrentTemperatureCard(value: data.current.value),

              const SizedBox(height: 16),

              MetricsGrid(
                isMobile: isMobile,
                data: data,
              ),

              const SizedBox(height: 16),

              RealtimeChart(measurements: data.history),
            ],
          ),
        );
      },
    );
  }
}
