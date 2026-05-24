import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import '../models/user_model.dart';

part 'auth_provider.freezed.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.authenticated(UserModel user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.error(String message) = _Error;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState.initial()) {
    _init();
  }

  Future<void> _init() async {
    state = const AuthState.loading();
    
    _authRepository.authStateChanges.listen((authState) async {
      if (authState.session != null) {
        final userModel = await _authRepository.getCurrentUserModel();
        if (userModel != null) {
          state = AuthState.authenticated(userModel);
        } else {
          state = const AuthState.unauthenticated();
        }
      } else {
        state = const AuthState.unauthenticated();
      }
    });
  }

  Future<void> loginWithEmail(String email, String password) async {
    state = const AuthState.loading();
    try {
      await _authRepository.loginWithEmail(email, password);
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String username, String fullName) async {
    state = const AuthState.loading();
    try {
      await _authRepository.signUpWithEmail(email, password, username, fullName);
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AuthState.loading();
    try {
      await _authRepository.loginWithGoogle();
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  Future<void> loginWithApple() async {
    state = const AuthState.loading();
    try {
      await _authRepository.loginWithApple();
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState.unauthenticated();
  }

  Future<void> resetPassword(String email) async {
    await _authRepository.resetPassword(email);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
});
