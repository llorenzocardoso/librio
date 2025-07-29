class Exchange {
  final String id;
  final String proposerId;
  final String receiverId;
  final String proposerBookId;
  final String receiverBookId;
  final String proposerBookTitle;
  final String receiverBookTitle;
  final String proposerBookImageUrl;
  final String receiverBookImageUrl;
  final String proposerBookAuthor;
  final String receiverBookAuthor;
  final String proposerBookGenre;
  final String receiverBookGenre;
  final String proposerBookCondition;
  final String receiverBookCondition;
  final String proposerName;
  final String receiverName;
  final ExchangeStatus status;
  final String? message;
  final bool proposerConfirmed;
  final bool receiverConfirmed;
  final DateTime? proposerConfirmedAt;
  final DateTime? receiverConfirmedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  Exchange({
    required this.id,
    required this.proposerId,
    required this.receiverId,
    required this.proposerBookId,
    required this.receiverBookId,
    required this.proposerBookTitle,
    required this.receiverBookTitle,
    required this.proposerBookImageUrl,
    required this.receiverBookImageUrl,
    required this.proposerBookAuthor,
    required this.receiverBookAuthor,
    required this.proposerBookGenre,
    required this.receiverBookGenre,
    required this.proposerBookCondition,
    required this.receiverBookCondition,
    required this.proposerName,
    required this.receiverName,
    required this.status,
    this.message,
    this.proposerConfirmed = false,
    this.receiverConfirmed = false,
    this.proposerConfirmedAt,
    this.receiverConfirmedAt,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });
}

enum ExchangeStatus {
  pending,
  accepted,
  rejected,
  completed,
  cancelled,
}

extension ExchangeStatusExtension on ExchangeStatus {
  String get displayName {
    switch (this) {
      case ExchangeStatus.pending:
        return 'Aguardando';
      case ExchangeStatus.accepted:
        return 'Aceita';
      case ExchangeStatus.rejected:
        return 'Rejeitada';
      case ExchangeStatus.completed:
        return 'Troca concluída';
      case ExchangeStatus.cancelled:
        return 'Cancelada';
    }
  }

  String get displayNameForHistory {
    switch (this) {
      case ExchangeStatus.pending:
        return 'Troca pendente';
      case ExchangeStatus.accepted:
        return 'Troca aceita';
      case ExchangeStatus.rejected:
        return 'Troca rejeitada';
      case ExchangeStatus.completed:
        return 'Troca concluída';
      case ExchangeStatus.cancelled:
        return 'Troca cancelada';
    }
  }
}
