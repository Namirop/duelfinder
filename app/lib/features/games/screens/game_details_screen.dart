import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran de détails d'une partie
/// TODO: Implémenter l'affichage des détails
class GameDetailsScreen extends ConsumerWidget {
  final String gameId;

  const GameDetailsScreen({
    super.key,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implémenter l'UI des détails
    // - Infos de la partie (titre, type, date, lieu)
    // - Carte Google Maps avec localisation
    // - Liste des participants
    // - Bouton rejoindre/quitter
    // - Infos organisateur
    return const Scaffold(
      body: Center(
        child: Text('GameDetailsScreen - TODO'),
      ),
    );
  }
}
