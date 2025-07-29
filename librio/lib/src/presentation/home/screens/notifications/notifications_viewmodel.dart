import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/presentation/presentation.dart';

mixin NotificationsViewModel on ChangeNotifier {
  NotificationsData? get notificationsData;
  bool get isLoading;
  String? get error;

  Future<void> loadNotifications();
  Future<void> refreshNotifications();

  void navigateToRating(BuildContext context, Exchange exchange) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => RatingScreen(exchange: exchange),
          ),
        )
        .then((_) => loadNotifications());
  }

  void navigateToExchangeDetails(BuildContext context, Exchange exchange) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ExchangeDetailsScreen(exchange: exchange),
          ),
        )
        .then((_) => loadNotifications());
  }

  Future<void> startChatAfterAccepted(
      BuildContext context, Exchange exchange) async {
    try {
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await ChatHelper.startChatWith(
        context,
        exchange.receiverId,
        currentUser.uid,
        forceStart: true,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar conversa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class NotificationsViewModelImpl extends ChangeNotifier
    with NotificationsViewModel {
  late NotificationsLoadingManager _loadingManager;
  NotificationsData? _notificationsData;
  bool _isLoading = false;
  String? _error;

  @override
  NotificationsData? get notificationsData => _notificationsData;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  NotificationsViewModelImpl() {
    _loadingManager = NotificationsLoadingManager();
    loadNotifications();
  }

  @override
  Future<void> loadNotifications() async {
    _setLoading(true);
    _clearError();

    try {
      _notificationsData = await _loadingManager.loadNotifications();
    } catch (e) {
      _setError('Erro ao carregar notificações: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
