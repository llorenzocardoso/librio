import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:librio/src/data/data.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/domain/usecases/update_book_usecase.dart';
import 'package:librio/src/domain/usecases/delete_book_usecase.dart';
import 'package:librio/src/data/datasources/location_service.dart';

class EditBookViewModel extends ChangeNotifier {
  final UpdateBookUseCase _updateBookUseCase;
  final DeleteBookUseCase _deleteBookUseCase;
  final CloudinaryStorageService _storageService;
  final ImagePickerService _imagePickerService;
  final LocationService _locationService;

  Book? _originalBook;
  File? _selectedImageFile;
  String? _currentImageUrl;
  bool _isUploadingImage = false;
  bool _isLoading = false;
  String? _error;

  double? _latitude;
  double? _longitude;
  String? _city;
  String? _state;
  bool _isLoadingLocation = false;

  EditBookViewModel({
    UpdateBookUseCase? updateBookUseCase,
    DeleteBookUseCase? deleteBookUseCase,
    CloudinaryStorageService? storageService,
    ImagePickerService? imagePickerService,
    LocationService? locationService,
  })  : _updateBookUseCase =
            updateBookUseCase ?? UpdateBookUseCase(BookRepositoryImpl()),
        _deleteBookUseCase =
            deleteBookUseCase ?? DeleteBookUseCase(BookRepositoryImpl()),
        _storageService = storageService ?? CloudinaryStorageService(),
        _imagePickerService = imagePickerService ?? ImagePickerService(),
        _locationService = locationService ?? LocationService();

  Book? get originalBook => _originalBook;
  File? get selectedImageFile => _selectedImageFile;
  String? get currentImageUrl => _currentImageUrl;
  bool get isUploadingImage => _isUploadingImage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get city => _city;
  String? get state => _state;
  bool get isLoadingLocation => _isLoadingLocation;

  void setBook(Book book) {
    _originalBook = book;
    _currentImageUrl = book.imageUrl;
    _latitude = book.latitude;
    _longitude = book.longitude;
    _city = book.city;
    _state = book.state;
    notifyListeners();
  }

  Future<void> pickImage(BuildContext context) async {
    try {
      final image = await _imagePickerService.pickImage(context);
      if (image != null) {
        _selectedImageFile = image;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao selecionar imagem: $e';
      notifyListeners();
    }
  }

  void removeImage() {
    _selectedImageFile = null;
    _currentImageUrl = null;
    notifyListeners();
  }

  Future<void> getLocation() async {
    _isLoadingLocation = true;
    _error = null;
    notifyListeners();

    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        _latitude = location.latitude;
        _longitude = location.longitude;

        if (_latitude != null && _longitude != null) {
          final address = await _locationService.getAddressFromCoordinates(
            _latitude!,
            _longitude!,
          );

          _city = address['city'];
          _state = address['state'];
        }
      }
    } catch (e) {
      _error = 'Erro ao obter localização: $e';
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  Future<void> updateBook({
    required String title,
    required String author,
    required String genre,
    required String description,
    required String condition,
    required BuildContext context,
  }) async {
    if (_originalBook == null) {
      _error = 'Livro não encontrado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? imageUrl = _currentImageUrl;

      if (_selectedImageFile != null) {
        _isUploadingImage = true;
        notifyListeners();

        imageUrl = await _storageService.uploadBookImage(_selectedImageFile!);

        if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
          try {
            await _storageService.deleteBookImage(_currentImageUrl!);
          } catch (e) {
            throw Exception('Erro ao deletar imagem antiga: $e');
          }
        }

        _isUploadingImage = false;
        notifyListeners();
      }

      await _updateBookUseCase.execute(
        bookId: _originalBook!.id,
        title: title,
        author: author,
        genre: genre,
        description: description,
        condition: condition,
        imageUrl: imageUrl,
        latitude: _latitude,
        longitude: _longitude,
        city: _city,
        state: _state,
      );

      if (context.mounted) {
        context.pop();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  Future<void> deleteBook(BuildContext context) async {
    if (_originalBook == null) {
      _error = 'Livro não encontrado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _deleteBookUseCase.execute(_originalBook!.id);

      if (context.mounted) {
        context.pop();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
