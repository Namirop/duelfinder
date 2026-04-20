import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tcg_matchmaker/core/router/app_router.dart';
import 'package:tcg_matchmaker/features/messages/providers/messages_provider.dart';
import 'package:tcg_matchmaker/features/games/providers/games_provider.dart';

class BottomNavBar extends ConsumerWidget {
  final int currentScreen;
  final Function(int) onTap;
  const BottomNavBar({
    super.key,
    required this.currentScreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final unreadMessages =
        ref.watch(messagesNotifierProvider.select((s) => s.totalUnread));
    final canCreateGame =
        !ref.watch(gamesNotifierProvider.select((s) => s.hasOpenGame));

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 30),
      child: SizedBox(
        height: 70,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 75,
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIcon(Icons.home_rounded, 0, colorScheme, ref),
                      _buildIcon(
                          Icons.calendar_month_outlined, 1, colorScheme, ref),
                      const SizedBox(width: 80),
                      _buildIconWithBadge(
                        Icons.chat_bubble_rounded,
                        3,
                        colorScheme,
                        ref,
                        badgeCount: unreadMessages,
                      ),
                      _buildIcon(Icons.person_rounded, 4, colorScheme, ref),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -8,
              child: _buildCenterButton(
                  colorScheme, 2, context, canCreateGame),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(
      IconData icon, int index, ColorScheme colorScheme, WidgetRef ref) {
    final isSelected = currentScreen == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Icon(
            icon,
            size: isSelected ? 26 : 22,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithBadge(
    IconData icon,
    int index,
    ColorScheme colorScheme,
    WidgetRef ref, {
    int badgeCount = 0,
    bool hasDot = false,
  }) {
    final isSelected = currentScreen == index;
    final showBadge = badgeCount > 0 || hasDot;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(
                icon,
                size: isSelected ? 26 : 22,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (showBadge)
              Positioned(
                top: 8,
                right: 8,
                child: hasDot
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 1.5,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(
      ColorScheme colorScheme, int index, BuildContext context, bool enabled) {
    final isSelected = currentScreen == index;
    final disabledColor = Colors.grey.shade700;

    final baseColor = enabled
        ? (isSelected
            ? colorScheme.primary
            : Color.lerp(colorScheme.primary, Colors.black, 0.5)!)
        : disabledColor;

    return GestureDetector(
      onTap: () {
        if (enabled) {
          context.push(AppRoutes.createGame);
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                    'Vous avez déjà une partie ouverte. Complétez-la ou annulez-la pour en créer une autre.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              baseColor,
              Color.lerp(baseColor, Colors.black, 0.15)!,
            ],
          ),
          border: Border.all(
            color: Colors.white
                .withValues(alpha: enabled && isSelected ? 0.3 : 0.15),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
            if (isSelected && enabled)
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.add_rounded,
            size: 45,
            color:
                Colors.white.withValues(alpha: enabled && isSelected ? 1 : 0.4),
          ),
        ),
      ),
    );
  }
}
