import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/features/auth/providers/auth_notifier.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isUpdatingLocation = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                theme, colorScheme, Icons.person_outline, 'Compte'),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.edit_outlined,
              title: 'Modifier le pseudo',
              onTap: () => _showEditPseudoDialog(context, ref),
            ),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.photo_camera_outlined,
              title: 'Changer la photo de profil',
              onTap: () => _showChangePhotoDialog(context),
            ),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.description_outlined,
              title: 'Modifier la bio',
              onTap: () => _showEditBioDialog(context, ref),
            ),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.lock_outline,
              title: 'Changer le mot de passe',
              onTap: () => _showChangePasswordDialog(context),
            ),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.logout,
              title: 'Déconnexion',
              titleColor: colorScheme.error,
              onTap: () => _showLogoutDialog(context, ref),
            ),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.delete_outline,
              title: 'Supprimer le compte',
              titleColor: colorScheme.error,
              onTap: () => _showDeleteAccountDialog(context, ref),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader(theme, colorScheme,
                Icons.notifications_outlined, 'Notifications'),
            _buildSwitchTile(
              context,
              theme,
              colorScheme,
              icon: Icons.notifications_active_outlined,
              title: 'Activer les notifications',
              value: notificationsEnabled,
              onChanged: (value) {
                ref.read(notificationsEnabledProvider.notifier).state = value;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value
                        ? 'Notifications activées'
                        : 'Notifications désactivées'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSectionHeader(
                theme, colorScheme, Icons.location_on_outlined, 'Localisation'),
            _buildLocationSwitch(context, theme, colorScheme, ref),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.refresh,
              title: 'Mettre à jour ma position',
              trailing: _isUpdatingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
              onTap:
                  _isUpdatingLocation ? null : () => _updateLocation(context),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader(theme, colorScheme, Icons.language, 'Langue'),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.translate,
              title: 'Français',
              trailing: Icon(
                Icons.check,
                color: colorScheme.primary,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Autres langues disponibles en V1.5'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSectionHeader(
                theme, colorScheme, Icons.description_outlined, 'Légal'),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.article_outlined,
              title: "Conditions d'utilisation",
              onTap: () => {
                // _launchUrl('https://duelfinder.com/cgu')
              },
            ),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.privacy_tip_outlined,
              title: 'Politique de confidentialité',
              onTap: () => {
                // _launchUrl('https://duelfinder.com/privacy')
              },
            ),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.info_outline,
              title: 'Mentions légales',
              onTap: () => {
                // _launchUrl('https://duelfinder.com/legal')
              },
            ),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.info_outline,
              title: 'Version',
              trailing: Text(
                'v1.0.0',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              onTap: null,
            ),
            const SizedBox(height: 16),
            _buildSectionHeader(
                theme, colorScheme, Icons.support_agent, 'Support'),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.help_outline,
              title: 'Contacter le support',
              onTap: () => {
                // _launchUrl('mailto:contact@duelfinder.com')
              },
            ),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.email_outlined,
              title: 'contact@duelfinder.com',
              onTap: () => {
                // _launchUrl('mailto:contact@duelfinder.com')
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _updateLocation(BuildContext context) async {
    setState(() => _isUpdatingLocation = true);

    try {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentPosition();

      if (mounted) {
        if (position != null) {
          ref.invalidate(currentPositionProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Position mise à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Impossible de récupérer la position'),
              action: SnackBarAction(
                label: 'Paramètres',
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la mise à jour de la position'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingLocation = false);
      }
    }
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: titleColor ?? colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: titleColor,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                )
              : null),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),
      value: value,
      onChanged: onChanged,
      activeColor: colorScheme.primary,
    );
  }

  Widget _buildLocationSwitch(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    WidgetRef ref,
  ) {
    final locationEnabled = ref.watch(locationEnabledProvider);

    return _buildSwitchTile(
      context,
      theme,
      colorScheme,
      icon: Icons.my_location_outlined,
      title: 'Autoriser la géolocalisation',
      value: locationEnabled,
      onChanged: (value) async {
        if (value) {
          final hasPermission =
              await ref.read(locationServiceProvider).checkPermission();

          if (!hasPermission) {
            // Demander la permission
            final permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied ||
                permission == LocationPermission.deniedForever) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Veuillez autoriser la localisation dans les paramètres'),
                    action: SnackBarAction(
                      label: 'Ouvrir',
                      onPressed: () => Geolocator.openAppSettings(),
                    ),
                  ),
                );
              }
              return; // Ne pas activer si permission refusée
            }
          }

          ref.read(locationEnabledProvider.notifier).state = true;
          ref.invalidate(currentPositionProvider);
          ref.invalidate(gamesNotifierProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Géolocalisation activée'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        } else {
          ref.read(locationEnabledProvider.notifier).state = false;
          ref.invalidate(currentPositionProvider);
          ref.invalidate(gamesNotifierProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Géolocalisation désactivée'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        }
      },
    );
  }

  // Future<void> _launchUrl(String url) async {
  //   final uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   }
  // }

  void _showEditPseudoDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(authNotifierProvider).user?.username ?? '',
    );
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le pseudo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nouveau pseudo',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter la mise à jour du pseudo via API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pseudo mis à jour')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showEditBioDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(authNotifierProvider).user?.bio ?? '',
    );
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la bio'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Votre bio',
            hintText: 'Décrivez-vous en quelques mots...',
          ),
          maxLines: 3,
          maxLength: 100,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter la mise à jour de la bio via API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bio mise à jour')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showChangePhotoDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                // TODO: Implémenter la sélection depuis la galerie
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Sélection galerie - À implémenter')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Prendre une photo'),
              onTap: () {
                // TODO: Implémenter la prise de photo
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Caméra - À implémenter')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel_outlined, color: colorScheme.error),
              title:
                  Text('Annuler', style: TextStyle(color: colorScheme.error)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe actuel',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter le changement de mot de passe via API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mot de passe modifié')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            child: const Text('Changer'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
            },
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implémenter la suppression du compte via API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compte supprimé')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
