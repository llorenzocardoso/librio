import 'package:flutter/material.dart';
import 'package:librio/src/domain/entities/user_profile.dart';
import 'package:librio/src/domain/entities/rating.dart';
import 'package:librio/src/domain/usecases/get_user_profile_usecase.dart';
import 'package:librio/src/domain/usecases/get_user_ratings_usecase.dart';
import 'package:librio/src/data/repositories/rating_repository_impl.dart';

class UserProfileViewModel extends ChangeNotifier {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final GetUserRatingsUseCase _getUserRatingsUseCase;

  UserProfile? _userProfile;
  List<Rating> _ratings = [];
  bool _isLoading = false;
  String? _error;

  UserProfileViewModel({
    GetUserProfileUseCase? getUserProfileUseCase,
    GetUserRatingsUseCase? getUserRatingsUseCase,
  })  : _getUserProfileUseCase = getUserProfileUseCase ??
            GetUserProfileUseCase(RatingRepositoryImpl()),
        _getUserRatingsUseCase = getUserRatingsUseCase ??
            GetUserRatingsUseCase(RatingRepositoryImpl());

  UserProfile? get userProfile => _userProfile;
  List<Rating> get ratings => _ratings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userProfile = await _getUserProfileUseCase.execute(userId);
      _ratings = await _getUserRatingsUseCase.execute(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
