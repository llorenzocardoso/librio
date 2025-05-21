import 'package:librio/src/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> signUp(String name, String email, String password);
  Future<User> login(String email, String password);

  Future<void> logout();
  Stream<User?> get authState;
}
