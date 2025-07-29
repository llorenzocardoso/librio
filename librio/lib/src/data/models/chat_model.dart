import '../../domain/entities/chat.dart';

class ChatModel extends Chat {
  const ChatModel({
    required super.id,
    required super.participantIds,
    super.lastMessage,
    required super.lastMessageTime,
    super.lastMessageSenderId,
    required super.unreadCount,
    required super.createdAt,
    required super.participantInfo,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      participantIds: List<String>.from(json['participantIds'] as List),
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
      unreadCount: Map<String, int>.from(json['unreadCount'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      participantInfo:
          Map<String, dynamic>.from(json['participantInfo'] as Map),
    );
  }

  factory ChatModel.fromFirestore(Map<String, dynamic> doc, String docId) {
    return ChatModel(
      id: docId,
      participantIds: List<String>.from(doc['participantIds'] as List),
      lastMessage: doc['lastMessage'] as String?,
      lastMessageTime: (doc['lastMessageTime'] as dynamic).toDate(),
      lastMessageSenderId: doc['lastMessageSenderId'] as String?,
      unreadCount: Map<String, int>.from(doc['unreadCount'] as Map? ?? {}),
      createdAt: (doc['createdAt'] as dynamic).toDate(),
      participantInfo:
          Map<String, dynamic>.from(doc['participantInfo'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
      'participantInfo': participantInfo,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'createdAt': createdAt,
      'participantInfo': participantInfo,
    };
  }
}
