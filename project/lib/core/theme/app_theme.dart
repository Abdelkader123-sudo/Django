import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class AppTextStyles {
  static const dashboardTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const metricLabel = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  static const metricValue = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const chartTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
}