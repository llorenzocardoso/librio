import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:go_router/go_router.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/routes/routes.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final ResetPasswordUseCase _useCase;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  ResetPasswordViewModel(this._useCase);

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  Future<void> resetPassword(String email, BuildContext context) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _useCase.execute(email);
      _successMessage =
          'Email de redefinição enviado com sucesso!\n\nVerifique sua caixa de entrada e pasta de spam.\n\nO email pode levar alguns minutos para chegar.';
    } catch (e) {
      // Tratamento específico para erros do Firebase Auth
      if (e is firebase_auth.FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            _error =
                '❌ Email não cadastrado no sistema.\n\nVerifique se o email está correto ou cadastre-se primeiro.';
            break;
          case 'invalid-email':
            _error = '❌ Email inválido.\n\nVerifique o formato do email.';
            break;
          case 'too-many-requests':
            _error =
                '⏰ Muitas tentativas.\n\nTente novamente em alguns minutos.';
            break;
          case 'network-request-failed':
            _error =
                '🌐 Erro de conexão.\n\nVerifique sua internet e tente novamente.';
            break;
          default:
            _error = '❌ Erro inesperado: ${e.message}\n\nCódigo: ${e.code}';
        }
      } else {
        _error = '❌ Erro inesperado: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  void navigateToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }

  void navigateToSignUp(BuildContext context) {
    context.go(AppRoutes.signup);
  }
}
