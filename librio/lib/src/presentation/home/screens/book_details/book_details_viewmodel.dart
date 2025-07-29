import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:go_router/go_router.dart';
import 'package:librio/src/data/data.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/routes/routes.dart';
import 'package:librio/src/data/repositories/user_profile_repository_impl.dart';
import '../chat/chat_helper.dart';

class BookDetailsViewModel extends ChangeNotifier {
  final GetUserProfileUseCase _getUserProfileUseCase;

  Book? _book;
  UserProfile? _ownerProfile;
  bool _isLoadingOwner = false;
  bool _canChat = false;
  bool _isCheckingChat = false;
  String? _error;

  BookDetailsViewModel({GetUserProfileUseCase? getUserProfileUseCase})
      : _getUserProfileUseCase = getUserProfileUseCase ??
            GetUserProfileUseCase(UserProfileRepositoryImpl());

  Book? get book => _book;
  UserProfile? get ownerProfile => _ownerProfile;
  bool get isLoadingOwner => _isLoadingOwner;
  bool get canChat => _canChat;
  bool get isCheckingChat => _isCheckingChat;
  String? get error => _error;

  void setBook(Book book) {
    _book = book;
    _loadOwnerProfile();
    _checkCanChat();
    notifyListeners();
  }

  Future<void> _loadOwnerProfile() async {
    if (_book == null) return;

    _isLoadingOwner = true;
    _error = null;
    notifyListeners();

    try {
      _ownerProfile = await _getUserProfileUseCase.execute(_book!.ownerId);
    } catch (e) {
      _error = e.toString();
      // Tentar buscar informações básicas do Firebase Auth
      String userName = 'Usuário';
      String userEmail = '';
      String userPhotoUrl = '';

      try {
        // Se o usuário atual for o dono do livro, usar dados do Firebase Auth
        final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.uid == _book!.ownerId) {
          userName = currentUser.displayName ??
              currentUser.email?.split('@')[0] ??
              'Usuário';
          userEmail = currentUser.email ?? '';
          userPhotoUrl = currentUser.photoURL ?? '';
        }
      } catch (authError) {
        // Ignorar erros do Firebase Auth
      }

      // Criar um perfil básico com informações disponíveis
      _ownerProfile = UserProfile(
        id: _book!.ownerId,
        name: userName,
        email: userEmail,
        photoUrl: userPhotoUrl,
        description: '',
        averageRating: 0.0,
        ratingCount: 0,
        exchangeCount: 0,
        ratings: [],
      );
    } finally {
      _isLoadingOwner = false;
      notifyListeners();
    }
  }

  bool get isOwnBook {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    return currentUser?.uid == _book?.ownerId;
  }

  void navigateToProposeExchange(BuildContext context) {
    if (_book != null) {
      context.push(AppRoutes.proposeExchange, extra: _book);
    }
  }

  void navigateBack(BuildContext context) {
    context.pop();
  }

  Future<void> _checkCanChat() async {
    if (_book == null) return;

    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid == _book!.ownerId) {
      _canChat = false;
      return;
    }

    _isCheckingChat = true;
    notifyListeners();

    try {
      _canChat = await ChatHelper.canChatWith(currentUser.uid, _book!.ownerId);
    } catch (e) {
      _canChat = false;
    } finally {
      _isCheckingChat = false;
      notifyListeners();
    }
  }
}
