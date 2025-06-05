import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/entities/user_profile.dart';
import 'package:librio/src/domain/usecases/update_user_profile_usecase.dart';
import 'package:librio/src/data/repositories/user_profile_repository_impl.dart';

class EditProfileViewModel extends ChangeNotifier {
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final UserProfileRepositoryImpl _userProfileRepository;

  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _isLoadingProfile = false;
  String? _error;

  EditProfileViewModel({
    UpdateUserProfileUseCase? updateUserProfileUseCase,
    UserProfileRepositoryImpl? userProfileRepository,
  })  : _updateUserProfileUseCase = updateUserProfileUseCase ??
            UpdateUserProfileUseCase(UserProfileRepositoryImpl()),
        _userProfileRepository =
            userProfileRepository ?? UserProfileRepositoryImpl();

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isLoadingProfile => _isLoadingProfile;
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
      // Atualizar perfil
      await _updateUserProfileUseCase.execute(
        userId: user.uid,
        name: name.isNotEmpty ? name : null,
        description: description.isNotEmpty ? description : null,
      );

      // Mostrar sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Voltar para a tela anterior
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

  void navigateBack(BuildContext context) {
    context.pop();
  }
}
