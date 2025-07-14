import 'package:librio/src/domain/repositories/exchange_repository.dart';
import 'package:librio/src/domain/entities/exchange.dart';

class GetRecentAcceptedExchangesUseCase {
  final ExchangeRepository exchangeRepository;

  GetRecentAcceptedExchangesUseCase(this.exchangeRepository);

  Future<List<Exchange>> execute(String userId) async {
    final exchanges = await exchangeRepository.getUserExchanges(userId);

    final now = DateTime.now();
    final oneDayAgo = now.subtract(const Duration(hours: 24));

    final recentAcceptedExchanges = exchanges
        .where((exchange) =>
            exchange.status == ExchangeStatus.accepted &&
            exchange.proposerId == userId &&
            exchange.updatedAt != null &&
            exchange.updatedAt!.isAfter(oneDayAgo))
        .toList();

    recentAcceptedExchanges.sort((a, b) =>
        (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt));

    return recentAcceptedExchanges;
  }
}
