import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Conditions d'utilisation",
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
              "Conditions d'utilisation",
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
            // ── Remplacez le contenu ci-dessous par vos vraies CGU ──
            _buildSection(
              theme,
              title: '1. Objet',
              content:
                  'Les présentes Conditions Générales d\'Utilisation (CGU) ont pour objet de définir les modalités et conditions d\'utilisation des services proposés par DuelFinder, ainsi que les droits et obligations des parties dans ce cadre.',
            ),
            _buildSection(
              theme,
              title: '2. Accès au service',
              content:
                  'L\'utilisation de l\'application DuelFinder est réservée aux personnes majeures ou aux mineurs avec accord parental. L\'accès au service est conditionné à la création d\'un compte utilisateur avec des informations exactes et sincères.',
            ),
            _buildSection(
              theme,
              title: '3. Compte utilisateur',
              content:
                  'Vous êtes responsable de la confidentialité de vos identifiants de connexion. Toute utilisation du service effectuée depuis votre compte est réputée avoir été effectuée par vous. DuelFinder se réserve le droit de supprimer tout compte contenant des informations fausses ou violant les présentes CGU.',
            ),
            _buildSection(
              theme,
              title: '4. Utilisation acceptable',
              content:
                  'Vous vous engagez à utiliser DuelFinder de manière loyale et conformément aux lois applicables. Il est interdit de publier des contenus illicites, offensants, trompeurs ou portant atteinte aux droits de tiers. DuelFinder se réserve le droit de suspendre ou supprimer tout compte en cas de violation.',
            ),
            _buildSection(
              theme,
              title: '5. Responsabilité',
              content:
                  'DuelFinder est une plateforme de mise en relation entre joueurs. La responsabilité de DuelFinder ne saurait être engagée en cas de litiges entre utilisateurs, de non-présentation à une partie, ou de tout préjudice résultant d\'une rencontre organisée via l\'application.',
            ),
            _buildSection(
              theme,
              title: '6. Modification des CGU',
              content:
                  'DuelFinder se réserve le droit de modifier les présentes CGU à tout moment. Les utilisateurs seront informés des modifications importantes. La poursuite de l\'utilisation du service vaut acceptation des nouvelles CGU.',
            ),
            _buildSection(
              theme,
              title: '7. Contact',
              content:
                  'Pour toute question relative aux présentes CGU, vous pouvez nous contacter à l\'adresse : contact@duelfinder.com',
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
