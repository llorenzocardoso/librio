import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetChatMessagesUseCase {
  final ChatRepository _repository;

  GetChatMessagesUseCase(this._repository);

  Stream<List<Message>> call(String chatId) {
    return _repository.getChatMessages(chatId);
  }
}
