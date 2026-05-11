import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<User> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<User> signIn({
    required String email,
    required String password,
  });

  Future<User> signInWithGoogle();

  Future<void> signOut();

  Future<void> resetPassword({required String email});
}
