import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:go_router/go_router.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/routes/routes.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase _useCase;
  bool isLoading = false;
  User? user;
  String? error;

  LoginViewModel(this._useCase);

  Future<void> login(
      String email, String password, BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      user = await _useCase.execute(email, password);
      error = null;

      // Navegar para home se login bem-sucedido
      if (user != null) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      // Tratamento específico para erros do Firebase Auth
      if (e is firebase_auth.FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            error = 'Usuário não encontrado. Verifique o email.';
            break;
          case 'wrong-password':
            error = 'Senha incorreta. Tente novamente.';
            break;
          case 'invalid-email':
            error = 'Email inválido. Verifique o formato.';
            break;
          case 'user-disabled':
            error = 'Esta conta foi desabilitada.';
            break;
          case 'too-many-requests':
            error = 'Muitas tentativas. Tente novamente mais tarde.';
            break;
          case 'network-request-failed':
            error = 'Erro de conexão. Verifique sua internet.';
            break;
          default:
            error = 'Erro no login: ${e.message}';
        }
      } else {
        error = 'Erro inesperado: ${e.toString()}';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void navigateToSignup(BuildContext context) {
    context.push(AppRoutes.signup);
  }
}
