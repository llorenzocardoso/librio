import 'package:flutter/material.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/presentation/presentation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class ExchangeDetailsScreen extends StatefulWidget {
  final Exchange exchange;

  const ExchangeDetailsScreen({
    Key? key,
    required this.exchange,
  }) : super(key: key);

  @override
  State<ExchangeDetailsScreen> createState() => _ExchangeDetailsScreenState();
}

class _ExchangeDetailsScreenState extends State<ExchangeDetailsScreen> {
  late ExchangeDetailsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ExchangeDetailsViewModel();
    viewModel.addListener(() => setState(() {}));

    if (widget.exchange.status == ExchangeStatus.completed) {
      viewModel.checkIfUserHasRated(widget.exchange.id);
    }
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _startChat(Exchange exchange) async {
    try {
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Determinar o ID do outro usuário
      final otherUserId = currentUser.uid == exchange.proposerId
          ? exchange.receiverId
          : exchange.proposerId;

      // Navegar para o chat
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

  @override
  Widget build(BuildContext context) {
    final exchange = widget.exchange;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => viewModel.navigateBack(context),
        ),
        title: const Text(
          'Detalhes da troca',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com status usando widget modular
            ExchangeHeader(exchange: exchange),

            const SizedBox(height: 24),

            // Livros da troca
            const Text(
              'Livros da troca',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                ExchangeBookCard(
                  title: exchange.proposerBookTitle,
                  author: exchange.proposerBookAuthor,
                  imageUrl: exchange.proposerBookImageUrl,
                  genre: exchange.proposerBookGenre,
                  condition: exchange.proposerBookCondition,
                  label: 'Livro oferecido',
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF176FF1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                ExchangeBookCard(
                  title: exchange.receiverBookTitle,
                  author: exchange.receiverBookAuthor,
                  imageUrl: exchange.receiverBookImageUrl,
                  genre: exchange.receiverBookGenre,
                  condition: exchange.receiverBookCondition,
                  label: 'Livro desejado',
                ),
              ],
            ),

            // Mensagem se houver
            const SizedBox(height: 24),
            ExchangeMessageSection(exchange: exchange),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        exchange: exchange,
        viewModel: viewModel,
        context: context,
      ),
    );
  }
}
