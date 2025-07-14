import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/usecases/create_or_get_chat_usecase.dart';
import '../../../../domain/usecases/get_user_exchanges_usecase.dart';
import '../../../../data/repositories/chat_repository_impl.dart';
import '../../../../data/repositories/exchange_repository_impl.dart';

class ChatHelper {
  static final CreateOrGetChatUseCase _createOrGetChatUseCase =
      CreateOrGetChatUseCase(ChatRepositoryImpl());
  static final GetUserExchangesUseCase _getUserExchangesUseCase =
      GetUserExchangesUseCase(ExchangeRepositoryImpl());

  /// Verifica se o usuário pode conversar com outro baseado nas trocas
  static Future<bool> canChatWith(
      String currentUserId, String otherUserId) async {
    // Validação básica de entrada
    if (currentUserId.isEmpty || otherUserId.isEmpty) {
      return false;
    }

    if (currentUserId == otherUserId) {
      return false;
    }

    try {

      final exchanges = await _getUserExchangesUseCase.execute(currentUserId);

      // Verificar se existe alguma troca ESPECÍFICA entre os dois usuários
      final specificExchange = exchanges.where((exchange) =>
          (exchange.proposerId == currentUserId &&
              exchange.receiverId == otherUserId) ||
          (exchange.proposerId == otherUserId &&
              exchange.receiverId == currentUserId)).toList();

      if (specificExchange.isNotEmpty) {
        for (var exchange in specificExchange) {
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<void> startChatWith(
    BuildContext context,
    String otherUserId,
    String currentUserId, {
    String? otherUserName,
    bool forceStart =
        false, // Para forçar início do chat (ex: após enviar proposta)
  }) async {
    try {

      // Verificar se pode conversar (a menos que seja forçado)
      if (!forceStart) {
        final canChat = await canChatWith(currentUserId, otherUserId);
        if (!canChat) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Você precisa enviar uma proposta de troca antes de conversar'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Criar ou buscar chat existente
      final chatId =
          await _createOrGetChatUseCase([currentUserId, otherUserId]);

      // Fechar loading
      if (context.mounted) {
        Navigator.of(context).pop();

        // Navegar para o chat
        context
            .push('/chat/$chatId?otherUserName=${otherUserName ?? 'Usuário'}');
      }
    } catch (error) {
      // Fechar loading
      if (context.mounted) {
        Navigator.of(context).pop();

        // Mostrar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar conversa: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Formata o tempo da última mensagem
  static String formatLastMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'Agora';
    }
  }

  /// Verifica se deve mostrar indicador de não lidas
  static bool hasUnreadMessages(Map<String, int> unreadCount, String userId) {
    return (unreadCount[userId] ?? 0) > 0;
  }

  /// Obtém o número de mensagens não lidas
  static int getUnreadCount(Map<String, int> unreadCount, String userId) {
    return unreadCount[userId] ?? 0;
  }
}
