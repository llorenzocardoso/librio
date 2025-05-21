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
  });
}
