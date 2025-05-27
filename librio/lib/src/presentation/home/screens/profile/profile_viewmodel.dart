import 'package:flutter/material.dart';
import 'package:librio/src/domain/usecases/get_user_books_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/entities/book.dart';

mixin ProfileViewModel on ChangeNotifier {
  List<Book> books = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchUserBooks();
}

class ProfileViewModelImpl extends ChangeNotifier with ProfileViewModel {
  final GetUserBooksUseCase _getUserBooksUseCase;

  ProfileViewModelImpl(this._getUserBooksUseCase);

  @override
  Future<void> fetchUserBooks() async {
    final fb.User? user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      error = 'Usuário não autenticado';
      notifyListeners();
      return;
    }
    isLoading = true;
    notifyListeners();
    try {
      books = await _getUserBooksUseCase.execute(user.uid);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
