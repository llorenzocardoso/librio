import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/presentation/presentation.dart';

class BottomActionBar extends StatelessWidget {
  final Exchange exchange;
  final ExchangeDetailsViewModel viewModel;
  final BuildContext context;

  const BottomActionBar({
    Key? key,
    required this.exchange,
    required this.viewModel,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (viewModel.isReceiver(exchange) &&
        exchange.status == ExchangeStatus.pending) {
      return _buildAcceptButton();
    }

    if (exchange.status == ExchangeStatus.accepted) {
      return _buildAcceptedButtons();
    }

    if (exchange.status == ExchangeStatus.completed) {
      return _buildRatingButton();
    }

    return const SizedBox.shrink();
  }

  Widget _buildAcceptButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: ElevatedButton(
        onPressed: viewModel.isLoading
            ? null
            : () => viewModel.acceptExchange(exchange.id, context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF176FF1),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: viewModel.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Aceitar proposta',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildAcceptedButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () => _startChat(exchange),
            icon: const Icon(Icons.chat, size: 18),
            label: const Text(
              'Iniciar conversa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF176FF1),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () =>
                    viewModel.markAsCompleted(exchange.id, context, exchange),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: viewModel.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Marcar como concluída',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingButton() {
    if (viewModel.isCheckingRating) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!viewModel.hasRated) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: ElevatedButton(
          onPressed: () => viewModel.navigateToRating(context, exchange),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Avaliar usuário',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _startChat(Exchange exchange) async {
    try {
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final otherUserId = currentUser.uid == exchange.proposerId
          ? exchange.receiverId
          : exchange.proposerId;

      await ChatHelper.startChatWith(
        context,
        otherUserId,
        currentUser.uid,
        forceStart: true,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao iniciar conversa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
