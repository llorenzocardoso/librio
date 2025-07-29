import 'package:flutter/material.dart';
import 'package:librio/src/domain/domain.dart';

class ExchangeActionButtons extends StatelessWidget {
  final Exchange exchange;
  final bool isProposer;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;
  final VoidCallback? onComplete;

  const ExchangeActionButtons({
    Key? key,
    required this.exchange,
    required this.isProposer,
    this.onAccept,
    this.onReject,
    this.onCancel,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (exchange.status == ExchangeStatus.pending && !isProposer) {
      return _buildReceiverActions();
    }

    if (exchange.status == ExchangeStatus.pending && isProposer) {
      return _buildProposerActions();
    }

    if (exchange.status == ExchangeStatus.accepted) {
      return _buildAcceptedActions();
    }

    return const SizedBox.shrink();
  }

  Widget _buildReceiverActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onReject,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              side: BorderSide(color: Colors.red.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Recusar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Aceitar'),
          ),
        ),
      ],
    );
  }

  Widget _buildProposerActions() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onCancel,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          side: BorderSide(color: Colors.red.shade200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Cancelar Proposta'),
      ),
    );
  }

  Widget _buildAcceptedActions() {
    return Column(
      children: [
        if (_hasExchangeExpired()) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta troca expirou após 48h. Marque como concluída se já realizaram a troca.',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Marcar como Concluída'),
          ),
        ),
      ],
    );
  }

  bool _hasExchangeExpired() {
    if (exchange.status != ExchangeStatus.accepted) return false;
    final now = DateTime.now();
    final acceptedTime = exchange.updatedAt ?? exchange.createdAt;
    final hoursSinceAccepted = now.difference(acceptedTime).inHours;
    return hoursSinceAccepted >= 48; // 48 horas para completar a troca
  }
}
