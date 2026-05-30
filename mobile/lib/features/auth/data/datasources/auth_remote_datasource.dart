import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tirta/shared/services/supabase_service.dart';

abstract class AuthRemoteDatasource {
  Future<User> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<User> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> resetPassword({required String email});
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final SupabaseClient _client;

  AuthRemoteDatasourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Gagal membuat akun. Silakan coba lagi.');
      }

      return user;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mendaftar. Coba lagi.');
    }
  }

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Gagal masuk. Silakan coba lagi.');
      }

      return user;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat masuk. Coba lagi.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat keluar. Coba lagi.');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutterquickstart://reset-callback',
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengirim email reset. Coba lagi.');
    }
  }
}
