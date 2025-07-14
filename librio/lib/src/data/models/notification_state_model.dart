class NotificationStateModel {
  final String userId;
  final List<String> viewedExchangeIds;
  final DateTime lastViewed;

  const NotificationStateModel({
    required this.userId,
    required this.viewedExchangeIds,
    required this.lastViewed,
  });

  factory NotificationStateModel.fromMap(Map<String, dynamic> map) {
    return NotificationStateModel(
      userId: map['userId'] ?? '',
      viewedExchangeIds: List<String>.from(map['viewedExchangeIds'] ?? []),
      lastViewed: DateTime.fromMillisecondsSinceEpoch(map['lastViewed'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'viewedExchangeIds': viewedExchangeIds,
      'lastViewed': lastViewed.millisecondsSinceEpoch,
    };
  }

  NotificationStateModel copyWith({
    String? userId,
    List<String>? viewedExchangeIds,
    DateTime? lastViewed,
  }) {
    return NotificationStateModel(
      userId: userId ?? this.userId,
      viewedExchangeIds: viewedExchangeIds ?? this.viewedExchangeIds,
      lastViewed: lastViewed ?? this.lastViewed,
    );
  }
}
