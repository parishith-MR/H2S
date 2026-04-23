import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF080B14);
  static const Color surface = Color(0xFF0D1220);
  static const Color card = Color(0xFF131929);
  static const Color cardHover = Color(0xFF1A2235);
  static const Color primary = Color(0xFF00D4FF);
  static const Color primaryDark = Color(0xFF0099BB);
  static const Color accent = Color(0xFF7B2FFF);
  static const Color accentLight = Color(0xFF9D5FFF);
  static const Color success = Color(0xFF00E5A0);
  static const Color warning = Color(0xFFFF9500);
  static const Color danger = Color(0xFFFF3B5C);
  static const Color textPrimary = Color(0xFFE8EAED);
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color border = Color(0xFF1E2D45);
  static const Color divider = Color(0xFF162032);
  static const Color shimmer = Color(0xFF1E2A40);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF7B2FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF060910), Color(0xFF0D1220), Color(0xFF060910)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Map<String, Color> categoryColors = {
    'Football': Color(0xFF00D4FF),
    'Cricket': Color(0xFF00E5A0),
    'Tennis': Color(0xFFFF9500),
    'Basketball': Color(0xFFFF3B5C),
    'Baseball': Color(0xFF7B2FFF),
    'Hockey': Color(0xFF00B4D8),
    'Rugby': Color(0xFFF72585),
    'Swimming': Color(0xFF4CC9F0),
    'Athletics': Color(0xFFFFBE0B),
    'Other': Color(0xFF8892A4),
  };
}

class AppSizes {
  AppSizes._();
  static const double navWidth = 240.0;
  static const double navWidthCollapsed = 70.0;
  static const double borderRadius = 12.0;
  static const double cardPadding = 20.0;
  static const double pagePadding = 24.0;
}

class AppStrings {
  AppStrings._();
  static const String appName = 'SportShield AI';
  static const String tagline = 'Shield Every Frame. Protect Every Play.';
  static const String version = 'v1.0.0';
  static const String description =
      'AI-powered digital asset protection for sports organizations. '
      'Detect unauthorized use of your media content instantly.';
}

class AppCategories {
  AppCategories._();
  static const List<String> all = [
    'Football',
    'Cricket',
    'Tennis',
    'Basketball',
    'Baseball',
    'Hockey',
    'Rugby',
    'Swimming',
    'Athletics',
    'Other',
  ];
}

class RiskLevel {
  static const String low = 'Low';
  static const String medium = 'Medium';
  static const String high = 'High';

  static Color getColor(String level) {
    switch (level) {
      case high:
        return AppColors.danger;
      case medium:
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  static IconData getIcon(String level) {
    switch (level) {
      case high:
        return Icons.warning_rounded;
      case medium:
        return Icons.info_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  static String fromScore(double score) {
    if (score >= 0.65) return high;
    if (score >= 0.40) return medium;
    return low;
  }
}
