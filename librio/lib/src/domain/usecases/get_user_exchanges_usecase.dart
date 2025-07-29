import 'package:librio/src/domain/entities/exchange.dart';
import 'package:librio/src/domain/repositories/exchange_repository.dart';

class GetUserExchangesUseCase {
  final ExchangeRepository repository;

  GetUserExchangesUseCase(this.repository);

  Future<List<Exchange>> execute(String userId) {
    return repository.getUserExchanges(userId);
  }
}
