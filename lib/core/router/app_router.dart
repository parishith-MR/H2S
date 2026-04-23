import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:h2s/pages/admin/admin_panel_page.dart';
import 'package:h2s/pages/auth/login_page.dart';
import 'package:h2s/pages/auth/signup_page.dart';
import 'package:h2s/pages/dashboard/dashboard_page.dart';
import 'package:h2s/pages/landing/landing_page.dart';
import 'package:h2s/pages/match_result/match_result_page.dart';
import 'package:h2s/pages/processing/processing_page.dart';
import 'package:h2s/pages/upload/upload_page.dart';
import 'package:h2s/pages/verify/verify_page.dart';
import 'package:h2s/providers/auth_provider.dart';

class AppRouter {
  static GoRouter create() {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final auth = context.read<AuthProvider>();
        final isLoggedIn = auth.isLoggedIn;
        final path = state.uri.path;

        // Public routes
        final publicRoutes = ['/', '/login', '/signup'];
        final isPublic = publicRoutes.contains(path);

        if (!isLoggedIn && !isPublic) {
          return '/login';
        }

        if (isLoggedIn && (path == '/login' || path == '/signup')) {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'landing',
          builder: (context, state) => const LandingPage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupPage(),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/upload',
          name: 'upload',
          builder: (context, state) => const UploadPage(),
        ),
        GoRoute(
          path: '/processing/:videoId',
          name: 'processing',
          builder: (context, state) => ProcessingPage(
            videoId: state.pathParameters['videoId']!,
          ),
        ),
        GoRoute(
          path: '/verify',
          name: 'verify',
          builder: (context, state) => const VerifyPage(),
        ),
        GoRoute(
          path: '/match/:matchId',
          name: 'match',
          builder: (context, state) => MatchResultPage(
            matchId: state.pathParameters['matchId']!,
          ),
        ),
        GoRoute(
          path: '/admin',
          name: 'admin',
          builder: (context, state) => const AdminPanelPage(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        backgroundColor: const Color(0xFF080B14),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Color(0xFF00D4FF), size: 64),
              const SizedBox(height: 16),
              Text(
                '404 — Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
