import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../domain/entities/message.dart';
import '../../../../domain/usecases/get_chat_messages_usecase.dart';
import '../../../../domain/usecases/send_message_usecase.dart';
import '../../../../domain/usecases/mark_chat_as_read_usecase.dart';
import '../../../../domain/usecases/get_user_by_id_usecase.dart';
import '../../../../domain/usecases/get_chat_usecase.dart';
import '../../../../data/repositories/chat_repository_impl.dart';
import 'dart:async';

class ChatViewModel extends ChangeNotifier {
  final String chatId;
  final GetChatMessagesUseCase _getChatMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final MarkChatAsReadUseCase _markChatAsReadUseCase;
  final GetUserByIdUseCase _getUserByIdUseCase;
  final GetChatUseCase _getChatUseCase;

  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isLoadingUserInfo = false;
  String? _error;
  StreamSubscription? _messagesSubscription;

  String? _otherUserId;
  String? _otherUserName;
  String? _otherUserPhotoUrl;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isLoadingUserInfo => _isLoadingUserInfo;
  String? get error => _error;
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';
  String? get otherUserId => _otherUserId;
  String? get otherUserName => _otherUserName;
  String? get otherUserPhotoUrl => _otherUserPhotoUrl;

  ChatViewModel(this.chatId)
      : _getChatMessagesUseCase = GetChatMessagesUseCase(ChatRepositoryImpl()),
        _sendMessageUseCase = SendMessageUseCase(ChatRepositoryImpl()),
        _markChatAsReadUseCase = MarkChatAsReadUseCase(ChatRepositoryImpl()),
        _getUserByIdUseCase = GetUserByIdUseCase(),
        _getChatUseCase = GetChatUseCase(ChatRepositoryImpl());

  void loadMessages() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _loadChatInfo();

    _messagesSubscription?.cancel();
    _messagesSubscription = _getChatMessagesUseCase(chatId).listen(
      (messages) {
        _messages = messages;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Erro ao carregar mensagens: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _loadChatInfo() async {
    try {
      final chat = await _getChatUseCase.execute(chatId);
      if (chat != null) {
        final currentUser = currentUserId;
        _otherUserId = chat.participantIds.firstWhere(
          (id) => id != currentUser,
          orElse: () => '',
        );

        if (_otherUserId != null && _otherUserId!.isNotEmpty) {
          final otherUserInfo = chat.participantInfo[_otherUserId];
          if (otherUserInfo != null) {
            _otherUserName = otherUserInfo['name'];
            _otherUserPhotoUrl = otherUserInfo['photoUrl'];
            notifyListeners();
          } else {
            _loadOtherUserInfo();
          }
        }
      }
    } catch (e) {
      throw Exception('Erro ao carregar informações do chat: $e');
    }
  }

  Future<void> _loadOtherUserInfo() async {
    if (_otherUserId == null) return;

    _isLoadingUserInfo = true;
    notifyListeners();

    try {
      final userData = await _getUserByIdUseCase.execute(_otherUserId!);
      if (userData != null) {
        _otherUserName = userData['name'] ?? 'Usuário';
        _otherUserPhotoUrl = userData['photoUrl'];
      }
    } catch (e) {
      throw Exception('Erro ao carregar informações do usuário: $e');
    } finally {
      _isLoadingUserInfo = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final message = Message(
      id: '',
      chatId: chatId,
      senderId: currentUserId,
      content: content.trim(),
      type: MessageType.text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    try {
      await _sendMessageUseCase(message);
    } catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }

  Future<void> markAsRead() async {
    try {
      await _markChatAsReadUseCase(chatId, currentUserId);
    } catch (error) {
      throw Exception('Erro ao marcar como lido: $error');
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
