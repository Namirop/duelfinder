// TODO: Réactiver Firebase quand configuré
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

const String mapboxAccessToken =
    'pk.eyJ1IjoibmFtaXJvcCIsImEiOiJjbW0yMmtmZDQwMmJzMnJzZHNjb3F6MjJlIn0.xK6GRkd-sJ9usDruhQ-ZrA';

// TODO: Réactiver quand Firebase est configuré
// /// Handler pour les messages Firebase en background
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   debugPrint('Background message: ${message.messageId}');
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    initializeDateFormatting('fr_FR', null),
  ]);

  // Configuration MapBox
  MapboxOptions.setAccessToken(mapboxAccessToken);

  // TODO: Réactiver quand Firebase est configuré
  // await Firebase.initializeApp();
  // await _initFirebaseMessaging();

  runApp(
    const ProviderScope(
      child: TCGMatchmakerApp(),
    ),
  );
}

// TODO: Réactiver quand Firebase est configuré
// Future<void> _initFirebaseMessaging() async {
//   final messaging = FirebaseMessaging.instance;
//   final settings = await messaging.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//     provisional: false,
//   );
//   debugPrint('FCM Permission: ${settings.authorizationStatus}');
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
// }

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
