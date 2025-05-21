import 'dart:async';
import 'package:flutter/foundation.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  final Stream _stream;
  late final StreamSubscription _subscription;

  GoRouterRefreshStream(this._stream) {
    _subscription =
        _stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
