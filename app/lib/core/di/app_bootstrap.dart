import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Handler top-level obligatoire pour Firebase Messaging (isolate séparé).
/// Doit être déclaré ici (top-level) pour être accessible depuis main().
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Le système Android/iOS affiche la notification nativement.
}

/// Initialise toute l'infra avant runApp().
/// Aucune dépendance Riverpod — pure initialisation plateforme.
Future<void> bootstrapApp() async {
  await initializeDateFormatting('fr_FR', null);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_TOKEN'] ?? '');
}
