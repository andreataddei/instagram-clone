import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> loginWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
    String username,
    String fullName,
  ) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'username': username,
        'full_name': fullName,
      });
    }

    return response;
  }

  Future<AuthResponse> loginWithGoogle() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      options: AuthOptions(
        redirectTo: 'io.github.andreataddei.instagramclone://login-callback',
      ),
    );
  }

  Future<AuthResponse> loginWithApple() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.apple,
      options: AuthOptions(
        redirectTo: 'io.github.andreataddei.instagramclone://login-callback',
      ),
    );
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<UserModel?> getCurrentUserModel() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final profile = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromSupabaseUser(user, profile: profile);
  }
}
