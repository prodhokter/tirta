import 'package:tirta/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUsecase {
  final AuthRepository _repository;

  ResetPasswordUsecase({required AuthRepository repository})
      : _repository = repository;

  Future<void> call({required String email}) async {
    return await _repository.resetPassword(email: email);
  }
}
