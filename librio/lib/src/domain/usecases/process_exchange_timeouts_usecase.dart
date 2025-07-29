import 'package:librio/src/domain/repositories/exchange_repository.dart';
import 'package:librio/src/domain/entities/exchange.dart';

class ProcessExchangeTimeoutsUseCase {
  final ExchangeRepository repository;

  ProcessExchangeTimeoutsUseCase(this.repository);

  Future<List<String>> execute(String userId) async {
    final exchanges = await repository.getUserExchanges(userId);
    final autoConfirmedExchanges = <String>[];

    for (final exchange in exchanges) {
      if (exchange.status == ExchangeStatus.accepted) {
        final now = DateTime.now();
        bool needsUpdate = false;

        if (!exchange.proposerConfirmed &&
            exchange.receiverConfirmedAt != null) {
          final hoursSinceReceiverConfirmed =
              now.difference(exchange.receiverConfirmedAt!).inHours;
          if (hoursSinceReceiverConfirmed >= 48) {
            await repository.confirmExchangeCompletion(
                exchange.id, exchange.proposerId);
            autoConfirmedExchanges.add(exchange.id);
            needsUpdate = true;
          }
        }

        if (!needsUpdate &&
            !exchange.receiverConfirmed &&
            exchange.proposerConfirmedAt != null) {
          final hoursSinceProposerConfirmed =
              now.difference(exchange.proposerConfirmedAt!).inHours;
          if (hoursSinceProposerConfirmed >= 48) {
            await repository.confirmExchangeCompletion(
                exchange.id, exchange.receiverId);
            autoConfirmedExchanges.add(exchange.id);
          }
        }
      }
    }

    return autoConfirmedExchanges;
  }
}
