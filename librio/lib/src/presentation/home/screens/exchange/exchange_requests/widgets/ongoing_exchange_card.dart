import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/shared/exchange_timeout_helper.dart';
import 'exchange_book_thumbnail.dart';

class OngoingExchangeCard extends StatelessWidget {
  final Exchange exchange;
  final String currentUserId;
  final VoidCallback? onMarkAsCompleted;
  final VoidCallback? onTap;

  const OngoingExchangeCard({
    Key? key,
    required this.exchange,
    required this.currentUserId,
    this.onMarkAsCompleted,
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
            _buildHeader(),
            const SizedBox(height: 12),
            _buildExchangeInfo(isProposer),
            const SizedBox(height: 16),
            _buildBooksSection(),
            const SizedBox(height: 16),
            if (_shouldShowConfirmationStatus()) ...[
              _buildConfirmationStatus(),
              const SizedBox(height: 12),
            ],
            if (_shouldShowTimeoutInfo()) ...[
              _buildTimeoutInfo(),
              const SizedBox(height: 12),
            ],
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Em Andamento',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        Text(
          DateFormat('dd/MM/yyyy').format(exchange.createdAt),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildExchangeInfo(bool isProposer) {
    return Text(
      isProposer
          ? 'Sua troca com ${exchange.receiverName}'
          : 'Troca com ${exchange.proposerName}',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildBooksSection() {
    return Row(
      children: [
        ExchangeBookThumbnail(
          imageUrl: exchange.proposerBookImageUrl,
          title: exchange.proposerBookTitle,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(
            Icons.swap_horiz,
            size: 24,
            color: Colors.blue,
          ),
        ),
        ExchangeBookThumbnail(
          imageUrl: exchange.receiverBookImageUrl,
          title: exchange.receiverBookTitle,
        ),
      ],
    );
  }

  bool _shouldShowConfirmationStatus() {
    return exchange.proposerConfirmed || exchange.receiverConfirmed;
  }

  Widget _buildConfirmationStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status de confirmação:',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          _buildConfirmationRow(
            exchange.proposerName,
            exchange.proposerConfirmed,
          ),
          const SizedBox(height: 2),
          _buildConfirmationRow(
            exchange.receiverName,
            exchange.receiverConfirmed,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String userName, bool isConfirmed) {
    return Row(
      children: [
        Icon(
          isConfirmed ? Icons.check_circle : Icons.schedule,
          color: isConfirmed ? Colors.green : Colors.orange,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '$userName: ${isConfirmed ? "Confirmou" : "Pendente"}',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  bool _shouldShowTimeoutInfo() {
    if (exchange.status != ExchangeStatus.accepted) return false;
    final timeoutInfo =
        ExchangeTimeoutHelper.getTimeoutInfo(exchange, currentUserId);
    return timeoutInfo.isNotEmpty;
  }

  Widget _buildTimeoutInfo() {
    final timeoutInfo =
        ExchangeTimeoutHelper.getTimeoutInfo(exchange, currentUserId);
    final isNearTimeout =
        ExchangeTimeoutHelper.isNearTimeout(exchange, currentUserId);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNearTimeout ? Colors.orange.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isNearTimeout ? Colors.orange.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isNearTimeout ? Icons.timer : Icons.schedule,
            color:
                isNearTimeout ? Colors.orange.shade600 : Colors.grey.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              timeoutInfo,
              style: TextStyle(
                fontSize: 12,
                color: isNearTimeout
                    ? Colors.orange.shade700
                    : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final userAlreadyConfirmed = _hasUserAlreadyConfirmed();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: userAlreadyConfirmed ? null : onMarkAsCompleted,
        style: ElevatedButton.styleFrom(
          backgroundColor: userAlreadyConfirmed ? Colors.grey : Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          userAlreadyConfirmed ? 'Você já confirmou' : 'Confirmar conclusão',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  bool _hasUserAlreadyConfirmed() {
    return (currentUserId == exchange.proposerId &&
            exchange.proposerConfirmed) ||
        (currentUserId == exchange.receiverId && exchange.receiverConfirmed);
  }
}
