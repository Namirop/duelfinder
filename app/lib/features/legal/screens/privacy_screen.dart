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
              'Dernière mise à jour : janvier 2025',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            // ── Remplacez le contenu ci-dessous par votre vraie politique ──
            _buildSection(
              theme,
              title: '1. Responsable du traitement',
              content:
                  'DuelFinder est le responsable du traitement de vos données personnelles. Pour toute question relative à la protection de vos données, contactez-nous à : contact@duelfinder.com',
            ),
            _buildSection(
              theme,
              title: '2. Données collectées',
              content:
                  'Nous collectons les données suivantes :\n'
                  '• Données d\'identification : adresse e-mail, pseudo\n'
                  '• Données de localisation : position géographique (avec votre consentement)\n'
                  '• Données de profil : photo de profil, biographie\n'
                  '• Données d\'usage : parties créées, participations, messages',
            ),
            _buildSection(
              theme,
              title: '3. Finalités du traitement',
              content:
                  'Vos données sont utilisées pour :\n'
                  '• Créer et gérer votre compte\n'
                  '• Vous mettre en relation avec d\'autres joueurs\n'
                  '• Vous envoyer des notifications relatives à vos parties\n'
                  '• Améliorer nos services',
            ),
            _buildSection(
              theme,
              title: '4. Base légale',
              content:
                  'Le traitement de vos données est fondé sur votre consentement (lors de la création de compte) et sur l\'exécution du contrat de service que vous avez accepté.',
            ),
            _buildSection(
              theme,
              title: '5. Conservation des données',
              content:
                  'Vos données sont conservées pendant la durée de vie de votre compte et supprimées dans un délai de 30 jours suivant la suppression de votre compte.',
            ),
            _buildSection(
              theme,
              title: '6. Vos droits',
              content:
                  'Conformément au RGPD, vous disposez des droits suivants :\n'
                  '• Droit d\'accès à vos données\n'
                  '• Droit de rectification\n'
                  '• Droit à l\'effacement (via la suppression du compte)\n'
                  '• Droit à la portabilité\n'
                  '• Droit d\'opposition\n\n'
                  'Pour exercer ces droits, contactez-nous à : contact@duelfinder.com',
            ),
            _buildSection(
              theme,
              title: '7. Sécurité',
              content:
                  'Nous mettons en œuvre des mesures techniques et organisationnelles appropriées pour protéger vos données contre tout accès non autorisé, perte ou altération.',
            ),
            _buildSection(
              theme,
              title: '8. Contact',
              content:
                  'Pour toute question ou réclamation concernant la protection de vos données personnelles, contactez-nous à : contact@duelfinder.com',
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
