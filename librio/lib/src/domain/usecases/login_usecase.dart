import 'package:librio/src/domain/entities/user.dart';
import 'package:librio/src/domain/repositories/user_repository.dart';

class LoginUseCase {
  final UserRepository repository;

  LoginUseCase(this.repository);

  Future<User> execute(String email, String password) {
    return repository.login(email, password);
  }
}
