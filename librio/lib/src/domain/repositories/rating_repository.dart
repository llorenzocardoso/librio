import 'package:librio/src/domain/entities/rating.dart';
import 'package:librio/src/domain/entities/user_profile.dart';

abstract class RatingRepository {
  Future<void> createRating({
    required String exchangeId,
    required String evaluatorId,
    required String evaluatedId,
    required int stars,
    required String message,
  });

  Future<List<Rating>> getUserRatings(String userId);
  Future<UserProfile> getUserProfile(String userId);
  Future<bool> hasUserRatedExchange(String exchangeId, String evaluatorId);
  Future<void> updateUserRatingStats(String userId);
}
