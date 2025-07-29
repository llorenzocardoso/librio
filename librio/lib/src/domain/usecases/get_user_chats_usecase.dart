import '../entities/chat.dart';
import '../repositories/chat_repository.dart';

class GetUserChatsUseCase {
  final ChatRepository _repository;

  GetUserChatsUseCase(this._repository);

  Stream<List<Chat>> call(String userId) {
    return _repository.getUserChats(userId);
  }
}
