import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:librio/src/domain/domain.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final Color? backgroundColor;
  final Color? borderColor;
  final Widget? icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const NotificationCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.time,
    this.backgroundColor,
    this.borderColor,
    this.icon,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class PendingRatingCard extends StatelessWidget {
  final Exchange exchange;
  final VoidCallback onTap;

  const PendingRatingCard({
    Key? key,
    required this.exchange,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationCard(
      title: 'Avalie sua troca',
      subtitle: 'Troca concluída com ${_getOtherUserName()}',
      time:
          'Concluída em ${DateFormat('dd/MM/yyyy').format(exchange.updatedAt ?? exchange.createdAt)}',
      backgroundColor: Colors.amber.shade50,
      borderColor: Colors.amber.shade200,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.star_outline,
          size: 20,
          color: Colors.amber.shade700,
        ),
      ),
      onTap: onTap,
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
    );
  }

  String _getOtherUserName() {
    // Esta lógica pode ser melhorada com informações do usuário atual
    return exchange.proposerName.isNotEmpty
        ? exchange.proposerName
        : exchange.receiverName;
  }
}

class ExchangeNotificationCard extends StatelessWidget {
  final Exchange exchange;
  final String type; // 'pending', 'accepted', 'recent'
  final VoidCallback onTap;
  final VoidCallback? onAction;
  final String? actionText;

  const ExchangeNotificationCard({
    Key? key,
    required this.exchange,
    required this.type,
    required this.onTap,
    this.onAction,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getTypeConfig();

    return NotificationCard(
      title: config['title']!,
      subtitle: config['subtitle']!,
      time: config['time']!,
      backgroundColor: config['backgroundColor'],
      borderColor: config['borderColor'],
      icon: config['icon'],
      onTap: onTap,
      trailing: onAction != null && actionText != null
          ? TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                actionText!,
                style: const TextStyle(fontSize: 12),
              ),
            )
          : const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
    );
  }

  Map<String, dynamic> _getTypeConfig() {
    switch (type) {
      case 'pending':
        return {
          'title': 'Nova proposta de troca',
          'subtitle':
              '${exchange.proposerName} quer trocar "${exchange.proposerBookTitle}" por "${exchange.receiverBookTitle}"',
          'time':
              'Recebida em ${DateFormat('dd/MM/yyyy').format(exchange.createdAt)}',
          'backgroundColor': Colors.blue.shade50,
          'borderColor': Colors.blue.shade200,
          'icon': Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.swap_horiz,
              size: 20,
              color: Colors.blue.shade700,
            ),
          ),
        };
      case 'accepted':
        return {
          'title': 'Proposta aceita!',
          'subtitle': '${exchange.receiverName} aceitou sua proposta de troca',
          'time':
              'Aceita em ${DateFormat('dd/MM/yyyy').format(exchange.updatedAt ?? exchange.createdAt)}',
          'backgroundColor': Colors.green.shade50,
          'borderColor': Colors.green.shade200,
          'icon': Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 20,
              color: Colors.green.shade700,
            ),
          ),
        };
      case 'recent':
        String statusText = '';
        Color statusColor = Colors.grey;

        switch (exchange.status) {
          case ExchangeStatus.completed:
            statusText = 'Troca concluída';
            statusColor = Colors.green;
            break;
          case ExchangeStatus.rejected:
            statusText = 'Proposta recusada';
            statusColor = Colors.red;
            break;
          default:
            statusText = 'Troca atualizada';
        }

        return {
          'title': statusText,
          'subtitle':
              'Troca entre "${exchange.proposerBookTitle}" e "${exchange.receiverBookTitle}"',
          'time':
              'Atualizada em ${DateFormat('dd/MM/yyyy').format(exchange.updatedAt ?? exchange.createdAt)}',
          'backgroundColor': _getColorShade(statusColor, 50),
          'borderColor': _getColorShade(statusColor, 200),
          'icon': Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getColorShade(statusColor, 100),
              shape: BoxShape.circle,
            ),
            child: Icon(
              exchange.status == ExchangeStatus.completed
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
              size: 20,
              color: _getColorShade(statusColor, 700),
            ),
          ),
        };
      default:
        return {
          'title': 'Notificação',
          'subtitle': 'Detalhes da troca',
          'time': DateFormat('dd/MM/yyyy').format(exchange.createdAt),
          'backgroundColor': Colors.grey.shade50,
          'borderColor': Colors.grey.shade200,
          'icon': const Icon(Icons.notifications_outlined),
        };
    }
  }

  Color _getColorShade(Color color, int shade) {
    if (color == Colors.green) {
      switch (shade) {
        case 50:
          return Colors.green.shade50;
        case 100:
          return Colors.green.shade100;
        case 200:
          return Colors.green.shade200;
        case 700:
          return Colors.green.shade700;
        default:
          return color;
      }
    } else if (color == Colors.red) {
      switch (shade) {
        case 50:
          return Colors.red.shade50;
        case 100:
          return Colors.red.shade100;
        case 200:
          return Colors.red.shade200;
        case 700:
          return Colors.red.shade700;
        default:
          return color;
      }
    } else {
      // Para Colors.grey ou outras cores sem shade
      switch (shade) {
        case 50:
          return Colors.grey.shade50;
        case 100:
          return Colors.grey.shade100;
        case 200:
          return Colors.grey.shade200;
        case 700:
          return Colors.grey.shade700;
        default:
          return color;
      }
    }
  }
}
