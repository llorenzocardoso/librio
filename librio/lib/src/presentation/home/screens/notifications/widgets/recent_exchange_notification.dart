import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/shared/shared.dart';

class RecentExchangeNotification extends StatelessWidget {
  final Exchange exchange;
  final VoidCallback onTap;

  const RecentExchangeNotification({
    Key? key,
    required this.exchange,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor()),
        boxShadow: [
          BoxShadow(
            color: _getBackgroundColor(),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getStatusIcon(exchange.status),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getStatusMessage(exchange),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                DateHelper.formatRelativeTime(exchange.createdAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${exchange.proposerBookTitle} ↔ ${exchange.receiverBookTitle}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text('Ver detalhes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getButtonColor(),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(ExchangeStatus status) {
    switch (status) {
      case ExchangeStatus.accepted:
        return Icon(Icons.check_circle, color: Colors.green.shade600, size: 20);
      case ExchangeStatus.completed:
        return Icon(Icons.verified, color: Colors.blue.shade600, size: 20);
      case ExchangeStatus.rejected:
        return Icon(Icons.cancel, color: Colors.red.shade600, size: 20);
      default:
        return Icon(Icons.hourglass_empty,
            color: Colors.orange.shade600, size: 20);
    }
  }

  String _getStatusMessage(Exchange exchange) {
    final currentUserId = fb.FirebaseAuth.instance.currentUser?.uid;
    final isProposer = exchange.proposerId == currentUserId;
    final otherUserName = isProposer ? exchange.receiverName : exchange.proposerName;

    switch (exchange.status) {
      case ExchangeStatus.accepted:
        return isProposer
            ? '$otherUserName aceitou sua proposta'
            : 'Você aceitou a proposta de $otherUserName';
      case ExchangeStatus.completed:
        return 'Troca com $otherUserName foi concluída';
      case ExchangeStatus.rejected:
        return isProposer
            ? '$otherUserName recusou sua proposta'
            : 'Você recusou a proposta de $otherUserName';
      default:
        return 'Troca com $otherUserName';
    }
  }

  Color _getBorderColor() {
    switch (exchange.status) {
      case ExchangeStatus.accepted:
        return Colors.green.shade200;
      case ExchangeStatus.completed:
        return Colors.blue.shade200;
      case ExchangeStatus.rejected:
        return Colors.red.shade200;
      default:
        return Colors.orange.shade200;
    }
  }

  Color _getBackgroundColor() {
    switch (exchange.status) {
      case ExchangeStatus.accepted:
        return Colors.green.shade100;
      case ExchangeStatus.completed:
        return Colors.blue.shade100;
      case ExchangeStatus.rejected:
        return Colors.red.shade100;
      default:
        return Colors.orange.shade100;
    }
  }

  Color _getButtonColor() {
    switch (exchange.status) {
      case ExchangeStatus.accepted:
        return Colors.green.shade700;
      case ExchangeStatus.completed:
        return Colors.blue.shade700;
      case ExchangeStatus.rejected:
        return Colors.red.shade700;
      default:
        return Colors.orange.shade700;
    }
  }
}
