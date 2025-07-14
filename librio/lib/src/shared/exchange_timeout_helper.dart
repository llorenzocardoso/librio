import 'package:librio/src/domain/entities/exchange.dart';

class ExchangeTimeoutHelper {
  static const int timeoutHours = 48;

  /// Calcula quanto tempo falta para o timeout automático
  static String getTimeoutInfo(Exchange exchange, String currentUserId) {
    if (exchange.status != ExchangeStatus.accepted) {
      return '';
    }

    final now = DateTime.now();

    // Se o usuário atual já confirmou, mostrar info sobre o outro usuário
    if (currentUserId == exchange.proposerId && exchange.proposerConfirmed) {
      if (exchange.receiverConfirmedAt != null) {
        return _formatRemainingTime(exchange.receiverConfirmedAt!, now);
      }
      return 'Aguardando confirmação do outro usuário';
    }

    if (currentUserId == exchange.receiverId && exchange.receiverConfirmed) {
      if (exchange.proposerConfirmedAt != null) {
        return _formatRemainingTime(exchange.proposerConfirmedAt!, now);
      }
      return 'Aguardando confirmação do outro usuário';
    }

    // Se o outro usuário já confirmou, mostrar tempo restante para auto-confirmação
    if (currentUserId == exchange.proposerId &&
        exchange.receiverConfirmedAt != null) {
      return 'Auto-confirmação em ${_formatRemainingTime(exchange.receiverConfirmedAt!, now)}';
    }

    if (currentUserId == exchange.receiverId &&
        exchange.proposerConfirmedAt != null) {
      return 'Auto-confirmação em ${_formatRemainingTime(exchange.proposerConfirmedAt!, now)}';
    }

    return '';
  }

  /// Verifica se uma exchange está próxima do timeout (últimas 6 horas)
  static bool isNearTimeout(Exchange exchange, String currentUserId) {
    if (exchange.status != ExchangeStatus.accepted) {
      return false;
    }

    final now = DateTime.now();
    DateTime? relevantConfirmationTime;

    if (currentUserId == exchange.proposerId &&
        exchange.receiverConfirmedAt != null) {
      relevantConfirmationTime = exchange.receiverConfirmedAt!;
    } else if (currentUserId == exchange.receiverId &&
        exchange.proposerConfirmedAt != null) {
      relevantConfirmationTime = exchange.proposerConfirmedAt!;
    }

    if (relevantConfirmationTime != null) {
      final hoursSinceConfirmation =
          now.difference(relevantConfirmationTime).inHours;
      return hoursSinceConfirmation >= (timeoutHours - 6); // Últimas 6 horas
    }

    return false;
  }

  /// Formata o tempo restante de forma amigável
  static String _formatRemainingTime(DateTime confirmationTime, DateTime now) {
    final deadline = confirmationTime.add(const Duration(hours: timeoutHours));
    final remaining = deadline.difference(now);

    if (remaining.isNegative) {
      return 'Tempo expirado - será confirmado automaticamente';
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  /// Retorna uma mensagem explicativa sobre o sistema de timeout
  static String getTimeoutExplanation() {
    return 'Após uma pessoa confirmar a troca, a outra parte tem 48h para confirmar. '
        'Caso não confirme neste prazo, a troca será automaticamente marcada como concluída.';
  }
}
