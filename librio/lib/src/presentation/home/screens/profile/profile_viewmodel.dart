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
  List<Rating> get ratingsWithComments =>
      ratings.where((rating) => rating.message.trim().isNotEmpty).toList();
  bool get isLoading => BookDataManager().isLoading;
  bool isLoadingProfile = false;
  bool isUploadingPhoto = false;
  String? get error => BookDataManager().error;

  Future<void> fetchUserBooks();
  Future<void> fetchUserProfile();
  Future<void> updateProfilePhoto(BuildContext context);
  Future<void> refresh();

  void navigateToBookDetails(BuildContext context, Book book) {
    context.push(AppRoutes.bookDetails, extra: book);
  }

  void navigateToEditProfile(BuildContext context) async {
    await context.push(AppRoutes.editProfile);

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
            GetUserProfileUseCase(UserProfileRepositoryImpl()),
        _getUserRatingsUseCase = getUserRatingsUseCase ??
            GetUserRatingsUseCase(RatingRepositoryImpl()),
        _updateUserProfileUseCase = updateUserProfileUseCase ??
            UpdateUserProfileUseCase(UserProfileRepositoryImpl()),
        _storageService = storageService ?? StorageService(),
        _imagePickerService = imagePickerService ?? ImagePickerService() {
    _bookDataManager.addListener(_onBooksDataChanged);
    UserProfileManager().addListener(_onProfileDataChanged);
  }

  void _onBooksDataChanged() {
    notifyListeners();
  }

  void _onProfileDataChanged() {
    fetchUserProfile();
  }

  @override
  void dispose() {
    _bookDataManager.removeListener(_onBooksDataChanged);
    UserProfileManager().removeListener(_onProfileDataChanged);
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
      final File? imageFile = await _imagePickerService.pickImage(context);
      if (imageFile == null) return;

      isUploadingPhoto = true;
      notifyListeners();

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

      await _updateUserProfileUseCase.execute(
        userId: user.uid,
        photoUrl: imageUrl,
      );

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

  Future<void> refreshUserProfile() async {
    await fetchUserProfile();
  }

  @override
  Future<void> refresh() async {
    await Future.wait([
      fetchUserBooks(),
      fetchUserProfile(),
    ]);
  }
}
