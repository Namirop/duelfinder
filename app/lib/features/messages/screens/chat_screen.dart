import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran de chat (conversation)
/// TODO: Implémenter l'interface de chat
class ChatScreen extends ConsumerWidget {
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implémenter l'UI de chat
    // - Liste des messages (bulles)
    // - Input pour écrire un message
    // - Bouton envoyer
    // - Scroll automatique vers le bas
    // - Pagination des anciens messages
    return const Scaffold(
      body: Center(
        child: Text('ChatScreen - TODO'),
      ),
    );
  }
}
