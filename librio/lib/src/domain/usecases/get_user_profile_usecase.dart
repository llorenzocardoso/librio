import 'package:librio/src/domain/entities/user_profile.dart';
import 'package:librio/src/domain/repositories/rating_repository.dart';

class GetUserProfileUseCase {
  final RatingRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserProfile> execute(String userId) {
    return repository.getUserProfile(userId);
  }
}
