import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

const String mapboxAccessToken =
    'pk.eyJ1IjoibmFtaXJvcCIsImEiOiJjbW0yMmtmZDQwMmJzMnJzZHNjb3F6MjJlIn0.xK6GRkd-sJ9usDruhQ-ZrA';

/// Handler pour les messages Firebase reçus quand l'app est en arrière-plan ou fermée.
/// Doit être une fonction top-level (pas une méthode de classe).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase est déjà initialisé, rien à faire ici.
  // Le système Android/iOS affiche la notification nativement.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    initializeDateFormatting('fr_FR', null),
    Firebase.initializeApp(),
  ]);

  // Enregistre le handler background APRÈS l'init Firebase
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Configuration MapBox
  MapboxOptions.setAccessToken(mapboxAccessToken);

  runApp(
    const ProviderScope(
      child: TCGMatchmakerApp(),
    ),
  );
}

/// Application principale TCG Matchmaker
class TCGMatchmakerApp extends ConsumerWidget {
  const TCGMatchmakerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'TCG Matchmaker',
      debugShowCheckedModeBanner: false,

      // Thème - Dark mode forcé pour correspondre au logo
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Router
      routerConfig: router,
    );
  }
}
