import 'package:librio/src/domain/repositories/rating_repository.dart';

class CreateRatingUseCase {
  final RatingRepository repository;

  CreateRatingUseCase(this.repository);

  Future<void> execute({
    required String exchangeId,
    required String evaluatorId,
    required String evaluatedId,
    required int stars,
    required String message,
  }) {
    return repository.createRating(
      exchangeId: exchangeId,
      evaluatorId: evaluatorId,
      evaluatedId: evaluatedId,
      stars: stars,
      message: message,
    );
  }
}
