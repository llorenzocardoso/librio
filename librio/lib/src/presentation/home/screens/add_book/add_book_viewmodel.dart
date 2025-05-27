import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/routes/routes.dart';

class AddBookViewModel extends ChangeNotifier {
  final AddBookUseCase _useCase;
  bool isLoading = false;
  String? error;

  AddBookViewModel(this._useCase);

  Future<void> addBook({
    required String title,
    required String author,
    required String genre,
    required String description,
    required String condition,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      await _useCase.execute(
        title: title,
        author: author,
        genre: genre,
        description: description,
        condition: condition,
      );
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void navigateToHome(BuildContext context) {
    context.go(AppRoutes.home);
  }
}
