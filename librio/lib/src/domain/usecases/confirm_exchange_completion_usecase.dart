import 'package:librio/src/domain/repositories/exchange_repository.dart';

class ConfirmExchangeCompletionUseCase {
  final ExchangeRepository repository;

  ConfirmExchangeCompletionUseCase(this.repository);

  Future<void> execute(String exchangeId, String userId) {
    return repository.confirmExchangeCompletion(exchangeId, userId);
  }
}
