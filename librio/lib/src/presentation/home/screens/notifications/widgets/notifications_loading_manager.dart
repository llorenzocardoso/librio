import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/data/data.dart';

class NotificationsLoadingManager {
  late GetPendingRatingsUseCase _getPendingRatingsUseCase;
  late GetPendingExchangesUseCase _getPendingExchangesUseCase;
  late GetRecentAcceptedExchangesUseCase _getRecentAcceptedExchangesUseCase;
  late GetUserExchangesUseCase _getUserExchangesUseCase;
  late NotificationService _notificationService;

  NotificationsLoadingManager() {
    _getPendingRatingsUseCase = GetPendingRatingsUseCase(
      ExchangeRepositoryImpl(),
      RatingRepositoryImpl(),
    );
    _getPendingExchangesUseCase = GetPendingExchangesUseCase(
      ExchangeRepositoryImpl(),
    );
    _getRecentAcceptedExchangesUseCase = GetRecentAcceptedExchangesUseCase(
      ExchangeRepositoryImpl(),
    );
    _getUserExchangesUseCase =
        GetUserExchangesUseCase(ExchangeRepositoryImpl());
    _notificationService = NotificationService();
  }

  Future<NotificationsData> loadNotifications() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      return NotificationsData.empty();
    }

    try {
      final viewedExchangeIds =
          await _notificationService.getViewedExchangeIds();
      final lastViewedTime = await _notificationService.getLastViewedTime();

      final pending = await _getPendingRatingsUseCase.execute(user.uid);

      final pendingProposals =
          await _getPendingExchangesUseCase.execute(user.uid);

      final acceptedProposals =
          await _getRecentAcceptedExchangesUseCase.execute(user.uid);

      final unviewedPendingExchanges = pendingProposals
          .where((exchange) => !viewedExchangeIds.contains(exchange.id))
          .toList();

      final unviewedAcceptedExchanges = acceptedProposals
          .where((exchange) =>
              !viewedExchangeIds.contains(exchange.id) &&
              (lastViewedTime == null ||
                  (exchange.updatedAt?.isAfter(lastViewedTime) ?? false)))
          .toList();

      final allExchanges = await _getUserExchangesUseCase.execute(user.uid);
      final recent = _filterRecentExchanges(
        allExchanges,
        unviewedPendingExchanges,
        unviewedAcceptedExchanges,
      );

      final allCurrentNotificationIds = [
        ...unviewedPendingExchanges.map((e) => e.id),
        ...unviewedAcceptedExchanges.map((e) => e.id),
      ];

      if (allCurrentNotificationIds.isNotEmpty) {
        await _notificationService
            .markExchangesAsViewed(allCurrentNotificationIds);
      }

      return NotificationsData(
        pendingRatings: pending,
        pendingExchanges: unviewedPendingExchanges,
        recentAcceptedExchanges: unviewedAcceptedExchanges,
        recentExchanges: recent,
      );
    } catch (e) {
      return NotificationsData.empty();
    }
  }

  List<Exchange> _filterRecentExchanges(
    List<Exchange> allExchanges,
    List<Exchange> unviewedPendingExchanges,
    List<Exchange> unviewedAcceptedExchanges,
  ) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final oneDayAgo = now.subtract(const Duration(hours: 24));

    final recent = allExchanges.where((exchange) {
      final isAlreadyShown =
          unviewedPendingExchanges.any((e) => e.id == exchange.id) ||
              unviewedAcceptedExchanges.any((e) => e.id == exchange.id);

      return !isAlreadyShown &&
          exchange.createdAt.isAfter(sevenDaysAgo) &&
          (exchange.status == ExchangeStatus.accepted ||
              exchange.status == ExchangeStatus.completed ||
              exchange.status == ExchangeStatus.rejected) &&
          !(exchange.status == ExchangeStatus.accepted &&
              exchange.updatedAt != null &&
              exchange.updatedAt!.isAfter(oneDayAgo));
    }).toList();

    recent.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return recent;
  }
}

class NotificationsData {
  final List<Exchange> pendingRatings;
  final List<Exchange> pendingExchanges;
  final List<Exchange> recentAcceptedExchanges;
  final List<Exchange> recentExchanges;

  NotificationsData({
    required this.pendingRatings,
    required this.pendingExchanges,
    required this.recentAcceptedExchanges,
    required this.recentExchanges,
  });

  factory NotificationsData.empty() {
    return NotificationsData(
      pendingRatings: [],
      pendingExchanges: [],
      recentAcceptedExchanges: [],
      recentExchanges: [],
    );
  }

  bool get hasNotifications =>
      pendingRatings.isNotEmpty ||
      pendingExchanges.isNotEmpty ||
      recentAcceptedExchanges.isNotEmpty ||
      recentExchanges.isNotEmpty;
}
