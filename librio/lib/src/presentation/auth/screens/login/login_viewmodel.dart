import 'package:flutter/material.dart';
import 'package:librio/src/domain/usecases/login_usecase.dart';
import 'package:librio/src/domain/entities/user.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase _useCase;
  bool isLoading = false;
  User? user;
  String? error;

  LoginViewModel(this._useCase);

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      user = await _useCase.execute(email, password);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
