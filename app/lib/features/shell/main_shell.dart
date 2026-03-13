import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';
import 'package:tcg_matchmaker/features/games/screens/create_game_screen.dart';
import 'package:tcg_matchmaker/features/games/screens/my_games_screen.dart';
import 'package:tcg_matchmaker/features/home/home_screen.dart';
import 'package:tcg_matchmaker/features/messages/providers/messages_provider.dart';
import 'package:tcg_matchmaker/features/messages/screens/conversations_screen.dart';
import 'package:tcg_matchmaker/features/notifications/providers/notifications_provider.dart';
import 'package:tcg_matchmaker/features/profile/screens/profile_screen.dart';
import 'package:tcg_matchmaker/shared/widgets/bottom_nav_bar.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with WidgetsBindingObserver {
  static const List<Widget> _screens = [
    HomeScreen(),
    MyGamesScreen(),
    CreateGameScreen(),
    ConversationsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPermissionsAndLoad());
  }

  Future<void> _initPermissionsAndLoad() async {
    // 1. Permission notifications (Android 13+)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Permission localisation — après que la dialog notifs soit résolue
    final locationService = ref.read(locationServiceProvider);
    await locationService.requestPermission();

    // 3. Fetch des parties (position null si refusée → message d'erreur)
    if (mounted) {
      ref.invalidate(currentPositionProvider);
      ref.read(gamesNotifierProvider.notifier).fetchExistingGames();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh badges quand l'app revient au premier plan
      ref.invalidate(hasUnreadProvider);
      ref.read(conversationsProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Active l'initialisation FCM dès que le shell est monté (user connecté)
    ref.watch(fcmInitializerProvider);

    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      extendBody: true,
      body: _screens[currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentScreen: currentIndex,
        onTap: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}
