import 'package:librio/src/domain/entities/user_profile.dart';
import 'package:librio/src/domain/repositories/user_profile_repository.dart';

class GetUserProfileUseCase {
  final UserProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserProfile> execute(String userId) {
    return repository.getUserProfile(userId);
  }
}
