import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/data/data.dart';
import 'package:librio/src/domain/domain.dart';


class ProposeExchangeViewModel extends ChangeNotifier {
  late CreateExchangeUseCase _createExchangeUseCase;
  late GetUserBooksUseCase _getUserBooksUseCase;

  List<Book> userBooks = [];
  Book? selectedBook;
  bool isLoading = false;
  bool isLoadingBooks = true;
  String? error;

  ProposeExchangeViewModel() {
    _createExchangeUseCase = CreateExchangeUseCase(ExchangeRepositoryImpl());
    _getUserBooksUseCase = GetUserBooksUseCase(BookRepositoryImpl());
  }

  Future<void> loadUserBooks() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final books = await _getUserBooksUseCase.execute(user.uid);
      userBooks = books;
      isLoadingBooks = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoadingBooks = false;
      notifyListeners();
    }
  }

  void selectBook(Book book) {
    selectedBook = book;
    notifyListeners();
  }

  Future<void> proposeExchange({
    required String receiverBookId,
    required String receiverId,
    String? message,
    required BuildContext context,
  }) async {
    if (selectedBook == null) {
      _showSnackBar(context, 'Selecione um livro para trocar');
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _createExchangeUseCase.execute(
        proposerBookId: selectedBook!.id,
        receiverBookId: receiverBookId,
        receiverId: receiverId,
        message: message,
      );

      _showSnackBar(context, 'Proposta enviada com sucesso!');
      navigateBack(context);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void navigateBack(BuildContext context) {
    context.pop();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
