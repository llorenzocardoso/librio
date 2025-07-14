import 'package:librio/src/domain/repositories/exchange_repository.dart';
import 'package:librio/src/domain/entities/exchange.dart';

class GetPendingExchangesUseCase {
  final ExchangeRepository exchangeRepository;

  GetPendingExchangesUseCase(this.exchangeRepository);

  Future<List<Exchange>> execute(String userId) async {
    // Buscar todas as trocas do usuário
    final exchanges = await exchangeRepository.getUserExchanges(userId);

    // Filtrar apenas trocas pendentes onde o usuário é o receiver (recebeu a proposta)
    final pendingReceivedExchanges = exchanges
        .where((exchange) =>
            exchange.status == ExchangeStatus.pending &&
            exchange.receiverId == userId)
        .toList();

    // Ordenar por data (mais recente primeiro)
    pendingReceivedExchanges.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return pendingReceivedExchanges;
  }
}
