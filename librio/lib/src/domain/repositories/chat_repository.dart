import '../entities/chat.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Stream<List<Chat>> getUserChats(String userId);
  Future<Chat?> getChatById(String chatId);
  Future<String> createOrGetChat(List<String> participantIds);
  Future<void> updateLastMessage(
      String chatId, String message, String senderId);
  Future<void> markAsRead(String chatId, String userId);

  Stream<List<Message>> getChatMessages(String chatId);
  Future<Message> sendMessage(Message message);
  Future<void> markMessageAsRead(String messageId);
}
