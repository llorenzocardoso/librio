import 'package:librio/src/domain/domain.dart';

abstract class BookRepository {
  Future<void> addBook({
    required String title,
    required String author,
    required String genre,
    required String description,
    required String condition,
  });

  Future<List<Book>> getUserBooks(String ownerId);
}
