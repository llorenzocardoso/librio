import 'package:librio/src/domain/repositories/book_repository.dart';

class UpdateBookUseCase {
  final BookRepository repository;

  UpdateBookUseCase(this.repository);

  Future<void> execute({
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
  }) {
    return repository.updateBook(
      bookId: bookId,
      title: title,
      author: author,
      genre: genre,
      description: description,
      condition: condition,
      imageUrl: imageUrl,
      latitude: latitude,
      longitude: longitude,
      city: city,
      state: state,
    );
  }
}
