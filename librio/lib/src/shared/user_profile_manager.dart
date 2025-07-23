import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../domain/domain.dart';
import '../data/data.dart';
import '../data/repositories/user_profile_repository_impl.dart';

class UserProfileManager extends ChangeNotifier {
  static final UserProfileManager _instance = UserProfileManager._internal();
  factory UserProfileManager() => _instance;
  UserProfileManager._internal();

  final GetUserProfileUseCase _getUserProfileUseCase =
      GetUserProfileUseCase(UserProfileRepositoryImpl());

  UserProfile? _currentUserProfile;
  bool _isLoading = false;

  UserProfile? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;

  Future<void> refreshCurrentUserProfile() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentUserProfile = await _getUserProfileUseCase.execute(user.uid);
    } catch (e) {
      _currentUserProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void notifyProfileChanged() {
    refreshCurrentUserProfile();
  }

  void clearProfile() {
    _currentUserProfile = null;
    notifyListeners();
  }
}
