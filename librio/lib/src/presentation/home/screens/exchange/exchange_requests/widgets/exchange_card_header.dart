import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:librio/src/domain/domain.dart';

class ExchangeCardHeader extends StatelessWidget {
  final Exchange exchange;
  final bool isProposer;

  const ExchangeCardHeader({
    Key? key,
    required this.exchange,
    required this.isProposer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(
            Icons.person,
            size: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isProposer
                    ? 'Você propôs uma troca para ${exchange.receiverName}'
                    : '${exchange.proposerName} lhe propôs uma troca!',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Enviada em ${DateFormat('dd/MM/yyyy').format(exchange.createdAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
