import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tcg_matchmaker/core/di/providers.dart';
import 'package:tcg_matchmaker/core/errors/exceptions.dart';
import 'package:tcg_matchmaker/core/services/app_logger.dart';

import '../entities/auth_state.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    checkAuthStatus();
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
}
