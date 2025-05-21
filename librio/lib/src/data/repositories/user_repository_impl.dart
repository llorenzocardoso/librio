import 'package:librio/src/domain/entities/user.dart';
import 'package:librio/src/data/models/user_model.dart';
import 'package:librio/src/domain/repositories/user_repository.dart';
import 'package:librio/src/data/datasources/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepositoryImpl implements UserRepository {
  final AuthService _authService;

  UserRepositoryImpl(this._authService);

  @override
  Stream<User?> get authState =>
      _authService.authStateChanges.map((fb.User? user) =>
          user != null ? UserModel.fromFirebaseUser(user) : null);
  @override
  Future<User> signUp(String name, String email, String password) async {
    final fb.UserCredential creds =
        await _authService.signUpWithEmailAndPassword(email, password);
    final fb.User? user = creds.user;
    if (user == null) throw Exception('User sign up failed');
    await user.updateDisplayName(name);
    await user.reload();
    final fb.User updatedUser = fb.FirebaseAuth.instance.currentUser!;
    final usersRef = FirebaseFirestore.instance.collection('users');
    await usersRef.doc(updatedUser.uid).set({
      'name': name,
      'email': email,
      'description': '',
      'averageRating': 0,
      'ratingCount': 0,
      'photoUrl': updatedUser.photoURL ?? '',
    });
    return UserModel.fromFirebaseUser(updatedUser);
  }

  @override
  Future<User> login(String email, String password) async {
    final fb.UserCredential? creds =
        await _authService.signInWithEmailAndPassword(email, password);
    final fb.User? user = creds?.user;
    if (user == null) throw Exception('User login failed');
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> logout() => _authService.signOut();
}
