import '../repositories/chat_repository.dart';

class MarkChatAsReadUseCase {
  final ChatRepository _repository;

  MarkChatAsReadUseCase(this._repository);

  Future<void> call(String chatId, String userId) async {
    await _repository.markAsRead(chatId, userId);
  }
}
