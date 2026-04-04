import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/features/profile/providers/settings_provider.dart';
import 'package:tcg_matchmaker/core/router/app_router.dart';
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
    final notificationsEnabled =
        ref.watch(settingsNotifierProvider).notificationsEnabled;

    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres',
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 23)),
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
              onTap: () => _showChangePasswordDialog(context, ref),
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
                ref
                    .read(settingsNotifierProvider.notifier)
                    .toggleNotifications(value);
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
              onTap: () => context.push(AppRoutes.terms),
            ),
            _buildSettingsTile(
              context,
              theme,
              colorScheme,
              icon: Icons.privacy_tip_outlined,
              title: 'Politique de confidentialité',
              onTap: () => context.push(AppRoutes.privacy),
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
              icon: Icons.email_outlined,
              title: 'contact@duelfinder.com',
              onTap: () {},
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
          Icon(icon, size: 20, color: colorScheme.primary),
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
        style: theme.textTheme.bodyLarge?.copyWith(color: titleColor),
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
      title: Text(title, style: theme.textTheme.bodyLarge),
      value: value,
      onChanged: onChanged,
      activeThumbColor: colorScheme.primary,
    );
  }

  Widget _buildLocationSwitch(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    WidgetRef ref,
  ) {
    final locationEnabled = ref.watch(settingsNotifierProvider).locationEnabled;

    return _buildSwitchTile(
      context,
      theme,
      colorScheme,
      icon: Icons.my_location_outlined,
      title: 'Autoriser la géolocalisation',
      value: locationEnabled,
      onChanged: (value) async {
        final result = await ref
            .read(settingsNotifierProvider.notifier)
            .toggleLocation(value);

        if (result == LocationPermissionResult.deniedForever) {
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
          return;
        }
        if (result == LocationPermissionResult.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Autorisation de localisation refusée'),
              ),
            );
          }
          return;
        }

        ref.read(gamesNotifierProvider.notifier).fetchExistingGames();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(value
                  ? 'Géolocalisation activée'
                  : 'Géolocalisation désactivée'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }

  void _showEditPseudoDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(authNotifierProvider).user?.username ?? '',
    );
    final colorScheme = Theme.of(context).colorScheme;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Modifier le pseudo'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Nouveau pseudo'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final value = controller.text.trim();
                      if (value.isEmpty) return;

                      setDialogState(() => isLoading = true);
                      final error = await ref
                          .read(authNotifierProvider.notifier)
                          .updateProfile(username: value);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error ?? 'Pseudo mis à jour'),
                            backgroundColor:
                                error != null ? colorScheme.error : null,
                          ),
                        );
                      }
                    },
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBioDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(authNotifierProvider).user?.bio ?? '',
    );
    final colorScheme = Theme.of(context).colorScheme;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setDialogState(() => isLoading = true);
                      final error = await ref
                          .read(authNotifierProvider.notifier)
                          .updateProfile(bio: controller.text.trim());

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error ?? 'Bio mise à jour'),
                            backgroundColor:
                                error != null ? colorScheme.error : null,
                          ),
                        );
                      }
                    },
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Changer le mot de passe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Mot de passe actuel'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Nouveau mot de passe'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Confirmer le mot de passe'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (newController.text != confirmController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Les mots de passe ne correspondent pas'),
                            backgroundColor: colorScheme.error,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);
                      final error = await ref
                          .read(authNotifierProvider.notifier)
                          .changePassword(
                            currentPassword: currentController.text,
                            newPassword: newController.text,
                          );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error ?? 'Mot de passe modifié'),
                            backgroundColor:
                                error != null ? colorScheme.error : null,
                          ),
                        );
                      }
                    },
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Changer'),
            ),
          ],
        ),
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
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Supprimer le compte'),
          content: const Text(
            'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setDialogState(() => isLoading = true);
                      final error = await ref
                          .read(authNotifierProvider.notifier)
                          .deleteAccount();

                      if (context.mounted) {
                        Navigator.pop(context);
                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                        // Si succès, l'état auth est reset → GoRouter redirige vers login
                      }
                    },
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Supprimer'),
            ),
          ],
        ),
      ),
    );
  }
}
