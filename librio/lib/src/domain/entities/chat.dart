class Chat {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final Map<String, dynamic>
      participantInfo; // Para armazenar nome e foto dos participantes

  const Chat({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    required this.lastMessageTime,
    this.lastMessageSenderId,
    required this.unreadCount,
    required this.createdAt,
    required this.participantInfo,
  });

  Chat copyWith({
    String? id,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    Map<String, dynamic>? participantInfo,
  }) {
    return Chat(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      participantInfo: participantInfo ?? this.participantInfo,
    );
  }
}
