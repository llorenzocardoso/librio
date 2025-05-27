class Rating {
  final String id;
  final String exchangeId; // ID da troca relacionada
  final String evaluatorId; // ID do usuário que está avaliando
  final String evaluatedId; // ID do usuário que está sendo avaliado
  final int stars; // Nota de 1 a 5 estrelas
  final String message; // Mensagem da avaliação
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
