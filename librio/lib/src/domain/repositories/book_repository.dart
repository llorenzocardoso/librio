import 'package:librio/src/domain/domain.dart';

abstract class BookRepository {
  Future<void> addBook({
    required String title,
    required String author,
    required String genre,
    required String description,
    required String condition,
    required String? imageUrl,
    double? latitude,
    double? longitude,
    String? city,
    String? state,
  });

  Future<List<Book>> getUserBooks(String ownerId);

  Future<List<Book>> getAllBooks({String? excludeUserId});

  Future<List<Book>> getBooksByDistance({
    required double userLatitude,
    required double userLongitude,
    required double maxDistanceKm,
    String? genre,
  });

  Future<void> updateBookAvailability(String bookId, bool available);

  Future<void> updateBook({
    required String bookId,
    required String title,
    required String author,
    required String genre,
    required String description,
    required String condition,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? city,
    String? state,
  });

  Future<void> deleteBook(String bookId);
}
