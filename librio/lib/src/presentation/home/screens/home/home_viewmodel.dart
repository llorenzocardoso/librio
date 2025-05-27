import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:go_router/go_router.dart';
import 'package:librio/src/data/data.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/routes/routes.dart';

class HomeViewModel extends ChangeNotifier {
  final GetAllBooksUseCase _getAllBooksUseCase;
  List<Book> _books = [];
  bool _isLoading = false;
  String? _error;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HomeViewModel()
      : _getAllBooksUseCase = GetAllBooksUseCase(BookRepositoryImpl()) {
    loadBooks();
  }

  Future<void> loadBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Obter o ID do usuário atual para excluir seus próprios livros
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      final excludeUserId = currentUser?.uid;

      _books = await _getAllBooksUseCase.execute(excludeUserId: excludeUserId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _books = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadBooks();
  }

  void navigateToAddBook(BuildContext context) {
    context.push(AppRoutes.addBook);
  }

  void navigateToProfile(BuildContext context) {
    context.push(AppRoutes.profile);
  }

  void navigateToBookDetails(BuildContext context, Book book) {
    context.push(AppRoutes.bookDetails, extra: book);
  }
}
