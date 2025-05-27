import 'package:flutter/material.dart';
import 'package:librio/src/domain/usecases/create_rating_usecase.dart';

class RatingViewModel extends ChangeNotifier {
  final CreateRatingUseCase _createRatingUseCase;

  bool isLoading = false;
  String? error;

  RatingViewModel(this._createRatingUseCase);

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
