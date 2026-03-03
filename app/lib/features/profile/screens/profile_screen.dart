import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      child: Column(
        children: [
          _buildHeader(context, theme, colorScheme),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildAvatar(colorScheme, user!.avatar),
                  const SizedBox(height: 20),
                  Text(
                    user.username,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBio(context, theme, colorScheme, user.bio),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text(
            "Mon profil",
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 23),
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(
              Icons.settings_outlined,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
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
        backgroundImage: NetworkImage(avatar),
      ),
    );
  }

  Widget _buildBio(
      BuildContext context, ThemeData theme, ColorScheme colorScheme, String? bio) {
    final hasBio = bio != null && bio.isNotEmpty;

    return Column(
      children: [
        Text(
          hasBio ? bio : 'Aucune bio pour le moment',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: hasBio ? 0.7 : 0.5),
            fontStyle: hasBio ? FontStyle.normal : FontStyle.italic,
          ),
        ),
        if (!hasBio) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push('/settings'),
            child: Text(
              'Modifier dans les paramètres',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
