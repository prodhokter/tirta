import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tirta/core/constants/app_routes.dart';
import 'package:tirta/features/auth/presentation/screens/login_screen.dart';
import 'package:tirta/features/auth/presentation/screens/register_screen.dart';
import 'package:tirta/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:tirta/features/auth/presentation/screens/profile_screen.dart';
import 'package:tirta/features/auth/presentation/screens/splash_screen.dart';
import 'package:tirta/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:tirta/features/chatbot/presentation/screens/chat_screen.dart';
import 'package:tirta/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:tirta/features/education/presentation/screens/education_screen.dart';
import 'package:tirta/features/education/presentation/screens/article_detail_screen.dart';
import 'package:tirta/features/expert_system/presentation/screens/expert_system_intro_screen.dart';
import 'package:tirta/features/expert_system/presentation/screens/question_screen.dart';
import 'package:tirta/features/expert_system/presentation/screens/result_screen.dart';
import 'package:tirta/features/history/presentation/screens/history_screen.dart';
import 'package:tirta/features/history/presentation/screens/history_detail_screen.dart';
import 'package:tirta/shared/services/supabase_service.dart';
import 'package:tirta/shared/widgets/bottom_navbar.dart';

export 'package:tirta/core/theme/app_theme.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = SupabaseService.currentSession != null;
      final isGoingToLogin = state.matchedLocation == AppRoutes.login;
      final isGoingToRegister = state.matchedLocation == AppRoutes.register;
      final isGoingToSplash = state.matchedLocation == AppRoutes.splash;
      
      if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister && !isGoingToSplash) {
        return AppRoutes.login;
      }
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.question,
        builder: (context, state) => const QuestionScreen(),
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) => const ResultScreen(),
      ),
      GoRoute(
        path: AppRoutes.articleDetail,
        builder: (context, state) {
          final articleId = state.extra as String?;
          return ArticleDetailScreen(articleId: articleId ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.historyDetail,
        builder: (context, state) {
          final examinationId = state.extra as String?;
          return HistoryDetailScreen(examinationId: examinationId ?? '');
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          int currentIndex = 0;
          final path = state.matchedLocation;
          if (path == AppRoutes.dashboard) {
            currentIndex = 0;
          } else if (path.startsWith('/expert-system')) {
            currentIndex = 1;
          } else if (path.startsWith('/chat')) {
            currentIndex = 2;
          } else if (path.startsWith('/education')) {
            currentIndex = 3;
          } else if (path.startsWith('/history')) {
            currentIndex = 4;
          }
          return ScaffoldWithNavbar(
            currentIndex: currentIndex,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.expertSystemIntro,
            builder: (context, state) => const ExpertSystemIntroScreen(),
          ),
          GoRoute(
            path: AppRoutes.chat,
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: AppRoutes.education,
            builder: (context, state) => const EducationScreen(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) => const HistoryScreen(),
          ),
        ],
      ),
    ],
  );
}
