import 'package:go_router/go_router.dart';
import 'package:project/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:project/features/realtime_dashboard/presentation/screens/dashboard_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard-alt',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
  );
}
