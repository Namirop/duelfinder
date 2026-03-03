import 'dart:ui';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentScreen;
  final Function(int) onTap;
  const BottomNavBar({
    super.key,
    required this.currentScreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 30),
      child: SizedBox(
        height: 70,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Barre de fond
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
                      _buildIcon(Icons.home_rounded, 0, colorScheme),
                      _buildIcon(Icons.sports_esports_outlined, 1, colorScheme),
                      const SizedBox(width: 80),
                      _buildIcon(Icons.chat_bubble_rounded, 3, colorScheme),
                      _buildIcon(Icons.person_rounded, 4, colorScheme),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -8,
              child: _buildCenterButton(colorScheme, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index, ColorScheme colorScheme) {
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

  Widget _buildCenterButton(ColorScheme colorScheme, int index) {
    final isSelected = currentScreen == index;
    // Couleur foncée opaque pour l'état non sélectionné (violet grisé)
    final unselectedColor = Color.lerp(colorScheme.primary, Colors.black, 0.5)!;

    return GestureDetector(
      onTap: () => onTap(2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isSelected
                ? [
                    colorScheme.primary,
                    Color.lerp(colorScheme.primary, Colors.black, 0.15)!,
                  ]
                : [
                    unselectedColor,
                    Color.lerp(unselectedColor, Colors.black, 0.15)!,
                  ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: isSelected ? 0.3 : 0.15),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
            if (isSelected)
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
            color: Colors.white.withValues(alpha: isSelected ? 1 : 0.6),
          ),
        ),
      ),
    );
  }
}
