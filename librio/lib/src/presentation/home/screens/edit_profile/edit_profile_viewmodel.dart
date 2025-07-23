import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/entities/user_profile.dart';
import 'package:librio/src/domain/usecases/update_user_profile_usecase.dart';
import 'package:librio/src/data/repositories/user_profile_repository_impl.dart';
import 'package:librio/src/data/datasources/datasources.dart';
import 'package:librio/src/shared/shared.dart';

class EditProfileViewModel extends ChangeNotifier {
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final UserProfileRepositoryImpl _userProfileRepository;
  final StorageService _storageService;
  final ImagePickerService _imagePickerService;

  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _isLoadingProfile = false;
  bool _isUploadingPhoto = false;
  String? _error;

  EditProfileViewModel({
    UpdateUserProfileUseCase? updateUserProfileUseCase,
    UserProfileRepositoryImpl? userProfileRepository,
    StorageService? storageService,
    ImagePickerService? imagePickerService,
  })  : _updateUserProfileUseCase = updateUserProfileUseCase ??
            UpdateUserProfileUseCase(UserProfileRepositoryImpl()),
        _userProfileRepository =
            userProfileRepository ?? UserProfileRepositoryImpl(),
        _storageService = storageService ?? StorageService(),
        _imagePickerService = imagePickerService ?? ImagePickerService() {
    UserProfileManager().addListener(_onProfileDataChanged);
  }

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isUploadingPhoto => _isUploadingPhoto;
  String? get error => _error;

  Future<void> loadCurrentProfile() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoadingProfile = true;
    _error = null;
    notifyListeners();

    try {
      _userProfile = await _userProfileRepository.getUserProfile(user.uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    required String description,
    required BuildContext context,
  }) async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _updateUserProfileUseCase.execute(
        userId: user.uid,
        name: name.isNotEmpty ? name : null,
        description: description.isNotEmpty ? description : null,
      );

      // Notificar o UserProfileManager sobre as mudanças
      UserProfileManager().notifyProfileChanged();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      navigateBack(context);
    } catch (e) {
      _error = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfilePhoto(BuildContext context) async {
    final fb.User? user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final File? imageFile = await _imagePickerService.pickImage(context);
      if (imageFile == null) return;

      _isUploadingPhoto = true;
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

      // Notificar o UserProfileManager sobre as mudanças
      UserProfileManager().notifyProfileChanged();

      await loadCurrentProfile();

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
      _isUploadingPhoto = false;
      notifyListeners();
    }
  }

  void _onProfileDataChanged() {
    loadCurrentProfile();
  }

  @override
  void dispose() {
    UserProfileManager().removeListener(_onProfileDataChanged);
    super.dispose();
  }

  void navigateBack(BuildContext context) {
    context.pop();
  }
}
