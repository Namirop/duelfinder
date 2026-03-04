import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/features/games/screens/create_game_screen.dart';
import 'package:tcg_matchmaker/features/games/screens/my_games_screen.dart';
import 'package:tcg_matchmaker/features/home/home_screen.dart';
import 'package:tcg_matchmaker/features/messages/screens/conversations_screen.dart';
import 'package:tcg_matchmaker/features/notifications/providers/notifications_provider.dart';
import 'package:tcg_matchmaker/features/profile/screens/profile_screen.dart';
import 'package:tcg_matchmaker/shared/widgets/bottom_nav_bar.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    MyGamesScreen(),
    CreateGameScreen(),
    ConversationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Active l'initialisation FCM dès que le shell est monté (user connecté)
    ref.watch(fcmInitializerProvider);

    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      extendBody: true,
      body: _screens[currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentScreen: currentIndex,
        onTap: (index) =>
            ref.read(navigationIndexProvider.notifier).state = index,
      ),
    );
  }
}
