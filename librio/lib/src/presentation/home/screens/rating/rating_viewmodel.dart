import 'package:flutter/material.dart';
import 'package:librio/src/domain/usecases/create_rating_usecase.dart';
import 'package:librio/src/domain/usecases/get_user_profile_usecase.dart';
import 'package:librio/src/domain/entities/user_profile.dart';
import 'package:librio/src/data/repositories/rating_repository_impl.dart';

class RatingViewModel extends ChangeNotifier {
  final CreateRatingUseCase _createRatingUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;

  bool isLoading = false;
  bool isLoadingUserProfile = false;
  String? error;
  UserProfile? evaluatedUserProfile;

  RatingViewModel(this._createRatingUseCase,
      {GetUserProfileUseCase? getUserProfileUseCase})
      : _getUserProfileUseCase = getUserProfileUseCase ??
            GetUserProfileUseCase(RatingRepositoryImpl());

  Future<void> loadUserProfile(String userId) async {
    isLoadingUserProfile = true;
    notifyListeners();

    try {
      evaluatedUserProfile = await _getUserProfileUseCase.execute(userId);
    } catch (e) {
      error = 'Erro ao carregar perfil do usuário: $e';
    } finally {
      isLoadingUserProfile = false;
      notifyListeners();
    }
  }

  Future<void> createRating({
    required String exchangeId,
    required String evaluatorId,
    required String evaluatedId,
    required int stars,
    required String message,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _createRatingUseCase.execute(
        exchangeId: exchangeId,
        evaluatorId: evaluatorId,
        evaluatedId: evaluatedId,
        stars: stars,
        message: message,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
