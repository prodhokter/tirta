import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tirta/features/auth/domain/repositories/auth_repository.dart';

class SignUpUsecase {
  final AuthRepository _repository;

  SignUpUsecase({required AuthRepository repository})
      : _repository = repository;

  Future<User> call({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}
