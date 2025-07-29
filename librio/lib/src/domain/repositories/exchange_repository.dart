import 'package:librio/src/domain/domain.dart';

abstract class ExchangeRepository {
  Future<void> createExchange({
    required String proposerBookId,
    required String receiverBookId,
    required String receiverId,
    String? message,
  });

  Future<List<Exchange>> getUserExchanges(String userId);

  Future<void> updateExchangeStatus(String exchangeId, ExchangeStatus status);

  Future<Exchange?> getExchangeById(String exchangeId);

  Future<void> confirmExchangeCompletion(String exchangeId, String userId);
}
