import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tirta/features/auth/domain/repositories/auth_repository.dart';

class SignInUsecase {
  final AuthRepository _repository;

  SignInUsecase({required AuthRepository repository})
      : _repository = repository;

  Future<User> call({
    required String email,
    required String password,
  }) async {
    return await _repository.signIn(
      email: email,
      password: password,
    );
  }
}
