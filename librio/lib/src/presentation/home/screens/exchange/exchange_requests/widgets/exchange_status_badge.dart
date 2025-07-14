import 'package:flutter/material.dart';
import 'package:librio/src/domain/domain.dart';

class ExchangeStatusBadge extends StatelessWidget {
  final ExchangeStatus status;

  const ExchangeStatusBadge({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: config['backgroundColor'],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config['borderColor']),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'],
            size: 16,
            color: config['textColor'],
          ),
          const SizedBox(width: 6),
          Text(
            config['text'],
            style: TextStyle(
              color: config['textColor'],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig() {
    switch (status) {
      case ExchangeStatus.pending:
        return {
          'text': 'Aguardando resposta',
          'backgroundColor': Colors.orange.withOpacity(0.1),
          'borderColor': Colors.orange.withOpacity(0.3),
          'textColor': Colors.orange,
          'icon': Icons.schedule,
        };
      case ExchangeStatus.accepted:
        return {
          'text': 'Aceita - Coordenem a troca!',
          'backgroundColor': Colors.blue.withOpacity(0.1),
          'borderColor': Colors.blue.withOpacity(0.3),
          'textColor': Colors.blue,
          'icon': Icons.check_circle_outline,
        };
      case ExchangeStatus.completed:
        return {
          'text': 'Troca concluída',
          'backgroundColor': Colors.green.withOpacity(0.1),
          'borderColor': Colors.green.withOpacity(0.3),
          'textColor': Colors.green,
          'icon': Icons.check_circle,
        };
      case ExchangeStatus.rejected:
        return {
          'text': 'Recusada',
          'backgroundColor': Colors.red.withOpacity(0.1),
          'borderColor': Colors.red.withOpacity(0.3),
          'textColor': Colors.red,
          'icon': Icons.cancel,
        };
      case ExchangeStatus.cancelled:
        return {
          'text': 'Cancelada',
          'backgroundColor': Colors.grey.withOpacity(0.1),
          'borderColor': Colors.grey.withOpacity(0.3),
          'textColor': Colors.grey,
          'icon': Icons.block,
        };
    }
  }
}
