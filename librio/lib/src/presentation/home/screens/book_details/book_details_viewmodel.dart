import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:go_router/go_router.dart';
import 'package:librio/src/data/data.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/routes/routes.dart';

class BookDetailsViewModel extends ChangeNotifier {
  final GetUserProfileUseCase _getUserProfileUseCase;

  Book? _book;
  UserProfile? _ownerProfile;
  bool _isLoadingOwner = false;
  String? _error;

  BookDetailsViewModel({GetUserProfileUseCase? getUserProfileUseCase})
      : _getUserProfileUseCase = getUserProfileUseCase ??
            GetUserProfileUseCase(RatingRepositoryImpl());

  Book? get book => _book;
  UserProfile? get ownerProfile => _ownerProfile;
  bool get isLoadingOwner => _isLoadingOwner;
  String? get error => _error;

  void setBook(Book book) {
    _book = book;
    _loadOwnerProfile();
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
}
