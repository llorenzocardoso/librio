import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/data/data.dart';
import 'package:librio/src/routes/routes.dart';
import 'package:librio/src/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/data/datasources/location_service.dart';
import 'package:librio/src/domain/usecases/update_user_location_usecase.dart';

class HomeViewModel extends ChangeNotifier {
  final BookDataManager _bookDataManager = BookDataManager();
  final GetBooksByDistanceUseCase _getBooksByDistanceUseCase =
      GetBooksByDistanceUseCase(BookRepositoryImpl());
  final LocationService _locationService = LocationService();
  final UpdateUserLocationUseCase _updateLocationUseCase =
      UpdateUserLocationUseCase(UserProfileRepositoryImpl());
  final UserProfileRepository _userProfileRepository =
      UserProfileRepositoryImpl();

  // Estado da pesquisa e filtros
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  List<Book> _filteredBooks = [];

  // Estado de geolocalização
  bool _locationEnabled = false;
  double _maxDistanceKm = 10.0;
  String? _currentLocation;
  bool _isLoadingLocation = false;
  bool _locationPreferencesLoaded = false;

  // Categorias disponíveis (vem das constantes centralizadas)
  static List<String> get categories => BookConstants.categoriesWithAll;

  List<Book> get books => _filteredBooks;
  bool get isLoading => _bookDataManager.isLoading;
  String? get error => _bookDataManager.error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  List<String> get availableCategories => categories;

  // Getters de geolocalização
  bool get locationEnabled => _locationEnabled;
  double get maxDistanceKm => _maxDistanceKm;
  String? get currentLocation => _currentLocation;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get locationPreferencesLoaded => _locationPreferencesLoaded;

  HomeViewModel() {
    _bookDataManager.addListener(_onDataChanged);
    _loadBooks();
    _loadLocationPreferences();
  }

  void _onDataChanged() {
    _applyFilters().then((_) => notifyListeners());
  }

  @override
  void dispose() {
    _bookDataManager.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> _loadBooks() async {
    await _bookDataManager.loadAllBooks();
  }

  Future<void> _loadLocationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _locationEnabled = prefs.getBool('location_enabled') ?? false;
        _maxDistanceKm = prefs.getDouble('max_distance_km') ?? 10.0;
        _locationPreferencesLoaded = true;
      });

      // Aplicar filtros após carregar preferências
      _applyFilters().then((_) => notifyListeners());
    } catch (e) {
      setState(() {
        _locationPreferencesLoaded = true;
      });
    }
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  Future<void> refresh() async {
    await _bookDataManager.refresh();
    await _loadLocationPreferences();
    await _applyFilters();
    notifyListeners();
  }

  // Função para pesquisar livros
  void searchBooks(String query) {
    _searchQuery = query.trim();
    _applyFilters().then((_) => notifyListeners());
  }

  // Função para filtrar por categoria
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters().then((_) => notifyListeners());
  }

  // Função para ativar/desativar filtro de localização
  void toggleLocationFilter(bool enabled) async {
    _locationEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_enabled', enabled);

    await _applyFilters();
    notifyListeners();
  }

  // Função para ativar localização rapidamente (obtém localização real)
  Future<void> activateLocationQuickly() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Obter localização atual
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        // Converter coordenadas em endereço
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        // Atualizar perfil do usuário
        final user = fb.FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _updateLocationUseCase.execute(
            userId: user.uid,
            latitude: position.latitude,
            longitude: position.longitude,
            city: address['city'],
            state: address['state'],
            address: address['address'],
          );
        }

        // Salvar preferências
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('location_enabled', true);

        setState(() {
          _locationEnabled = true;
          _currentLocation = '${address['city']}, ${address['state']}';
          _isLoadingLocation = false;
        });

        // Aplicar filtros
        await _applyFilters();
      } else {
        setState(() {
          _isLoadingLocation = false;
        });

        // Se não conseguiu obter localização, mostrar erro
        throw Exception('Não foi possível obter sua localização');
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });

      // Re-throw para que a UI possa mostrar o erro
      rethrow;
    }
  }

  // Função para definir distância máxima
  void setMaxDistance(double distance) async {
    _maxDistanceKm = distance;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('max_distance_km', distance);

    if (_locationEnabled) {
      _applyFilters().then((_) => notifyListeners());
    }
  }

  // Aplica todos os filtros (pesquisa + categoria + localização)
  Future<void> _applyFilters() async {
    // Se as preferências ainda não foram carregadas, não mostrar livros
    if (!_locationPreferencesLoaded) {
      _filteredBooks = [];
      return;
    }

    // Se localização não está habilitada, não mostrar livros
    if (!_locationEnabled) {
      _filteredBooks = [];
      return;
    }

    List<Book> books = _bookDataManager.allBooks;

    // Filtro por localização (sempre aplicado quando habilitado)
    books = await _applyLocationFilter(books);

    // Filtro por categoria
    if (_selectedCategory != 'Todos') {
      books = books.where((book) {
        return book.genre.toLowerCase() == _selectedCategory.toLowerCase();
      }).toList();
    }

    // Filtro por pesquisa
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      books = books.where((book) {
        return book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query) ||
            book.genre.toLowerCase().contains(query) ||
            book.description.toLowerCase().contains(query);
      }).toList();

      // Ordenar por relevância (título primeiro, depois autor)
      books.sort((a, b) {
        final aTitle = a.title.toLowerCase();
        final bTitle = b.title.toLowerCase();
        final aAuthor = a.author.toLowerCase();
        final bAuthor = b.author.toLowerCase();

        // Se o título de A contém a query e B não, A vem primeiro
        if (aTitle.contains(query) && !bTitle.contains(query)) return -1;
        if (!aTitle.contains(query) && bTitle.contains(query)) return 1;

        // Se ambos contêm no título, ordena alfabeticamente
        if (aTitle.contains(query) && bTitle.contains(query)) {
          return aTitle.compareTo(bTitle);
        }

        // Se nenhum contém no título, verifica autor
        if (aAuthor.contains(query) && !bAuthor.contains(query)) return -1;
        if (!aAuthor.contains(query) && bAuthor.contains(query)) return 1;

        // Caso padrão: ordem alfabética
        return aTitle.compareTo(bTitle);
      });
    } else {
      // Se não há pesquisa, ordena alfabeticamente por título
      books.sort((a, b) => a.title.compareTo(b.title));
    }

    _filteredBooks = books;
  }

  // Aplica filtro de localização usando distância real
  Future<List<Book>> _applyLocationFilter(List<Book> books) async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      return books;
    }

    try {
      // Obter localização do usuário
      final userProfile = await _userProfileRepository.getUserProfile(user.uid);

      if (userProfile.latitude == null || userProfile.longitude == null) {
        final booksWithCoords = books.where((book) {
          return book.latitude != null && book.longitude != null;
        }).toList();
        return booksWithCoords;
      }

      // Usar GetBooksByDistanceUseCase para obter livros por distância
      final booksWithDistance = await _getBooksByDistanceUseCase.execute(
        userLatitude: userProfile.latitude!,
        userLongitude: userProfile.longitude!,
        maxDistanceKm: _maxDistanceKm,
      );

      // Filtrar apenas os livros que estão na lista original (aplicar outros filtros)
      final originalBookIds = books.map((book) => book.id).toSet();
      final filteredBooks = booksWithDistance
          .where((book) => originalBookIds.contains(book.id))
          .toList();
      return filteredBooks;
    } catch (e) {
      final booksWithCoords = books.where((book) {
        return book.latitude != null && book.longitude != null;
      }).toList();
      return booksWithCoords;
    }
  }

  void navigateToAddBook(BuildContext context) {
    context.push(AppRoutes.addBook);
  }

  void navigateToBookDetails(BuildContext context, Book book) {
    context.push(AppRoutes.bookDetails, extra: book);
  }

  void navigateToLocationSettings(BuildContext context) {
    context.push(AppRoutes.locationSettings);
  }
}
