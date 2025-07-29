import 'package:librio/src/domain/repositories/user_profile_repository.dart';

class UpdateUserLocationUseCase {
  final UserProfileRepository repository;

  UpdateUserLocationUseCase(this.repository);

  Future<void> execute({
    required String userId,
    required double latitude,
    required double longitude,
    String? city,
    String? state,
    String? address,
  }) {
    return repository.updateUserLocation(
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      city: city,
      state: state,
      address: address,
    );
  }
}
