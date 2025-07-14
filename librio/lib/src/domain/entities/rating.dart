class Rating {
  final String id;
  final String exchangeId;
  final String evaluatorId;
  final String evaluatedId;
  final int stars;
  final String message;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.exchangeId,
    required this.evaluatorId,
    required this.evaluatedId,
    required this.stars,
    required this.message,
    required this.createdAt,
  });
}
