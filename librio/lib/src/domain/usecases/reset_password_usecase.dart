import 'package:librio/src/domain/repositories/user_repository.dart';

class ResetPasswordUseCase {
  final UserRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute(String email) {
    return repository.resetPassword(email);
  }
}
