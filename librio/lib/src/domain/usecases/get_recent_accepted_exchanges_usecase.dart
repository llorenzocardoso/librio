import 'package:librio/src/domain/repositories/exchange_repository.dart';
import 'package:librio/src/domain/entities/exchange.dart';

class GetRecentAcceptedExchangesUseCase {
  final ExchangeRepository exchangeRepository;

  GetRecentAcceptedExchangesUseCase(this.exchangeRepository);

  Future<List<Exchange>> execute(String userId) async {
    // Buscar todas as trocas do usuário
    final exchanges = await exchangeRepository.getUserExchanges(userId);

    // Filtrar trocas aceitas nas últimas 24 horas onde o usuário é o proposer
    final now = DateTime.now();
    final oneDayAgo = now.subtract(const Duration(hours: 24));

    final recentAcceptedExchanges = exchanges
        .where((exchange) =>
            exchange.status == ExchangeStatus.accepted &&
            exchange.proposerId == userId && // Usuário que propôs a troca
            exchange.updatedAt != null &&
            exchange.updatedAt!.isAfter(oneDayAgo)) // Aceita nas últimas 24h
        .toList();

    // Ordenar por data de atualização (mais recente primeiro)
    recentAcceptedExchanges.sort((a, b) =>
        (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt));

    return recentAcceptedExchanges;
  }
}
