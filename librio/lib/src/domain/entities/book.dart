class Book {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String condition;
  final String ownerId;
  final String genre;
  final String description;
  final bool available;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.condition,
    required this.ownerId,
    required this.genre,
    required this.description,
    this.available = true,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
  });
}
