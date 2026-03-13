import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tcg_matchmaker/features/auth/providers/auth_notifier.dart';
import 'package:tcg_matchmaker/features/games/screens/create_game_screen.dart';
import 'package:tcg_matchmaker/features/games/screens/my_games_screen.dart';
import 'package:tcg_matchmaker/features/profile/screens/profile_screen.dart';
import 'package:tcg_matchmaker/features/profile/screens/settings_screen.dart';
import 'package:tcg_matchmaker/features/shell/main_shell.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/messages/screens/chat_screen.dart';
import '../../features/messages/screens/conversations_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';

/// Routes de l'application
abstract class AppRoutes {
  // Auth
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  // Home
  static const String home = '/';

  // Games
  static const String myGames = '/mygames';
  static const String createGame = '/games/create';

  // Messages
  static const String messages = '/messages';
  static const String conversation = '/messages/:id';

  // Notifications
  static const String notifications = '/notifications';

  // Profile
  static const String profile = '/profile';
  static const String settings = '/settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (authState.isLoading) {
        return isSplash ? null : AppRoutes.splash;
      }

      if (isSplash) {
        return authState.isAuthenticated ? AppRoutes.home : AppRoutes.login;
      }

      if (!authState.isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }

      if (authState.isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const MainShell()),
      GoRoute(
          path: AppRoutes.myGames,
          name: 'myGames',
          builder: (context, state) => const MyGamesScreen()),
      GoRoute(
          path: AppRoutes.createGame,
          name: 'createGame',
          builder: (context, state) => const CreateGameScreen()),
          GoRoute(
        path: AppRoutes.messages,
        name: 'messages',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.conversation,
        name: 'conversation',
        builder: (context, state) {
          final gameId = state.pathParameters['id']!;
          return ChatScreen(conversationId: gameId);
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen()),
      GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen()),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Text('Page non trouvée: ${state.uri}'),
        ),
      );
    },
  );
});
