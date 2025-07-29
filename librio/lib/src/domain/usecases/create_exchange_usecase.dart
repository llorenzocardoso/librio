import 'package:librio/src/domain/repositories/exchange_repository.dart';

class CreateExchangeUseCase {
  final ExchangeRepository repository;

  CreateExchangeUseCase(this.repository);

  Future<void> execute({
    required String proposerBookId,
    required String receiverBookId,
    required String receiverId,
    String? message,
  }) {
    return repository.createExchange(
      proposerBookId: proposerBookId,
      receiverBookId: receiverBookId,
      receiverId: receiverId,
      message: message,
    );
  }
}
