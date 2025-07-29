import 'package:librio/src/domain/repositories/book_repository.dart';

class AddBookUseCase {
  final BookRepository repository;

  AddBookUseCase(this.repository);

  Future<void> execute({
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
  }) {
    return repository.addBook(
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
