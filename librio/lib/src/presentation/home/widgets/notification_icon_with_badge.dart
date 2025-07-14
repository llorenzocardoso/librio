import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/data/data.dart';

class NotificationIconWithBadge extends StatefulWidget {
  final VoidCallback onPressed;

  const NotificationIconWithBadge({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<NotificationIconWithBadge> createState() =>
      _NotificationIconWithBadgeState();
}

class _NotificationIconWithBadgeState extends State<NotificationIconWithBadge>
    with AutomaticKeepAliveClientMixin {
  late GetPendingRatingsUseCase _getPendingRatingsUseCase;
  late GetPendingExchangesUseCase _getPendingExchangesUseCase;
  late GetRecentAcceptedExchangesUseCase _getRecentAcceptedExchangesUseCase;
  late NotificationService _notificationService;
  int totalNotificationCount = 0;
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
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
    _notificationService = NotificationService();
    _loadNotificationCount();
  }

  @override
  void didUpdateWidget(NotificationIconWithBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      return;
    }

    try {
      final viewedExchangeIds =
          await _notificationService.getViewedExchangeIds();
      final lastViewedTime = await _notificationService.getLastViewedTime();

      final pendingRatings = await _getPendingRatingsUseCase.execute(user.uid);

      final pendingExchanges =
          await _getPendingExchangesUseCase.execute(user.uid);

      final recentAcceptedExchanges =
          await _getRecentAcceptedExchangesUseCase.execute(user.uid);

      final unviewedPendingExchanges = pendingExchanges
          .where((exchange) => !viewedExchangeIds.contains(exchange.id))
          .toList();

      final unviewedAcceptedExchanges = recentAcceptedExchanges
          .where((exchange) =>
              !viewedExchangeIds.contains(exchange.id) &&
              (lastViewedTime == null ||
                  (exchange.updatedAt?.isAfter(lastViewedTime) ?? false)))
          .toList();

      final unviewedRatings = pendingRatings;

      if (mounted) {
        setState(() {
          totalNotificationCount = unviewedRatings.length +
              unviewedPendingExchanges.length +
              unviewedAcceptedExchanges.length;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void refresh() {
    if (mounted) {
      _loadNotificationCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/notification_icon.svg',
            width: 32,
            height: 32,
          ),
          onPressed: () {
            widget.onPressed();
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _loadNotificationCount();
              }
            });
          },
        ),
        if (!isLoading && totalNotificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                totalNotificationCount > 99
                    ? '99+'
                    : totalNotificationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
