import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/data/datasources/datasources.dart';
import 'package:librio/src/routes/routes.dart';
import 'package:librio/src/data/datasources/location_service.dart';
import 'package:librio/src/data/repositories/user_profile_repository_impl.dart';
import 'package:librio/src/domain/usecases/update_user_location_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AddBookViewModel extends ChangeNotifier {
  final AddBookUseCase _useCase;
  final CloudinaryStorageService _storageService;
  final ImagePickerService _imagePickerService;
  final LocationService _locationService;
  final UserProfileRepository _userProfileRepository;
  final UpdateUserLocationUseCase _updateLocationUseCase;

  bool isLoading = false;
  bool isUploadingImage = false;
  String? error;
  File? selectedImageFile;

  AddBookViewModel(
    this._useCase, {
    CloudinaryStorageService? storageService,
    ImagePickerService? imagePickerService,
    LocationService? locationService,
    UserProfileRepository? userProfileRepository,
  })  : _storageService = storageService ?? CloudinaryStorageService(),
        _imagePickerService = imagePickerService ?? ImagePickerService(),
        _locationService = locationService ?? LocationService(),
        _userProfileRepository =
            userProfileRepository ?? UserProfileRepositoryImpl(),
        _updateLocationUseCase = UpdateUserLocationUseCase(
            userProfileRepository ?? UserProfileRepositoryImpl());

  Future<void> pickImage(BuildContext context) async {
    try {
      final File? imageFile = await _imagePickerService.pickImage(context);
      if (imageFile == null) return;

      selectedImageFile = imageFile;
      notifyListeners();
    } catch (e) {
      error = 'Erro ao selecionar imagem: $e';
      notifyListeners();
    }
  }

  void removeImage() {
    selectedImageFile = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> _getUserLocation() async {
    try {
      final user = fb.FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final userProfile = await _userProfileRepository.getUserProfile(user.uid);

      if (userProfile.latitude != null && userProfile.longitude != null) {
        return {
          'latitude': userProfile.latitude,
          'longitude': userProfile.longitude,
          'city': userProfile.city,
          'state': userProfile.state,
        };
      }

      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        await _updateLocationUseCase.execute(
          userId: user.uid,
          latitude: position.latitude,
          longitude: position.longitude,
          city: address['city'],
          state: address['state'],
          address: address['address'],
        );

        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'city': address['city'],
          'state': address['state'],
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> addBook({
    required String title,
    required String author,
    required String genre,
    required String description,
    required String condition,
  }) async {
    if (selectedImageFile == null) {
      error = 'Uma imagem do livro é obrigatória';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();
    try {
      isUploadingImage = true;
      notifyListeners();

      final String? imageUrl =
          await _storageService.uploadBookImage(selectedImageFile!);

      isUploadingImage = false;
      notifyListeners();

      if (imageUrl == null) {
        throw Exception('Falha no upload da imagem');
      }

      final locationData = await _getUserLocation();

      if (locationData == null) {
        throw Exception('Não foi possível obter sua localização. '
            'Verifique se o GPS está ativado e as permissões foram concedidas. '
            'A localização é necessária para que outros usuários possam encontrar seus livros.');
      }

      await _useCase.execute(
        title: title,
        author: author,
        genre: genre,
        description: description,
        condition: condition,
        imageUrl: imageUrl,
        latitude: locationData['latitude'],
        longitude: locationData['longitude'],
        city: locationData['city'],
        state: locationData['state'],
      );

      error = null;
    } catch (e) {
      if (e.toString().contains('permission-denied') ||
          e.toString().contains('PERMISSION_DENIED')) {
        error = 'Erro de permissão. Tente fazer login novamente.';
      } else {
        error = 'Erro ao criar livro: ${e.toString()}';
      }
    } finally {
      isLoading = false;
      isUploadingImage = false;
      notifyListeners();
    }
  }

  void navigateToHome(BuildContext context) {
    context.go(AppRoutes.home);
  }
}
