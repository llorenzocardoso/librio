import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:go_router/go_router.dart';
import 'package:librio/src/data/data.dart';
import 'package:librio/src/routes/routes.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  fb.User? get currentUser => fb.FirebaseAuth.instance.currentUser;

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail() async {
    final user = currentUser;
    if (user?.email == null) {
      _error = 'Usuário não encontrado ou email não disponível';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await fb.FirebaseAuth.instance.sendPasswordResetEmail(
        email: user!.email!,
      );
      _successMessage = 'Email enviado! Verifique sua caixa de entrada.';
    } on fb.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _error = 'Usuário não encontrado';
          break;
        case 'invalid-email':
          _error = 'Email inválido';
          break;
        case 'too-many-requests':
          _error = 'Muitas tentativas. Tente novamente mais tarde.';
          break;
        default:
          _error = 'Erro ao enviar email: ${e.message}';
      }
    } catch (e) {
      _error = 'Erro inesperado: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _successMessage = 'Logout realizado com sucesso';
    } catch (e) {
      _error = 'Erro ao fazer logout: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void navigateToEditProfile(BuildContext context) {
    context.push(AppRoutes.editProfile);
  }

  void navigateToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }
}
