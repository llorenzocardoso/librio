import 'package:librio/src/domain/repositories/book_repository.dart';

class DeleteBookUseCase {
  final BookRepository repository;

  DeleteBookUseCase(this.repository);

  Future<void> execute(String bookId) {
    return repository.deleteBook(bookId);
  }
}
