class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? description;
  final double averageRating; // Média das avaliações
  final int ratingCount; // Número total de avaliações
  final int exchangeCount; // Número total de trocas realizadas
  final List<String> ratings; // IDs das avaliações recebidas

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
  });
}
