import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    // Não encapsular em Exception para preservar FirebaseAuthException
      return await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<fb.UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    // Não encapsular em Exception para preservar FirebaseAuthException
      return await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
  }
}
