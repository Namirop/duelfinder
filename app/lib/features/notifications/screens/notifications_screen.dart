import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran de liste des notifications
/// TODO: Implémenter l'affichage des notifications
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implémenter l'UI de liste des notifications
    // - Liste des notifications avec icône selon le type
    // - Indicateur non lu
    // - Action au tap (navigation vers la ressource)
    // - Swipe pour supprimer
    // - Bouton "Tout marquer comme lu"
    return const Scaffold(
      body: Center(
        child: Text('NotificationsScreen - TODO'),
      ),
    );
  }
}
