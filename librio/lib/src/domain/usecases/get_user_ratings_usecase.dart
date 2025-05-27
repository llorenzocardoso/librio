import 'package:librio/src/domain/entities/rating.dart';
import 'package:librio/src/domain/repositories/rating_repository.dart';

class GetUserRatingsUseCase {
  final RatingRepository repository;

  GetUserRatingsUseCase(this.repository);

  Future<List<Rating>> execute(String userId) {
    return repository.getUserRatings(userId);
  }
}
