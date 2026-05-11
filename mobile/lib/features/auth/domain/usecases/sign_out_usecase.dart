import 'package:tirta/features/auth/domain/repositories/auth_repository.dart';

class SignOutUsecase {
  final AuthRepository _repository;

  SignOutUsecase({required AuthRepository repository})
      : _repository = repository;

  Future<void> call() async {
    return await _repository.signOut();
  }
}
