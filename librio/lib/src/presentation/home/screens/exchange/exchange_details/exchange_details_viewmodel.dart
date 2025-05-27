import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/data/data.dart';
import 'package:librio/src/presentation/presentation.dart';

class ExchangeDetailsViewModel extends ChangeNotifier {
  final CheckRatingExistsUseCase _checkRatingExistsUseCase;
  final ConfirmExchangeCompletionUseCase _confirmExchangeCompletionUseCase;

  bool isLoading = false;
  String? error;
  bool _hasRated = false;
  bool _isCheckingRating = false;

  ExchangeDetailsViewModel({
    CheckRatingExistsUseCase? checkRatingExistsUseCase,
    ConfirmExchangeCompletionUseCase? confirmExchangeCompletionUseCase,
  })  : _checkRatingExistsUseCase = checkRatingExistsUseCase ??
            CheckRatingExistsUseCase(RatingRepositoryImpl()),
        _confirmExchangeCompletionUseCase = confirmExchangeCompletionUseCase ??
            ConfirmExchangeCompletionUseCase(ExchangeRepositoryImpl());

  bool get hasRated => _hasRated;
  bool get isCheckingRating => _isCheckingRating;

  Future<void> acceptExchange(String exchangeId, BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final repository = ExchangeRepositoryImpl();
      await repository.updateExchangeStatus(
          exchangeId, ExchangeStatus.accepted);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proposta aceita com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      navigateBack(context);
    } catch (e) {
      error = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void navigateBack(BuildContext context) {
    context.pop();
  }

  bool isReceiver(Exchange exchange) {
    final currentUser = fb.FirebaseAuth.instance.currentUser;
    return exchange.receiverId == currentUser?.uid;
  }

  Future<void> markAsCompleted(
      String exchangeId, BuildContext context, Exchange exchange) async {
    final currentUser = fb.FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    isLoading = true;
    notifyListeners();

    try {
      await _confirmExchangeCompletionUseCase.execute(
          exchangeId, currentUser.uid);

      // Verificar se ambos confirmaram
      final repository = ExchangeRepositoryImpl();
      final updatedExchange = await repository.getExchangeById(exchangeId);
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
      } else {
        navigateBack(context);
      }
    } catch (e) {
      error = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
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
                navigateBack(context);
              },
              child: const Text('Avaliar depois'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                navigateToRating(context, exchange);
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

  Future<void> checkIfUserHasRated(String exchangeId) async {
    final currentUser = fb.FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _isCheckingRating = true;
    notifyListeners();

    try {
      _hasRated =
          await _checkRatingExistsUseCase.execute(exchangeId, currentUser.uid);
    } catch (e) {
      error = e.toString();
    } finally {
      _isCheckingRating = false;
      notifyListeners();
    }
  }

  void navigateToRating(BuildContext context, Exchange exchange) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => RatingScreen(exchange: exchange),
      ),
    )
        .then((_) {
      // Verificar novamente se o usuário avaliou após voltar da tela de avaliação
      checkIfUserHasRated(exchange.id);
    });
  }
}
