import 'package:librio/src/domain/repositories/rating_repository.dart';

class CheckRatingExistsUseCase {
  final RatingRepository repository;

  CheckRatingExistsUseCase(this.repository);

  Future<bool> execute(String exchangeId, String evaluatorId) {
    return repository.hasUserRatedExchange(exchangeId, evaluatorId);
  }
}
