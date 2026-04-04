import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';

import '../entities/auth_state.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return const AuthState(isLoading: true);
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
      // user == null = pas connecté, Riverpod s'en fout, l'UI check isAuthenticated
    } on AppException catch (e) {
      AppLogger.w('AuthNotifier', 'checkAuthStatus failed: ${e.toString()}');
      state = state.copyWith(authErrorString: e.message, isLoading: false);
    } catch (e, stackTrace) {
      AppLogger.e('AuthNotifier', 'checkAuthStatus failed', e, stackTrace);
      state =
          state.copyWith(authErrorString: 'Erreur inconnue', isLoading: false);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
          );
      state = state.copyWith(user: user, isLoading: false);
    } on AppException catch (e) {
      AppLogger.w('AuthNotifier', 'login failed: ${e.toString()}');
      state = state.copyWith(authErrorString: e.message, isLoading: false);
    } catch (e, stackTrace) {
      AppLogger.e('AuthNotifier', 'login failed', e, stackTrace);
      state =
          state.copyWith(authErrorString: 'Erreur inconnue', isLoading: false);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await ref.read(authRepositoryProvider).register(
            email: email,
            password: password,
            username: username,
          );
      state = state.copyWith(user: user, isLoading: false);
    } on AppException catch (e) {
      AppLogger.w('AuthNotifier', 'register failed: ${e.toString()}');
      state = state.copyWith(authErrorString: e.message, isLoading: false);
    } catch (e, stackTrace) {
      AppLogger.e('AuthNotifier', 'register failed', e, stackTrace);
      state =
          state.copyWith(authErrorString: 'Erreur inconnue', isLoading: false);
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } on AppException catch (e) {
      AppLogger.w('AuthNotifier', 'logout failed: ${e.toString()}');
    } catch (e, stackTrace) {
      AppLogger.e('AuthNotifier', 'logout failed', e, stackTrace);
    } finally {
      state = const AuthState();
    }
  }

  /// Upload un nouvel avatar.
  /// Retourne null si succès, sinon le message d'erreur.
  Future<String?> updateAvatar(File imageFile) async {
    try {
      final updatedUser =
          await ref.read(profileRepositoryProvider).uploadAvatar(imageFile);
      state = state.copyWith(user: updatedUser);
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erreur lors de la mise à jour de la photo';
    }
  }

  /// Met à jour le profil (username et/ou bio).
  /// Retourne null si succès, sinon le message d'erreur.
  Future<String?> updateProfile({String? username, String? bio}) async {
    try {
      final updatedUser = await ref
          .read(profileRepositoryProvider)
          .updateProfile(username: username, bio: bio);
      state = state.copyWith(user: updatedUser);
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erreur inconnue';
    }
  }

  /// Change le mot de passe.
  /// Retourne null si succès, sinon le message d'erreur.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await ref.read(profileRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erreur inconnue';
    }
  }

  /// Supprime le compte.
  /// Retourne null si succès, sinon le message d'erreur.
  Future<String?> deleteAccount() async {
    try {
      await ref.read(profileRepositoryProvider).deleteAccount();
      state = const AuthState();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erreur inconnue';
    }
  }
}
