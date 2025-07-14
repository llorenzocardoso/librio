import 'package:librio/src/domain/entities/chat.dart';
import 'package:librio/src/domain/repositories/chat_repository.dart';

class GetChatUseCase {
  final ChatRepository repository;

  GetChatUseCase(this.repository);

  Future<Chat?> execute(String chatId) async {
    return await repository.getChatById(chatId);
  }
}
