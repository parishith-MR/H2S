import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:h2s/core/router/app_router.dart';
import 'package:h2s/core/theme/app_theme.dart';
import 'package:h2s/providers/auth_provider.dart';
import 'package:h2s/providers/dashboard_provider.dart';
import 'package:h2s/providers/video_provider.dart';

void main() {
  runApp(const SportShieldApp());
}

class SportShieldApp extends StatelessWidget {
  const SportShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.create();
          return MaterialApp.router(
            title: 'SportShield AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
