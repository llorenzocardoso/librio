import 'package:flutter/material.dart';
import 'package:librio/src/domain/usecases/sign_up_usecase.dart';
import 'package:librio/src/domain/entities/user.dart';

class SignUpViewModel extends ChangeNotifier {
  final SignUpUseCase _useCase;
  bool isLoading = false;
  User? user;
  String? error;

  SignUpViewModel(this._useCase);

  Future<void> signUp(String name, String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      user = await _useCase.execute(name, email, password);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
