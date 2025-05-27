import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/data/data.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/routes/routes.dart';
import 'package:librio/src/presentation/presentation.dart';

class ExchangeRequestsViewModel extends ChangeNotifier {
  late GetUserExchangesUseCase _getUserExchangesUseCase;
  late ConfirmExchangeCompletionUseCase _confirmExchangeCompletionUseCase;

  List<Exchange> allExchanges = [];
  List<Exchange> pendingExchanges = [];
  List<Exchange> ongoingExchanges = [];
  List<Exchange> acceptedExchanges = [];
  List<Exchange> rejectedExchanges = [];

  bool isLoading = true;
  String? error;

  ExchangeRequestsViewModel() {
    _getUserExchangesUseCase =
        GetUserExchangesUseCase(ExchangeRepositoryImpl());
    _confirmExchangeCompletionUseCase =
        ConfirmExchangeCompletionUseCase(ExchangeRepositoryImpl());
  }

  Future<void> loadExchanges() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userExchanges = await _getUserExchangesUseCase.execute(user.uid);

      // Incluir TODAS as trocas onde o usuário é proposer OU receiver
      allExchanges = userExchanges;

      // Pendente: propostas recebidas (receiver) + propostas enviadas (proposer) que estão pendentes
      pendingExchanges = userExchanges
          .where((e) => e.status == ExchangeStatus.pending)
          .toList();

      // Em Andamento: trocas aceitas onde o usuário é proposer OU receiver
      ongoingExchanges = userExchanges
          .where((exchange) => exchange.status == ExchangeStatus.accepted)
          .toList();

      // Aceita: trocas aceitas onde o usuário é proposer OU receiver
      acceptedExchanges = userExchanges
          .where((e) => e.status == ExchangeStatus.accepted)
          .toList();

      // Recusada: propostas rejeitadas onde o usuário é proposer OU receiver
      rejectedExchanges = userExchanges
          .where((e) => e.status == ExchangeStatus.rejected)
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExchangeStatus(
      String exchangeId, ExchangeStatus status, BuildContext context) async {
    try {
      final repository = ExchangeRepositoryImpl();
      await repository.updateExchangeStatus(exchangeId, status);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == ExchangeStatus.accepted
                ? 'Proposta aceita com sucesso!'
                : 'Proposta recusada',
          ),
          backgroundColor:
              status == ExchangeStatus.accepted ? Colors.green : Colors.red,
        ),
      );

      // Recarregar as trocas
      await loadExchanges();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void navigateToExchangeDetails(BuildContext context, Exchange exchange) {
    context.push(AppRoutes.exchangeDetails, extra: exchange);
  }

  void navigateToExchangeHistory(BuildContext context) {
    context.push(AppRoutes.exchangeHistory);
  }

  void navigateBack(BuildContext context) {
    context.pop();
  }

  String? getCurrentUserId() {
    return fb.FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> markAsCompleted(
      String exchangeId, BuildContext context, Exchange exchange) async {
    final currentUserId = getCurrentUserId();
    if (currentUserId == null) return;

    try {
      await _confirmExchangeCompletionUseCase.execute(
          exchangeId, currentUserId);

      // Verificar se ambos confirmaram
      final updatedExchange =
          await ExchangeRepositoryImpl().getExchangeById(exchangeId);
      final bothConfirmed = updatedExchange?.status == ExchangeStatus.completed;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bothConfirmed
                ? 'Troca concluída! Ambos confirmaram.'
                : 'Sua confirmação foi registrada. Aguardando confirmação do outro usuário.',
          ),
          backgroundColor: bothConfirmed ? Colors.green : Colors.orange,
        ),
      );

      // Mostrar modal de avaliação apenas se ambos confirmaram
      if (bothConfirmed) {
        _showRatingModal(context, exchange);
      }

      // Recarregar as trocas
      await loadExchanges();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRatingModal(BuildContext context, Exchange exchange) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Troca Concluída!'),
          content: const Text(
              'Agora você pode avaliar como foi a experiência da troca.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Avaliar depois'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToRating(context, exchange);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              child: const Text('Avaliar agora',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToRating(BuildContext context, Exchange exchange) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RatingScreen(exchange: exchange),
      ),
    );
  }
}
