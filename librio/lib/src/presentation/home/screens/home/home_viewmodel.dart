import 'package:flutter/material.dart';
import 'package:librio/src/domain/entities/book.dart';
import 'package:librio/src/data/datasources/mock_data.dart';
import 'package:go_router/go_router.dart';

class HomeViewModel extends ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  HomeViewModel() {
    loadBooks();
  }

  Future<void> loadBooks() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _books = MockData.getMockBooks();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadBooks();
  }

  void navigateToAddBook(BuildContext context) {
    context.push('/add_book');
  }

  void navigateToProfile(BuildContext context) {
    context.push('/profile');
  }
}
