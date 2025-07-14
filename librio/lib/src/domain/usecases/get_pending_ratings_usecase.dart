import 'package:librio/src/domain/repositories/exchange_repository.dart';
import 'package:librio/src/domain/repositories/rating_repository.dart';
import 'package:librio/src/domain/entities/exchange.dart';

class GetPendingRatingsUseCase {
  final ExchangeRepository exchangeRepository;
  final RatingRepository ratingRepository;

  GetPendingRatingsUseCase(this.exchangeRepository, this.ratingRepository);

  Future<List<Exchange>> execute(String userId) async {
    final exchanges = await exchangeRepository.getUserExchanges(userId);

    final completedExchanges = exchanges
        .where((exchange) => exchange.status == ExchangeStatus.completed)
        .toList();

    final pendingRatings = <Exchange>[];

    for (final exchange in completedExchanges) {
      final hasRated =
          await ratingRepository.hasUserRatedExchange(exchange.id, userId);

      if (!hasRated) {
        pendingRatings.add(exchange);
      }
    }

    return pendingRatings;
  }
}
