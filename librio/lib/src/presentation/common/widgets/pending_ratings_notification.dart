import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/data/data.dart';
import 'package:librio/src/presentation/presentation.dart';

class PendingRatingsNotification extends StatefulWidget {
  const PendingRatingsNotification({Key? key}) : super(key: key);

  @override
  State<PendingRatingsNotification> createState() =>
      _PendingRatingsNotificationState();
}

class _PendingRatingsNotificationState
    extends State<PendingRatingsNotification> {
  late GetPendingRatingsUseCase _getPendingRatingsUseCase;
  List<Exchange> pendingRatings = [];
  bool isLoading = true;
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    _getPendingRatingsUseCase = GetPendingRatingsUseCase(
      ExchangeRepositoryImpl(),
      RatingRepositoryImpl(),
    );
    _loadPendingRatings();
  }

  Future<void> _loadPendingRatings() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final pending = await _getPendingRatingsUseCase.execute(user.uid);
      setState(() {
        pendingRatings = pending;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _dismissNotification() {
    setState(() => isVisible = false);
  }

  void _navigateToRating(Exchange exchange) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => RatingScreen(exchange: exchange),
      ),
    )
        .then((_) {
      // Recarregar após voltar da tela de avaliação
      _loadPendingRatings();
    });
  }

  void _showPendingRatingsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Avaliações Pendentes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: pendingRatings.length,
                itemBuilder: (context, index) {
                  final exchange = pendingRatings[index];
                  final currentUserId =
                      fb.FirebaseAuth.instance.currentUser?.uid;
                  final otherUserName = exchange.proposerId == currentUserId
                      ? exchange.receiverName
                      : exchange.proposerName;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                        Text(
                          'Troca com $otherUserName',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToRating(exchange);
                            },
                            icon: const Icon(Icons.star, size: 18),
                            label: const Text('Avaliar agora'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || !isVisible || pendingRatings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade100, Colors.amber.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber.shade700, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pendingRatings.length == 1
                          ? 'Você tem 1 avaliação pendente'
                          : 'Você tem ${pendingRatings.length} avaliações pendentes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Avalie suas trocas concluídas para ajudar outros usuários!',
                      style: TextStyle(
                        color: Colors.amber.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _dismissNotification,
                icon: Icon(Icons.close, color: Colors.amber.shade700),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _showPendingRatingsList,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.amber.shade700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Ver todas',
                    style: TextStyle(color: Colors.amber.shade700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _navigateToRating(pendingRatings.first),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Avaliar agora'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
