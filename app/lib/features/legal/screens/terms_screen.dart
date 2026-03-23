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
              'Dernière mise à jour : 23 mars 2026',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              title: '1. Présentation du service',
              content:
                  'DuelFinder est une application permettant aux utilisateurs de trouver des joueurs à proximité et d\'organiser des parties de jeux dans la vie réelle (IRL).\n\n'
                  'L\'application agit comme une plateforme de mise en relation entre joueurs. DuelFinder ne participe pas à l\'organisation physique des rencontres et n\'intervient pas dans leur déroulement.',
            ),
            _buildSection(
              theme,
              title: '2. Acceptation des conditions',
              content:
                  'En créant un compte ou en utilisant l\'application DuelFinder, l\'utilisateur accepte les présentes conditions d\'utilisation.\n\n'
                  'Si l\'utilisateur n\'accepte pas ces conditions, il ne doit pas utiliser l\'application.',
            ),
            _buildSection(
              theme,
              title: '3. Conditions d\'accès',
              content:
                  'Pour utiliser l\'application, l\'utilisateur doit :\n'
                  '• Être âgé d\'au moins 13 ans. Les utilisateurs mineurs doivent utiliser l\'application avec l\'accord d\'un parent ou d\'un responsable légal.\n'
                  '• Fournir des informations exactes lors de la création du compte.\n'
                  '• Ne pas utiliser l\'application à des fins illégales.\n\n'
                  'Chaque utilisateur est responsable de l\'utilisation de son compte.',
            ),
            _buildSection(
              theme,
              title: '4. Utilisation de l\'application',
              content:
                  'L\'utilisateur s\'engage à utiliser l\'application de manière respectueuse et conforme aux lois.\n\n'
                  'Il est interdit de :\n'
                  '• Harceler, menacer ou intimider d\'autres utilisateurs.\n'
                  '• Publier de fausses informations.\n'
                  '• Utiliser l\'application pour des activités illégales.\n'
                  '• Perturber le fonctionnement du service.\n\n'
                  'DuelFinder se réserve le droit de suspendre ou supprimer un compte en cas de violation des règles.',
            ),
            _buildSection(
              theme,
              title: '5. Organisation des rencontres',
              content:
                  'DuelFinder permet aux utilisateurs d\'organiser des rencontres pour jouer dans la vie réelle.\n\n'
                  'Les rencontres organisées via l\'application se déroulent sous la responsabilité exclusive des utilisateurs.\n\n'
                  'DuelFinder ne peut être tenu responsable :\n'
                  '• Du comportement des utilisateurs.\n'
                  '• De l\'annulation d\'une partie.\n'
                  '• De tout incident survenant lors d\'une rencontre.\n\n'
                  'Les utilisateurs doivent faire preuve de prudence lors de rencontres avec d\'autres joueurs.',
            ),
            _buildSection(
              theme,
              title: '6. Contenu publié par les utilisateurs',
              content:
                  'Les utilisateurs sont responsables du contenu qu\'ils publient sur l\'application, notamment :\n'
                  '• Leur pseudonyme.\n'
                  '• Leur photo de profil.\n'
                  '• Les parties créées.\n\n'
                  'DuelFinder peut supprimer tout contenu jugé inapproprié.',
            ),
            _buildSection(
              theme,
              title: '7. Suspension ou suppression de compte',
              content:
                  'DuelFinder peut suspendre ou supprimer un compte en cas de :\n'
                  '• Violation des présentes conditions.\n'
                  '• Comportement nuisible à la communauté.\n'
                  '• Utilisation abusive de l\'application.\n\n'
                  'L\'utilisateur peut supprimer son compte à tout moment dans les paramètres de l\'application.',
            ),
            _buildSection(
              theme,
              title: '8. Modification du service',
              content:
                  'DuelFinder peut modifier, améliorer ou mettre à jour l\'application à tout moment.\n\n'
                  'Les fonctionnalités peuvent évoluer au fil des versions.',
            ),
            _buildSection(
              theme,
              title: '9. Limitation de responsabilité',
              content:
                  'DuelFinder fournit un service de mise en relation entre joueurs.\n\n'
                  'Dans la mesure permise par la loi, DuelFinder ne pourra être tenu responsable des dommages résultant :\n'
                  '• De l\'utilisation de l\'application.\n'
                  '• Des interactions entre utilisateurs.\n'
                  '• Des rencontres organisées via la plateforme.',
            ),
            _buildSection(
              theme,
              title: '10. Contact',
              content: 'Pour toute question concernant ces conditions : contact@duelfinder.com',
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
