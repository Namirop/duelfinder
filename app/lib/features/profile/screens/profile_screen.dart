import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tcg_matchmaker/features/auth/providers/auth_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(theme, colorScheme),
            const SizedBox(height: 32),
            _buildAvatar(colorScheme, user!.avatar),
            const SizedBox(height: 16),
            Text(
              user.username,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (user.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Membre depuis ${DateFormat('MMMM yyyy', 'fr_FR').format(user.createdAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
            const SizedBox(height: 32),
            _buildStatsSection(theme, colorScheme),
            const SizedBox(height: 32),
            _buildMenuSection(context, ref, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Mon profil",
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 23)),
      ],
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme, String avatar) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.primary,
          width: 3,
        ),
      ),
      child: CircleAvatar(
        radius: 60,
        backgroundColor: colorScheme.primaryContainer,
        backgroundImage: NetworkImage(
          avatar,
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(theme, colorScheme, '0', 'Parties\njouées'),
          _buildStatDivider(colorScheme),
          _buildStatItem(theme, colorScheme, '0', 'Parties\ncréées'),
          _buildStatDivider(colorScheme),
          _buildStatItem(theme, colorScheme, '0', 'Avis\nreçus'),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    ColorScheme colorScheme,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(ColorScheme colorScheme) {
    return Container(
      height: 40,
      width: 1,
      color: colorScheme.onSurface.withValues(alpha: 0.2),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          theme,
          colorScheme,
          icon: Icons.edit_outlined,
          label: 'Modifier le profil',
          onTap: () => context.push('/profile/edit'),
        ),
        _buildMenuItem(
          context,
          theme,
          colorScheme,
          icon: Icons.settings_outlined,
          label: 'Paramètres',
          onTap: () {
            // TODO: Navigation vers paramètres
          },
        ),
        _buildMenuItem(
          context,
          theme,
          colorScheme,
          icon: Icons.help_outline,
          label: 'Aide & Support',
          onTap: () {
            // TODO: Navigation vers aide
          },
        ),
        const SizedBox(height: 16),
        _buildLogoutButton(context, ref, theme, colorScheme),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorScheme.primary),
      ),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context, ref),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.error,
          side: BorderSide(color: colorScheme.error),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout),
        label: const Text('Se déconnecter'),
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
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}
