import 'user.dart';

class AuthState {
  final User? user;
  final String? authErrorString;
  final bool isLoading;

  const AuthState({this.user, this.authErrorString, this.isLoading = false});

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    String? authErrorString,
    bool? isLoading,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      authErrorString:
          clearError ? null : (authErrorString ?? this.authErrorString),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
