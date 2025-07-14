import 'package:flutter/foundation.dart';
import '../domain/domain.dart';
import '../data/data.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Gerenciador global de dados dos livros
/// Responsável por manter o estado atualizado em todas as telas
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

  // Getters
  List<Book> get allBooks => _allBooks;
  List<Book> get userBooks => _userBooks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Aguarda até que o usuário esteja autenticado
  Future<void> _waitForAuthentication() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) return; // Já autenticado

    // Aguarda o stream de autenticação
    await firebase_auth.FirebaseAuth.instance
        .authStateChanges()
        .where((user) => user != null)
        .first
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Timeout aguardando autenticação'),
        );
  }

  /// Carrega todos os livros (exceto os do usuário atual)
  Future<void> loadAllBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Aguarda a autenticação
      await _waitForAuthentication();

      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado após aguardar');
      }

      // Pequeno delay para garantir que a autenticação está completa
      await Future.delayed(const Duration(milliseconds: 500));

      final excludeUserId = currentUser.uid;
      _allBooks =
          await _getAllBooksUseCase.execute(excludeUserId: excludeUserId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _allBooks = [];

      // Se for erro de permissão, dar dica ao usuário
      if (e.toString().contains('permission') ||
          e.toString().contains('PERMISSION_DENIED')) {
        _error = 'Erro de permissão: Faça logout e login novamente';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega os livros do usuário atual
  Future<void> loadUserBooks() async {
    try {
      // Aguarda a autenticação
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

  /// Carrega tanto todos os livros quanto os do usuário
  Future<void> loadBooksData() async {
    await Future.wait([
      loadAllBooks(),
      loadUserBooks(),
    ]);
  }

  /// Atualiza os dados após uma mudança nos livros
  /// Deve ser chamada quando:
  /// - Um livro é adicionado
  /// - Um livro é editado
  /// - Um livro é removido
  /// - A disponibilidade de um livro muda
  Future<void> notifyBookDataChanged() async {
    await loadBooksData();
  }

  /// Atualiza apenas os livros do usuário
  /// Útil quando sabemos que apenas os livros do usuário mudaram
  Future<void> notifyUserBooksChanged() async {
    await loadUserBooks();
  }

  /// Atualiza apenas todos os livros
  /// Útil quando sabemos que apenas a lista geral mudou
  Future<void> notifyAllBooksChanged() async {
    await loadAllBooks();
  }

  /// Força uma atualização completa
  Future<void> refresh() async {
    await loadBooksData();
  }

  /// Obtém um livro específico pelo ID
  Book? getBookById(String bookId) {
    // Procura primeiro nos livros do usuário
    for (final book in _userBooks) {
      if (book.id == bookId) return book;
    }

    // Se não encontrar, procura nos livros gerais
    for (final book in _allBooks) {
      if (book.id == bookId) return book;
    }

    return null;
  }

  /// Verifica se um livro pertence ao usuário atual
  bool isUserBook(String bookId) {
    return _userBooks.any((book) => book.id == bookId);
  }

  /// Limpa todos os dados (útil no logout)
  void clear() {
    _allBooks = [];
    _userBooks = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
