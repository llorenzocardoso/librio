import 'package:librio/src/domain/entities/user.dart';
import 'package:librio/src/domain/repositories/user_repository.dart';

class SignUpUseCase {
  final UserRepository repository;

  SignUpUseCase(this.repository);

  Future<User> execute(String name, String email, String password) {
    return repository.signUp(name, email, password);
  }
}
