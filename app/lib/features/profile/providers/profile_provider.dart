import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

/// Provider pour la gestion du profil
/// TODO: Implémenter la logique de gestion du profil
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  AsyncValue<void> build() {
    // TODO: Charger le profil initial
    return const AsyncValue.data(null);
  }

  // TODO: Implémenter loadProfile()
  // TODO: Implémenter updateProfile()
  // TODO: Implémenter uploadAvatar()
}
