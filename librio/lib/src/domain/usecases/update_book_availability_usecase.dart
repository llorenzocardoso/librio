import 'package:librio/src/domain/repositories/book_repository.dart';

class UpdateBookAvailabilityUseCase {
  final BookRepository repository;

  UpdateBookAvailabilityUseCase(this.repository);

  Future<void> execute(String bookId, bool available) {
    return repository.updateBookAvailability(bookId, available);
  }
}
