class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? description;
  final double averageRating;
  final int ratingCount;
  final int exchangeCount;
  final List<String> ratings;

  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? address;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.description,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.exchangeCount = 0,
    this.ratings = const [],
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.address,
  });
}
