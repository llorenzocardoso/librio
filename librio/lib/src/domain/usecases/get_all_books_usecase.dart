import 'package:librio/src/domain/entities/book.dart';
import 'package:librio/src/domain/repositories/book_repository.dart';

class GetAllBooksUseCase {
  final BookRepository repository;

  GetAllBooksUseCase(this.repository);

  Future<List<Book>> execute({String? excludeUserId}) {
    return repository.getAllBooks(excludeUserId: excludeUserId);
  }
}
