import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Politique de confidentialité',
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Politique de confidentialité',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dernière mise à jour : 23 mars 2026',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              title: '1. Introduction',
              content:
                  'DuelFinder respecte la vie privée de ses utilisateurs et s\'engage à protéger leurs données personnelles.\n\n'
                  'Cette politique explique quelles données sont collectées et comment elles sont utilisées.',
            ),
            _buildSection(
              theme,
              title: '2. Données collectées',
              content:
                  'Lors de l\'utilisation de l\'application, DuelFinder peut collecter :\n'
                  '• Adresse email.\n'
                  '• Pseudonyme.\n'
                  '• Photo de profil.\n'
                  '• Localisation approximative.\n'
                  '• Données liées aux parties (création, participation).',
            ),
            _buildSection(
              theme,
              title: '3. Utilisation des données',
              content:
                  'Les données collectées servent à :\n'
                  '• Créer et gérer les comptes utilisateurs.\n'
                  '• Afficher les joueurs et parties à proximité.\n'
                  '• Améliorer le fonctionnement de l\'application.\n'
                  '• Assurer la sécurité du service.',
            ),
            _buildSection(
              theme,
              title: '4. Localisation',
              content:
                  'La localisation de l\'utilisateur peut être utilisée pour afficher les parties et joueurs proches.\n\n'
                  'L\'utilisateur peut refuser ou désactiver la localisation dans les paramètres de son appareil.',
            ),
            _buildSection(
              theme,
              title: '5. Partage des données',
              content:
                  'DuelFinder ne vend pas les données personnelles des utilisateurs.\n\n'
                  'Certaines données peuvent être traitées par des services techniques nécessaires au fonctionnement de l\'application.',
            ),
            _buildSection(
              theme,
              title: '6. Conservation des données',
              content:
                  'Les données sont conservées tant que le compte utilisateur est actif.\n\n'
                  'Lorsque l\'utilisateur supprime son compte, ses données sont supprimées dans un délai raisonnable.',
            ),
            _buildSection(
              theme,
              title: '7. Droits des utilisateurs',
              content:
                  'L\'utilisateur peut :\n'
                  '• Accéder à ses données.\n'
                  '• Modifier ses informations.\n'
                  '• Supprimer son compte.',
            ),
            _buildSection(
              theme,
              title: '8. Sécurité des données',
              content:
                  'DuelFinder met en place des mesures raisonnables pour protéger les données personnelles.\n\n'
                  'Cependant, aucun système informatique ne peut garantir une sécurité absolue.',
            ),
            _buildSection(
              theme,
              title: '9. Modifications de la politique',
              content:
                  'Cette politique de confidentialité peut être mise à jour pour refléter les évolutions du service.',
            ),
            _buildSection(
              theme,
              title: '10. Contact',
              content: 'Pour toute question concernant la confidentialité : contact@duelfinder.com',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, {required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
