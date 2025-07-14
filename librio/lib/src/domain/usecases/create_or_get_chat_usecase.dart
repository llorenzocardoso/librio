import '../repositories/chat_repository.dart';

class CreateOrGetChatUseCase {
  final ChatRepository _repository;

  CreateOrGetChatUseCase(this._repository);

  Future<String> call(List<String> participantIds) async {
    _validateParticipants(participantIds);

    return await _repository.createOrGetChat(participantIds);
  }

  void _validateParticipants(List<String> participantIds) {
    if (participantIds.isEmpty) {
      throw ArgumentError('Lista de participantes não pode estar vazia');
    }

    if (participantIds.length != 2) {
      throw ArgumentError(
          'Chat deve ter exatamente 2 participantes, recebido: ${participantIds.length}');
    }

    for (String id in participantIds) {
      if (id.isEmpty || id.trim().isEmpty) {
        throw ArgumentError('ID de participante não pode estar vazio');
      }
    }

    if (participantIds[0] == participantIds[1]) {
      throw ArgumentError(
          'Não é possível criar chat: usuário não pode conversar consigo mesmo');
    }

    final uniqueIds = participantIds.toSet();
    if (uniqueIds.length != participantIds.length) {
      throw ArgumentError('IDs de participantes duplicados encontrados');
    }
  }
}
