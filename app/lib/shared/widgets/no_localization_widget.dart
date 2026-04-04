import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoLocalizationWidget extends StatelessWidget {
  const NoLocalizationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              "Localisation indisponible",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.arrow_circle_right_outlined),
              label: const Text('Paramètres'),
            ),
          ],
        ),
      ),
    );
  }
}
