import 'package:librio/src/domain/entities/book.dart';
import 'package:librio/src/domain/repositories/book_repository.dart';

class GetBooksByDistanceUseCase {
  final BookRepository repository;

  GetBooksByDistanceUseCase(this.repository);

  Future<List<Book>> execute({
    required double userLatitude,
    required double userLongitude,
    required double maxDistanceKm,
    String? genre,
  }) {
    return repository.getBooksByDistance(
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      maxDistanceKm: maxDistanceKm,
      genre: genre,
    );
  }
}
