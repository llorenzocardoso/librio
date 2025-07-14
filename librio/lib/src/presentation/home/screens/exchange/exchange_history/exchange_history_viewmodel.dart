import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/data/data.dart';
import 'package:librio/src/presentation/presentation.dart';

class ExchangeHistoryViewModel extends ChangeNotifier {
  late GetUserExchangesUseCase _getUserExchangesUseCase;
  late CheckRatingExistsUseCase _checkRatingExistsUseCase;
  late GetUserProfileUseCase _getUserProfileUseCase;

  List<Exchange> exchanges = [];
  bool isLoading = true;
  String? error;
  final Map<String, bool> _ratingStatus = {}; // exchangeId -> hasRated
  final Map<String, UserProfile> _userProfiles = {}; // userId -> UserProfile

  ExchangeHistoryViewModel() {
    _getUserExchangesUseCase =
        GetUserExchangesUseCase(ExchangeRepositoryImpl());
    _checkRatingExistsUseCase =
        CheckRatingExistsUseCase(RatingRepositoryImpl());
    _getUserProfileUseCase = GetUserProfileUseCase(RatingRepositoryImpl());
  }

  // Buscar perfil do usuário (com cache)
  UserProfile? getUserProfile(String userId) {
    return _userProfiles[userId];
  }

  Future<void> loadExchanges() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userExchanges = await _getUserExchangesUseCase.execute(user.uid);
      exchanges = userExchanges;

      // Buscar perfis dos usuários envolvidos nas trocas
      await _loadUserProfiles();

      // Verificar status de avaliação para trocas concluídas
      await _checkRatingStatusForCompletedExchanges(user.uid);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfiles() async {
    final userIds = <String>{};

    // Coletar todos os IDs únicos de usuários
    for (final exchange in exchanges) {
      userIds.add(exchange.proposerId);
      userIds.add(exchange.receiverId);
    }

    // Buscar perfis em paralelo
    final futures = userIds.map((userId) async {
      try {
        final profile = await _getUserProfileUseCase.execute(userId);
        _userProfiles[userId] = profile;
      } catch (e) {
        throw Exception('Erro ao buscar perfil do usuário $userId: $e');
      }
    });

    await Future.wait(futures);
  }

  Future<void> _checkRatingStatusForCompletedExchanges(String userId) async {
    final completedExchanges = exchanges
        .where((exchange) => exchange.status == ExchangeStatus.completed)
        .toList();

    for (final exchange in completedExchanges) {
      try {
        final hasRated =
            await _checkRatingExistsUseCase.execute(exchange.id, userId);
        _ratingStatus[exchange.id] = hasRated;
      } catch (e) {
        _ratingStatus[exchange.id] = false;
      }
    }
  }

  Future<void> refresh() async {
    isLoading = true;
    error = null;
    notifyListeners();
    await loadExchanges();
  }

  void navigateBack(BuildContext context) {
    context.pop();
  }

  String? getCurrentUserId() {
    return fb.FirebaseAuth.instance.currentUser?.uid;
  }

  bool hasUserRated(String exchangeId) {
    return _ratingStatus[exchangeId] ?? false;
  }

  bool canUserRate(Exchange exchange) {
    return exchange.status == ExchangeStatus.completed &&
        !hasUserRated(exchange.id);
  }

  void navigateToRating(BuildContext context, Exchange exchange) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => RatingScreen(exchange: exchange),
      ),
    )
        .then((_) {
      // Recarregar após voltar da tela de avaliação
      refresh();
    });
  }
}
