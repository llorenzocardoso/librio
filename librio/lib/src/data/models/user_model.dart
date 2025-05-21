import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/entities/user.dart';

class UserModel extends User {
  UserModel({required String id, required String email, required String name})
      : super(id: id, email: email, name: name);

  factory UserModel.fromFirebaseUser(fb.User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
    );
  }
}
