import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:librio/src/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required String id,
    required String name,
    required String email,
    String? photoUrl,
    String? description,
    double averageRating = 0.0,
    int ratingCount = 0,
    int exchangeCount = 0,
    List<String> ratings = const [],
    double? latitude,
    double? longitude,
    String? city,
    String? state,
    String? address,
  }) : super(
          id: id,
          name: name,
          email: email,
          photoUrl: photoUrl,
          description: description,
          averageRating: averageRating,
          ratingCount: ratingCount,
          exchangeCount: exchangeCount,
          ratings: ratings,
          latitude: latitude,
          longitude: longitude,
          city: city,
          state: state,
          address: address,
        );

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      description: data['description'],
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      exchangeCount: data['exchangeCount'] ?? 0,
      ratings: List<String>.from(data['ratings'] ?? []),
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      city: data['city'],
      state: data['state'],
      address: data['address'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'description': description,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'exchangeCount': exchangeCount,
      'ratings': ratings,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'address': address,
    };
  }
}
