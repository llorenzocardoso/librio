import 'package:librio/src/domain/repositories/exchange_repository.dart';
import 'package:librio/src/domain/entities/exchange.dart';

class GetPendingExchangesUseCase {
  final ExchangeRepository exchangeRepository;

  GetPendingExchangesUseCase(this.exchangeRepository);

  Future<List<Exchange>> execute(String userId) async {
    final exchanges = await exchangeRepository.getUserExchanges(userId);

    final pendingReceivedExchanges = exchanges
        .where((exchange) =>
            exchange.status == ExchangeStatus.pending &&
            exchange.receiverId == userId)
        .toList();

    pendingReceivedExchanges.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return pendingReceivedExchanges;
  }
}
