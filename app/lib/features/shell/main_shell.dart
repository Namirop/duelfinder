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
import 'package:tcg_matchmaker/features/notifications/providers/fcm_initializer.dart';
import 'package:tcg_matchmaker/features/notifications/providers/notifications_provider.dart';
import 'package:tcg_matchmaker/features/participations/providers/participations_notifier.dart';
import 'package:tcg_matchmaker/features/profile/providers/settings_provider.dart';
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
    // permet au widget de recevoir didChangeAppLifecycleState, sinon il n'est jamais appelé
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _requestPermissionsAndLoadInitialData());
  }

  /// Point d'orchestration central : charge les données initiales, demande
  /// les permissions OS, et initialise FCM. Les notifiers ont un sync build
  /// vide — c'est ici qu'on déclenche les premiers fetches, dans un ordre
  /// maîtrisé (données sans dépendance d'abord, localisation ensuite).
  Future<void> _requestPermissionsAndLoadInitialData() async {
    // 1. Données sans dépendance localisation : on lance immédiatement
    ref.read(notificationsNotifierProvider.notifier).fetchNotifications();
    ref.read(participationsNotifierProvider.notifier).fetchMyParticipations();
    ref.read(gamesNotifierProvider.notifier).fetchCreatedGames();
    ref.read(messagesNotifierProvider.notifier).fetchConversations();

    // 2. Permission notifications (Android 13+) puis init FCM
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    // FCM initialisé après la permission pour avoir le token valide
    ref.read(fcmInitializerProvider.notifier).initialize();

    // 3. Permission localisation — après que la dialog notifs soit résolue
    final locationService = ref.read(locationServiceProvider);
    final hasPermission = await locationService.requestPermission();

    // 4. Met à jour la localisation puis lance le fetch des parties
    if (mounted) {
      ref
          .read(settingsNotifierProvider.notifier)
          .setLocationEnabledSilently(hasPermission);
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
    // quand l’utilisateur revient dans l’app
    // on revérifie si messages reçus ou notif changées pendant absence
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationsNotifierProvider.notifier).fetchNotifications();
      ref.read(messagesNotifierProvider.notifier).fetchConversations();
      ref.read(gamesNotifierProvider.notifier).fetchCreatedGames();
      ref.read(participationsNotifierProvider.notifier).fetchMyParticipations();
    }
  }

  @override
  Widget build(BuildContext context) {
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
