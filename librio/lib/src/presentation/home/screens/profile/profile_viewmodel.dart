import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/routes/routes.dart';
import 'package:librio/src/data/repositories/rating_repository_impl.dart';

mixin ProfileViewModel on ChangeNotifier {
  List<Book> books = [];
  UserProfile? userProfile;
  List<Rating> ratings = [];
  bool isLoading = false;
  bool isLoadingProfile = false;
  String? error;

  Future<void> fetchUserBooks();
  Future<void> fetchUserProfile();

  void navigateToBookDetails(BuildContext context, Book book) {
    context.push(AppRoutes.bookDetails, extra: book);
  }

  void navigateToEditProfile(BuildContext context) async {
    await context.push(AppRoutes.editProfile);
    // Recarregar perfil quando voltar da tela de edição
    fetchUserProfile();
  }

  void navigateBack(BuildContext context) {
    context.pop();
  }

  void navigateToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }
}

class ProfileViewModelImpl extends ChangeNotifier with ProfileViewModel {
  final GetUserBooksUseCase _getUserBooksUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;
  final GetUserRatingsUseCase _getUserRatingsUseCase;

  ProfileViewModelImpl(
    this._getUserBooksUseCase, {
    GetUserProfileUseCase? getUserProfileUseCase,
    GetUserRatingsUseCase? getUserRatingsUseCase,
  })  : _getUserProfileUseCase = getUserProfileUseCase ??
            GetUserProfileUseCase(RatingRepositoryImpl()),
        _getUserRatingsUseCase = getUserRatingsUseCase ??
            GetUserRatingsUseCase(RatingRepositoryImpl());

  @override
  Future<void> fetchUserBooks() async {
    final fb.User? user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      error = 'Usuário não autenticado';
      notifyListeners();
      return;
    }
    isLoading = true;
    notifyListeners();
    try {
      books = await _getUserBooksUseCase.execute(user.uid);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> fetchUserProfile() async {
    final fb.User? user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      error = 'Usuário não autenticado';
      notifyListeners();
      return;
    }

    isLoadingProfile = true;
    notifyListeners();

    try {
      userProfile = await _getUserProfileUseCase.execute(user.uid);
      ratings = await _getUserRatingsUseCase.execute(user.uid);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoadingProfile = false;
      notifyListeners();
    }
  }
}
