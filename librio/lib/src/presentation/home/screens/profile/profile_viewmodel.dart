import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/routes/routes.dart';
import 'package:librio/src/data/repositories/rating_repository_impl.dart';
import 'package:librio/src/data/repositories/user_profile_repository_impl.dart';
import 'package:librio/src/data/datasources/datasources.dart';
import 'package:librio/src/shared/shared.dart';

mixin ProfileViewModel on ChangeNotifier {
  List<Book> get books => BookDataManager().userBooks;
  UserProfile? userProfile;
  List<Rating> ratings = [];
  List<Rating> get ratingsWithComments => ratings.where((rating) => rating.message.trim().isNotEmpty).toList();
  bool get isLoading => BookDataManager().isLoading;
  bool isLoadingProfile = false;
  bool isUploadingPhoto = false;
  String? get error => BookDataManager().error;

  Future<void> fetchUserBooks();
  Future<void> fetchUserProfile();
  Future<void> updateProfilePhoto(BuildContext context);

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
  final BookDataManager _bookDataManager = BookDataManager();
  final GetUserProfileUseCase _getUserProfileUseCase;
  final GetUserRatingsUseCase _getUserRatingsUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final StorageService _storageService;
  final ImagePickerService _imagePickerService;
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  ProfileViewModelImpl(
    GetUserBooksUseCase getUserBooksUseCase, {
    GetUserProfileUseCase? getUserProfileUseCase,
    GetUserRatingsUseCase? getUserRatingsUseCase,
    UpdateUserProfileUseCase? updateUserProfileUseCase,
    StorageService? storageService,
    ImagePickerService? imagePickerService,
  })  : _getUserProfileUseCase = getUserProfileUseCase ??
            GetUserProfileUseCase(RatingRepositoryImpl()),
        _getUserRatingsUseCase = getUserRatingsUseCase ??
            GetUserRatingsUseCase(RatingRepositoryImpl()),
        _updateUserProfileUseCase = updateUserProfileUseCase ??
            UpdateUserProfileUseCase(UserProfileRepositoryImpl()),
        _storageService = storageService ?? StorageService(),
        _imagePickerService = imagePickerService ?? ImagePickerService() {
    _bookDataManager.addListener(_onBooksDataChanged);
  }

  void _onBooksDataChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _bookDataManager.removeListener(_onBooksDataChanged);
    super.dispose();
  }

  @override
  Future<void> fetchUserBooks() async {
    await _bookDataManager.loadUserBooks();
  }

  @override
  Future<void> fetchUserProfile() async {
    final fb.User? user = _auth.currentUser;
    if (user == null) {
      // Error está sendo gerenciado pelo BookDataManager
      notifyListeners();
      return;
    }

    isLoadingProfile = true;
    notifyListeners();

    try {
      userProfile = await _getUserProfileUseCase.execute(user.uid);
      ratings = await _getUserRatingsUseCase.execute(user.uid);
    } catch (e) {
      userProfile = null;
      ratings = [];
    } finally {
      isLoadingProfile = false;
      notifyListeners();
    }
  }

  @override
  Future<void> updateProfilePhoto(BuildContext context) async {
    final fb.User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // Mostrar picker de imagem
      final File? imageFile = await _imagePickerService.pickImage(context);
      if (imageFile == null) return;

      isUploadingPhoto = true;
      notifyListeners();

      // Fazer upload da imagem para o Storage
      final String? imageUrl =
          await _storageService.uploadProfileImage(imageFile);

      if (imageUrl == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao fazer upload da imagem')),
          );
        }
        return;
      }

      // Atualizar perfil com a nova foto
      await _updateUserProfileUseCase.execute(
        userId: user.uid,
        photoUrl: imageUrl,
      );

      // Recarregar perfil para mostrar a nova foto
      await fetchUserProfile();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto atualizada com sucesso!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      isUploadingPhoto = false;
      notifyListeners();
    }
  }

  // Método para recarregar o perfil (útil quando exchangeCount pode ter mudado)
  Future<void> refreshUserProfile() async {
    await fetchUserProfile();
  }
}
