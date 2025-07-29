import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:librio/src/domain/domain.dart';

class ExchangeHeader extends StatelessWidget {
  final Exchange exchange;

  const ExchangeHeader({
    Key? key,
    required this.exchange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(exchange.status),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getStatusText(exchange.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yyyy \'às\' HH:mm')
                    .format(exchange.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getExchangeTitle(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getExchangeSubtitle(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(ExchangeStatus status) {
    switch (status) {
      case ExchangeStatus.pending:
        return 'Pendente';
      case ExchangeStatus.accepted:
        return 'Aceita';
      case ExchangeStatus.completed:
        return 'Concluída';
      case ExchangeStatus.rejected:
        return 'Recusada';
      case ExchangeStatus.cancelled:
        return 'Cancelada';
    }
  }

  Color _getStatusColor(ExchangeStatus status) {
    switch (status) {
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

  String _getExchangeTitle() {
    switch (exchange.status) {
      case ExchangeStatus.pending:
        return 'Proposta de troca enviada';
      case ExchangeStatus.accepted:
        return 'Troca aceita!';
      case ExchangeStatus.completed:
        return 'Troca concluída com sucesso!';
      case ExchangeStatus.rejected:
        return 'Proposta recusada';
      case ExchangeStatus.cancelled:
        return 'Troca cancelada';
    }
  }

  String _getExchangeSubtitle() {
    switch (exchange.status) {
      case ExchangeStatus.pending:
        return 'Aguardando resposta do usuário';
      case ExchangeStatus.accepted:
        return 'Agora vocês podem coordenar a troca';
      case ExchangeStatus.completed:
        return 'A troca foi finalizada';
      case ExchangeStatus.rejected:
        return 'A proposta não foi aceita';
      case ExchangeStatus.cancelled:
        return 'A troca foi cancelada por um dos usuários';
    }
  }
}
