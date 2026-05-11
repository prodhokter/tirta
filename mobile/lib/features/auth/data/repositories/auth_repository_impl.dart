import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tirta/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:tirta/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl({required AuthRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _remoteDatasource.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    return await _remoteDatasource.signIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<User> signInWithGoogle() async {
    return await _remoteDatasource.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    return await _remoteDatasource.signOut();
  }

  @override
  Future<void> resetPassword({required String email}) async {
    return await _remoteDatasource.resetPassword(email: email);
  }
}
