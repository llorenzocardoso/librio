import 'package:librio/src/domain/entities/book.dart';
import 'package:librio/src/domain/repositories/book_repository.dart';

class GetUserBooksUseCase {
  final BookRepository repository;

  GetUserBooksUseCase(this.repository);

  Future<List<Book>> execute(String ownerId) {
    return repository.getUserBooks(ownerId);
  }
}
