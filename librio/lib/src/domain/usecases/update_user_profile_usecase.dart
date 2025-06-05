import 'package:librio/src/domain/repositories/user_profile_repository.dart';

class UpdateUserProfileUseCase {
  final UserProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<void> execute({
    required String userId,
    String? name,
    String? description,
    String? photoUrl,
  }) {
    return repository.updateUserProfile(
      userId: userId,
      name: name,
      description: description,
      photoUrl: photoUrl,
    );
  }
}
