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

  static Future<bool> canChatWith(
      String currentUserId, String otherUserId) async {
    if (currentUserId.isEmpty || otherUserId.isEmpty) {
      return false;
    }

    if (currentUserId == otherUserId) {
      return false;
    }

    try {
      final exchanges = await _getUserExchangesUseCase.execute(currentUserId);

      final specificExchange = exchanges
          .where((exchange) =>
              (exchange.proposerId == currentUserId &&
                  exchange.receiverId == otherUserId) ||
              (exchange.proposerId == otherUserId &&
                  exchange.receiverId == currentUserId))
          .toList();

      if (specificExchange.isNotEmpty) {
        for (var exchange in specificExchange) {}
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
    bool forceStart = false,
  }) async {
    try {
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

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final chatId =
          await _createOrGetChatUseCase([currentUserId, otherUserId]);

      if (context.mounted) {
        Navigator.of(context).pop();

        context
            .push('/chat/$chatId?otherUserName=${otherUserName ?? 'Usuário'}');
      }
    } catch (error) {
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar conversa: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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

  static bool hasUnreadMessages(Map<String, int> unreadCount, String userId) {
    return (unreadCount[userId] ?? 0) > 0;
  }

  static int getUnreadCount(Map<String, int> unreadCount, String userId) {
    return unreadCount[userId] ?? 0;
  }
}
