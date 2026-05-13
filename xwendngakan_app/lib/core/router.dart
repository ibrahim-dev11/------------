import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../features/auth/role_selection_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/home/main_shell.dart';
import '../features/home/home_screen.dart';
import '../features/institutions/institutions_screen.dart';
import '../features/institutions/institution_detail_screen.dart';
import '../features/teachers/teachers_screen.dart';
import '../features/teachers/teacher_profile_screen.dart';
import '../features/saved/saved_screen.dart';
import '../features/teachers/teacher_register_screen.dart';
import '../features/cv/cv_screen.dart';
import '../features/cv/cv_detail_screen.dart';
import '../features/news/news_screen.dart';
import '../features/events/events_screen.dart';
import '../features/cv/cv_form_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/institutions/map_screen.dart';
import '../features/profile/privacy_policy_screen.dart';
import '../features/home/qr_scanner_screen.dart';
import '../features/news/news_detail_screen.dart';
import '../data/models/news_model.dart';
import '../data/models/post_model.dart';
import '../features/pathfinder/path_finder_screen.dart';
import '../features/lost_and_found/lost_and_found_screen.dart';
import '../features/lost_and_found/add_item_screen.dart';
import '../features/language/language_selection_screen.dart';
 

GoRouter createRouter(BuildContext context) {
  final auth = Provider.of<AuthProvider>(context, listen: false);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuth = auth.status == AuthStatus.authenticated;
      final isInitial = auth.status == AuthStatus.initial;
      final loc = state.uri.toString();

      if (isInitial) return null;

      final publicRoutes = ['/splash', '/language-select', '/onboarding', '/login', '/register', '/forgot-password', '/role-selection', '/teacher-register', '/cv-form'];
      final isPublic = publicRoutes.any((r) => loc.startsWith(r));

      if (!isAuth && !isPublic) return '/login';
      if (isAuth && (loc == '/login' || loc == '/register')) return '/home';

      return null;
    },
    refreshListenable: auth,
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Language selection (shown once at first launch, or from settings)
      GoRoute(
        path: '/language-select',
        builder: (context, state) {
          final fromSettings = state.uri.queryParameters['from'] == 'settings';
          return LanguageSelectionScreen(fromSettings: fromSettings);
        },
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/institutions',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return InstitutionsScreen(initialFilter: extra);
            },
          ),
          GoRoute(
            path: '/news',
            builder: (context, state) => const NewsScreen(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventsScreen(),
          ),
          GoRoute(
            path: '/teachers',
            builder: (context, state) => const TeachersScreen(),
          ),
          GoRoute(
            path: '/cvs',
            builder: (context, state) => const CvScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/saved',
            builder: (context, state) => const SavedScreen(),
          ),
        ],
      ),

      // Detail screens
      GoRoute(
        path: '/institutions/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          return InstitutionDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/teacher-register',
        builder: (context, state) => const TeacherRegisterScreen(),
      ),
      GoRoute(
        path: '/cv-form',
        builder: (context, state) => const CvFormScreen(),
      ),
      GoRoute(
        path: '/path-finder',
        builder: (context, state) => const PathFinderScreen(),
      ),
      GoRoute(
        path: '/lost-and-found',
        builder: (context, state) => const LostAndFoundScreen(),
      ),
      GoRoute(
        path: '/lost-and-found/add',
        builder: (context, state) => const AddLostItemScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/teachers/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          return TeacherProfileScreen(id: id);
        },
      ),
      GoRoute(
        path: '/cvs/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          return CvDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const QrScannerScreen(),
      ),


      GoRoute(
        path: '/news-detail',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is NewsModel) {
            return NewsDetailScreen(news: extra);
          } else if (extra is PostModel) {
            return NewsDetailScreen(post: extra);
          }
          return const SizedBox.shrink();
        },
      ),
      GoRoute(
        path: '/path-finder',
        builder: (context, state) => const PathFinderScreen(),
      ),
    ],
  );
}
