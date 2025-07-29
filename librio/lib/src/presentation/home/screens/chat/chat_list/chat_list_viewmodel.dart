import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:librio/src/data/data.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/routes/routes.dart';

import 'dart:async';

class ChatListViewModel extends ChangeNotifier {
  final GetUserChatsUseCase _getUserChatsUseCase;
  List<Chat> _chats = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _chatsSubscription;

  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  ChatListViewModel()
      : _getUserChatsUseCase = GetUserChatsUseCase(ChatRepositoryImpl());

  void loadChats() {
    final userId = currentUserId;
    if (userId.isEmpty) {
      _error = 'Usuário não autenticado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    _chatsSubscription?.cancel();
    _chatsSubscription = _getUserChatsUseCase(userId).listen(
      (chats) {
        _chats = chats;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Erro ao carregar conversas: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void navigateHome(BuildContext context) {
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    super.dispose();
  }
}
