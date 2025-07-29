import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.content,
    required super.type,
    required super.timestamp,
    super.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  factory MessageModel.fromFirestore(Map<String, dynamic> doc, String docId) {
    return MessageModel(
      id: docId,
      chatId: doc['chatId'] as String,
      senderId: doc['senderId'] as String,
      content: doc['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == doc['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: (doc['timestamp'] as dynamic).toDate(),
      isRead: doc['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}
