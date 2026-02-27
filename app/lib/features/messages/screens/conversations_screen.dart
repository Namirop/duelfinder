import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran de liste des conversations
/// TODO: Implémenter l'affichage des conversations
class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implémenter l'UI de liste des conversations
    // - Liste des conversations avec aperçu dernier message
    // - Badge messages non lus
    // - Avatar et nom du contact
    // - Date du dernier message
    return const SafeArea(
      bottom: false,
      child: Center(
        child: Text('ConversationsScreen - TODO'),
      ),
    );
  }
}
