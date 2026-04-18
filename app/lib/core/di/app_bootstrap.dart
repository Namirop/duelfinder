import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Handler background FCM — obligatoirement top-level (pas dans une classe)
/// car il tourne dans un isolate séparé quand l'app est en arrière-plan.
/// Le corps est vide : l'OS affiche la notification nativement.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Initialise toute l'infra avant runApp().
/// Aucune dépendance Riverpod — pure initialisation plateforme.
Future<void> bootstrapApp() async {
  await initializeDateFormatting('fr_FR', null);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_TOKEN'] ?? '');
}
