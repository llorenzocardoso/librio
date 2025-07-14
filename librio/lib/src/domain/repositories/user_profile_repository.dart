import 'package:librio/src/domain/entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile> getUserProfile(String userId);

  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? description,
    String? photoUrl,
  });

  Future<void> updateUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    String? city,
    String? state,
    String? address,
  });
}
