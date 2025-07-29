import 'package:flutter/material.dart';
import 'package:librio/src/domain/domain.dart';
import 'exchange_card_header.dart';
import 'exchange_books_display.dart';
import 'exchange_status_badge.dart';
import 'exchange_action_buttons.dart';

class ExchangeRequestCard extends StatelessWidget {
  final Exchange exchange;
  final String currentUserId;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;

  const ExchangeRequestCard({
    Key? key,
    required this.exchange,
    required this.currentUserId,
    this.onAccept,
    this.onReject,
    this.onCancel,
    this.onComplete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isProposer = exchange.proposerId == currentUserId;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExchangeCardHeader(
              exchange: exchange,
              isProposer: isProposer,
            ),
            const SizedBox(height: 16),
            ExchangeBooksDisplay(
              exchange: exchange,
            ),
            const SizedBox(height: 16),
            ExchangeStatusBadge(
              status: exchange.status,
            ),
            if (_shouldShowActions(isProposer)) ...[
              const SizedBox(height: 16),
              ExchangeActionButtons(
                exchange: exchange,
                isProposer: isProposer,
                onAccept: onAccept,
                onReject: onReject,
                onCancel: onCancel,
                onComplete: onComplete,
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _shouldShowActions(bool isProposer) {
    return exchange.status == ExchangeStatus.pending ||
        exchange.status == ExchangeStatus.accepted;
  }
}
