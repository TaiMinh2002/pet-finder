import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../data/datasources/remote/auth_remote_datasource.dart';
import '../injection_container.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/create_post/create_post_page.dart';
import '../presentation/pages/dashboard/dashboard_page.dart';
import '../presentation/pages/map/map_page.dart';
import '../presentation/pages/notifications/notifications_page.dart';
import '../presentation/pages/onboarding/onboarding_page.dart';
import '../presentation/pages/post_detail/post_detail_page.dart';
import '../presentation/pages/post_list/post_list_page.dart';
import '../presentation/pages/profile/profile_page.dart';
import '../presentation/pages/settings/settings_page.dart';
import '../presentation/pages/splash/splash_page.dart';

final router = GoRouter(
  initialLocation: '/splash',
  redirect: _redirect,
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
    GoRoute(path: '/auth/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/auth/register', builder: (_, __) => const RegisterPage()),
    ShellRoute(
      builder: (context, state, child) => DashboardPage(child: child),
      routes: [
        GoRoute(path: '/map', builder: (_, __) => const MapPage()),
        GoRoute(path: '/posts', builder: (_, __) => const PostListPage()),
        GoRoute(path: '/create', builder: (_, __) => const CreatePostPage()),
        GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      ],
    ),
    GoRoute(
      path: '/posts/:postId',
      builder: (_, state) => PostDetailPage(
        postId: state.pathParameters['postId']!,
      ),
    ),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
  ],
);

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final authDs = sl<AuthRemoteDataSource>();
  final isOnSplash = state.matchedLocation == '/splash';
  final isOnOnboarding = state.matchedLocation == '/onboarding';
  final isOnAuth = state.matchedLocation.startsWith('/auth');

  // Always allow splash to load first
  if (isOnSplash) return null;

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool(AppConstants.keyOnboardingDone) ?? false;

  if (!onboardingDone && !isOnOnboarding) return '/onboarding';

  final isLoggedIn = authDs.currentUser != null;
  if (!isLoggedIn && !isOnAuth) return '/auth/login';
  if (isLoggedIn && isOnAuth) return '/map';

  return null;
}
