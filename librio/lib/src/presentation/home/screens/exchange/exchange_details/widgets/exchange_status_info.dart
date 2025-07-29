import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:librio/src/domain/domain.dart';

class ExchangeStatusInfo extends StatelessWidget {
  final Exchange exchange;

  const ExchangeStatusInfo({
    Key? key,
    required this.exchange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusBorderColor()),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDescription(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (_getStatusDate().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getStatusDate(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusTitle() {
    switch (exchange.status) {
      case ExchangeStatus.pending:
        return 'Aguardando resposta';
      case ExchangeStatus.accepted:
        return 'Troca aceita!';
      case ExchangeStatus.completed:
        return 'Troca concluída';
      case ExchangeStatus.rejected:
        return 'Proposta recusada';
      case ExchangeStatus.cancelled:
        return 'Troca cancelada';
    }
  }

  String _getStatusDescription() {
    switch (exchange.status) {
      case ExchangeStatus.pending:
        return 'A proposta foi enviada e está aguardando resposta.';
      case ExchangeStatus.accepted:
        return 'A proposta foi aceita! Coordenem a troca entre vocês.';
      case ExchangeStatus.completed:
        return 'A troca foi concluída com sucesso!';
      case ExchangeStatus.rejected:
        return 'A proposta foi recusada.';
      case ExchangeStatus.cancelled:
        return 'A troca foi cancelada.';
    }
  }

  String _getStatusDate() {
    final formatter = DateFormat('dd/MM/yyyy \'às\' HH:mm');
    switch (exchange.status) {
      case ExchangeStatus.pending:
        return 'Proposta enviada em ${formatter.format(exchange.createdAt)}';
      case ExchangeStatus.accepted:
        return exchange.updatedAt != null
            ? 'Aceita em ${formatter.format(exchange.updatedAt!)}'
            : '';
      case ExchangeStatus.completed:
        return exchange.updatedAt != null
            ? 'Concluída em ${formatter.format(exchange.updatedAt!)}'
            : '';
      case ExchangeStatus.rejected:
        return exchange.updatedAt != null
            ? 'Recusada em ${formatter.format(exchange.updatedAt!)}'
            : '';
      case ExchangeStatus.cancelled:
        return exchange.updatedAt != null
            ? 'Cancelada em ${formatter.format(exchange.updatedAt!)}'
            : '';
    }
  }

  IconData _getStatusIcon() {
    switch (exchange.status) {
      case ExchangeStatus.pending:
        return Icons.schedule;
      case ExchangeStatus.accepted:
        return Icons.check_circle_outline;
      case ExchangeStatus.completed:
        return Icons.check_circle;
      case ExchangeStatus.rejected:
        return Icons.cancel_outlined;
      case ExchangeStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor() {
    switch (exchange.status) {
      case ExchangeStatus.pending:
        return Colors.orange;
      case ExchangeStatus.accepted:
        return Colors.blue;
      case ExchangeStatus.completed:
        return Colors.green;
      case ExchangeStatus.rejected:
        return Colors.red;
      case ExchangeStatus.cancelled:
        return Colors.grey;
    }
  }

  Color _getStatusBackgroundColor() {
    switch (exchange.status) {
      case ExchangeStatus.pending:
        return Colors.orange.shade50;
      case ExchangeStatus.accepted:
        return Colors.blue.shade50;
      case ExchangeStatus.completed:
        return Colors.green.shade50;
      case ExchangeStatus.rejected:
        return Colors.red.shade50;
      case ExchangeStatus.cancelled:
        return Colors.grey.shade50;
    }
  }

  Color _getStatusBorderColor() {
    switch (exchange.status) {
      case ExchangeStatus.pending:
        return Colors.orange.shade200;
      case ExchangeStatus.accepted:
        return Colors.blue.shade200;
      case ExchangeStatus.completed:
        return Colors.green.shade200;
      case ExchangeStatus.rejected:
        return Colors.red.shade200;
      case ExchangeStatus.cancelled:
        return Colors.grey.shade200;
    }
  }
}
