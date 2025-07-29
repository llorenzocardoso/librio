import 'package:flutter/foundation.dart';
import '../domain/domain.dart';
import '../data/data.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class BookDataManager extends ChangeNotifier {
  static final BookDataManager _instance = BookDataManager._internal();
  factory BookDataManager() => _instance;
  BookDataManager._internal();

  final GetAllBooksUseCase _getAllBooksUseCase =
      GetAllBooksUseCase(BookRepositoryImpl());
  final GetUserBooksUseCase _getUserBooksUseCase =
      GetUserBooksUseCase(BookRepositoryImpl());

  List<Book> _allBooks = [];
  List<Book> _userBooks = [];
  bool _isLoading = false;
  String? _error;

  List<Book> get allBooks => _allBooks;
  List<Book> get userBooks => _userBooks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _waitForAuthentication() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) return;

    await firebase_auth.FirebaseAuth.instance
        .authStateChanges()
        .where((user) => user != null)
        .first
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Timeout aguardando autenticação'),
        );
  }

  Future<void> loadAllBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _waitForAuthentication();

      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado após aguardar');
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final excludeUserId = currentUser.uid;
      _allBooks =
          await _getAllBooksUseCase.execute(excludeUserId: excludeUserId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _allBooks = [];

      if (e.toString().contains('permission') ||
          e.toString().contains('PERMISSION_DENIED')) {
        _error = 'Erro de permissão: Faça logout e login novamente';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserBooks() async {
    try {
      await _waitForAuthentication();

      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado após aguardar');
      }

      _userBooks = await _getUserBooksUseCase.execute(currentUser.uid);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _userBooks = [];
    }

    notifyListeners();
  }

  Future<void> loadBooksData() async {
    await Future.wait([
      loadAllBooks(),
      loadUserBooks(),
    ]);
  }

  Future<void> notifyBookDataChanged() async {
    await loadBooksData();
  }

  Future<void> notifyUserBooksChanged() async {
    await loadUserBooks();
  }

  Future<void> notifyAllBooksChanged() async {
    await loadAllBooks();
  }

  Future<void> refresh() async {
    await loadBooksData();
  }

  Book? getBookById(String bookId) {
    for (final book in _userBooks) {
      if (book.id == bookId) return book;
    }

    for (final book in _allBooks) {
      if (book.id == bookId) return book;
    }

    return null;
  }

  bool isUserBook(String bookId) {
    return _userBooks.any((book) => book.id == bookId);
  }

  void clear() {
    _allBooks = [];
    _userBooks = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
