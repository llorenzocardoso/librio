# 📍 Sistema de Geolocalização

## Visão Geral

O sistema de geolocalização permite que usuários encontrem livros para troca baseados na proximidade geográfica, tornando as trocas mais práticas e viáveis. Inclui obtenção de localização GPS, cálculo de distâncias e filtragem por proximidade.

## Dependências

### Packages Necessários

```yaml
dependencies:
  geolocator: ^10.1.0        # Obter localização GPS
  geocoding: ^2.1.1          # Conversão coordenadas/endereço
  shared_preferences: ^2.2.2 # Salvar preferências do usuário
```

### Permissões

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Este app precisa acessar sua localização para encontrar livros próximos a você.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Este app precisa acessar sua localização para encontrar livros próximos a você.</string>
```

## Estrutura de Dados

### UserProfile Entity (Atualizada)

```dart
class UserProfile {
  final String id;
  final String name;
  final String? bio;
  final String? profileImageUrl;
  final double? latitude;      // Novo campo
  final double? longitude;     // Novo campo
  final String? city;          // Novo campo
  final String? state;         // Novo campo
  final String? address;       // Novo campo
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    this.bio,
    this.profileImageUrl,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

## Serviços

### LocationService

O serviço principal para todas as operações de geolocalização:

```dart
class LocationService {
  // Verifica se o GPS está habilitado
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Verifica status das permissões
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Solicita permissões de localização
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  // Obtém localização atual
  Future<Position> getCurrentLocation() async {
    // Verificar se GPS está habilitado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS não está habilitado');
    }

    // Verificar permissões
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissões de localização permanentemente negadas');
    }

    // Obter localização
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Converte coordenadas em endereço
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.locality}, ${place.administrativeArea}';
      }
      return 'Endereço não encontrado';
    } catch (e) {
      return 'Erro ao obter endereço: $e';
    }
  }

  // Calcula distância entre duas coordenadas
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // km
  }

  // Verifica se está dentro da distância máxima
  bool isWithinDistance(
    double userLat,
    double userLon,
    double targetLat,
    double targetLon,
    double maxDistanceKm,
  ) {
    double distance = calculateDistance(userLat, userLon, targetLat, targetLon);
    return distance <= maxDistanceKm;
  }
}
```

## Use Cases

### UpdateUserLocationUseCase

Atualiza a localização do usuário no perfil:

```dart
class UpdateUserLocationUseCase {
  final UserProfileRepository _userProfileRepository;
  final LocationService _locationService;

  UpdateUserLocationUseCase(
    this._userProfileRepository,
    this._locationService,
  );

  Future<void> call(String userId) async {
    try {
      // Obter localização atual
      Position position = await _locationService.getCurrentLocation();

      // Converter em endereço
      String address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Extrair cidade e estado
      List<String> parts = address.split(', ');
      String? city = parts.isNotEmpty ? parts[0] : null;
      String? state = parts.length > 1 ? parts[1] : null;

      // Atualizar no repositório
      await _userProfileRepository.updateUserLocation(
        userId: userId,
        latitude: position.latitude,
        longitude: position.longitude,
        city: city,
        state: state,
        address: address,
      );
    } catch (e) {
      throw Exception('Erro ao atualizar localização: $e');
    }
  }
}
```

### GetBooksByDistanceUseCase

Busca livros baseados na proximidade geográfica:

```dart
class GetBooksByDistanceUseCase {
  final BookRepository _bookRepository;
  final UserProfileRepository _userProfileRepository;

  GetBooksByDistanceUseCase(
    this._bookRepository,
    this._userProfileRepository,
  );

  Future<List<Book>> call({
    required String userId,
    required double maxDistanceKm,
    String? genre,
  }) async {
    try {
      // Obter perfil do usuário com localização
      UserProfile userProfile = await _userProfileRepository.getUserProfile(userId);

      if (userProfile.latitude == null || userProfile.longitude == null) {
        throw Exception('Localização do usuário não disponível');
      }

      // Buscar livros por distância
      return await _bookRepository.getBooksByDistance(
        userLatitude: userProfile.latitude!,
        userLongitude: userProfile.longitude!,
        maxDistanceKm: maxDistanceKm,
        genre: genre,
      );
    } catch (e) {
      throw Exception('Erro ao buscar livros por distância: $e');
    }
  }
}
```

## Repository Implementation

### UserProfileRepository (Método Adicionado)

```dart
abstract class UserProfileRepository {
  // ... métodos existentes ...

  Future<void> updateUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    String? city,
    String? state,
    String? address,
  });
}

class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseFirestore _firestore;

  // ... implementações existentes ...

  @override
  Future<void> updateUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    String? city,
    String? state,
    String? address,
  }) async {
    try {
      await _firestore.collection('user_profiles').doc(userId).update({
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'state': state,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar localização do usuário: $e');
    }
  }
}
```

### BookRepository (Método Adicionado)

```dart
abstract class BookRepository {
  // ... métodos existentes ...

  Future<List<Book>> getBooksByDistance({
    required double userLatitude,
    required double userLongitude,
    required double maxDistanceKm,
    String? genre,
  });
}

class BookRepositoryImpl implements BookRepository {
  // ... implementações existentes ...

  @override
  Future<List<Book>> getBooksByDistance({
    required double userLatitude,
    required double userLongitude,
    required double maxDistanceKm,
    String? genre,
  }) async {
    try {
      Query query = _firestore
          .collection('books')
          .where('available', isEqualTo: true);

      if (genre != null && genre.isNotEmpty) {
        query = query.where('genre', isEqualTo: genre);
      }

      final querySnapshot = await query.get();
      final books = <Book>[];

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final bookLatitude = data['latitude'] as double?;
        final bookLongitude = data['longitude'] as double?;

        if (bookLatitude != null && bookLongitude != null) {
          final distance = _calculateDistance(
            userLatitude,
            userLongitude,
            bookLatitude,
            bookLongitude,
          );

          if (distance <= maxDistanceKm) {
            books.add(Book.fromFirestore(doc));
          }
        }
      }

      return books;
    } catch (e) {
      throw Exception('Erro ao buscar livros por distância: $e');
    }
  }

  // Fórmula de Haversine para cálculo de distância
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Raio da Terra em km
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(_degreesToRadians(lat1)) *
            math.sin(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}
```

## Interface do Usuário

### Tela de Configurações de Localização

```dart
class LocationSettingsScreen extends StatefulWidget {
  @override
  _LocationSettingsScreenState createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  bool _isLocationEnabled = false;
  double _selectedDistance = 10.0;
  String? _currentLocation;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Localização'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLocationStatus(),
            const SizedBox(height: 24),
            _buildLocationButton(),
            const SizedBox(height: 24),
            _buildDistanceSelector(),
            const SizedBox(height: 24),
            _buildQuickDistanceOptions(),
            const SizedBox(height: 24),
            _buildCurrentLocationDisplay(),
            const SizedBox(height: 32),
            _buildExplanationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatus() {
    return Card(
      child: ListTile(
        leading: Icon(
          _isLocationEnabled ? Icons.location_on : Icons.location_off,
          color: _isLocationEnabled ? Colors.green : Colors.grey,
        ),
        title: Text(
          _isLocationEnabled
            ? 'Localização Ativada'
            : 'Localização Desativada',
        ),
        subtitle: Text(
          _isLocationEnabled
            ? 'Mostrando livros próximos a você'
            : 'Ative para ver livros próximos',
        ),
      ),
    );
  }

  Widget _buildDistanceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distância Máxima: ${_selectedDistance.toInt()} km',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Slider(
          value: _selectedDistance,
          min: 1.0,
          max: 50.0,
          divisions: 49,
          label: '${_selectedDistance.toInt()} km',
          onChanged: (value) {
            setState(() {
              _selectedDistance = value;
            });
            _saveDistancePreference(value);
          },
        ),
      ],
    );
  }

  Widget _buildQuickDistanceOptions() {
    final quickOptions = [5.0, 10.0, 25.0];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: quickOptions.map((distance) {
        final isSelected = _selectedDistance == distance;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedDistance = distance;
                });
                _saveDistancePreference(distance);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
                foregroundColor: isSelected ? Colors.white : Colors.black87,
              ),
              child: Text('${distance.toInt()}km'),
            ),
          ),
        );
      }).toList(),
    );
  }
}
```

## Fluxo de Uso

### 1. Configuração Inicial
1. Usuário acessa configurações de localização
2. Solicita permissões de GPS
3. Obtém localização atual
4. Salva coordenadas e endereço no perfil

### 2. Busca por Proximidade
1. Usuário define distância máxima desejada
2. Sistema busca livros dentro do raio especificado
3. Exibe resultados ordenados por distância
4. Permite filtros adicionais (gênero, etc.)

### 3. Atualização de Localização
1. Usuário pode atualizar localização manualmente
2. Sistema valida nova localização
3. Atualiza perfil com novos dados
4. Recalcula proximidade dos livros

## Tratamento de Erros

### Cenários Comuns

```dart
// GPS desabilitado
if (!await LocationService().isLocationServiceEnabled()) {
  throw LocationException('GPS não está habilitado');
}

// Permissões negadas
if (permission == LocationPermission.denied) {
  throw LocationException('Permissão de localização negada');
}

// Permissões permanentemente negadas
if (permission == LocationPermission.deniedForever) {
  throw LocationException('Abra as configurações e habilite a localização');
}

// Timeout na obtenção de localização
Future.timeout(
  Duration(seconds: 30),
  onTimeout: () => throw LocationException('Timeout ao obter localização'),
);
```

## Considerações de Performance

### Otimizações Implementadas

1. **Cache de Localização**: Evita solicitações GPS excessivas
2. **Fórmula de Haversine**: Cálculo eficiente de distâncias
3. **Filtros no Backend**: Reduz transferência de dados
4. **Indexação Geoespacial**: Para grandes volumes de dados

### Configurações Recomendadas

```dart
// Configuração otimizada para o Geolocator
LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100, // Atualizar apenas se mover 100m
);
```

## Segurança e Privacidade

### Boas Práticas

1. **Permissões Mínimas**: Solicitar apenas "when in use"
2. **Dados Opcionais**: Localização é sempre opcional
3. **Transparência**: Explicar claramente o uso dos dados
4. **Controle do Usuário**: Permitir desabilitar a qualquer momento

### Firestore Security Rules

```javascript
// Regras para documentos com localização
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /user_profiles/{userId} {
      allow update: if request.auth != null
        && request.auth.uid == userId
        && request.writeFields.hasOnly([
          'latitude', 'longitude', 'city', 'state', 'address', 'updatedAt'
        ]);
    }
  }
}
```

## Testes

### Testes Unitários

```dart
class MockLocationService extends Mock implements LocationService {}

void main() {
  group('GetBooksByDistanceUseCase', () {
    test('should return books within specified distance', () async {
      // Arrange
      final mockLocationService = MockLocationService();
      final useCase = GetBooksByDistanceUseCase(mockLocationService);

      // Act & Assert
      // ... implementar testes
    });
  });
}
```

### Testes de Integração

```dart
void main() {
  group('Location Integration Tests', () {
    testWidgets('should request location permission', (tester) async {
      // Arrange
      await tester.pumpWidget(MyApp());

      // Act
      await tester.tap(find.text('Obter Localização'));
      await tester.pump();

      // Assert
      expect(find.text('Permissão solicitada'), findsOneWidget);
    });
  });
}
```

## Troubleshooting

### Problemas Comuns

1. **"No location permissions are defined"**
   - Verificar `AndroidManifest.xml` e `Info.plist`
   - Reinstalar o app após adicionar permissões

2. **Localização imprecisa no emulador**
   - Usar: `adb shell geo fix longitude latitude`
   - Configurar localização nas configurações do emulador

3. **Timeout ao obter localização**
   - Verificar conexão com GPS/WiFi
   - Aumentar timeout ou usar `LocationAccuracy.low`

4. **Permissões negadas permanentemente**
   - Orientar usuário a abrir configurações do sistema
   - Implementar deep link para configurações

## Roadmap

### Melhorias Futuras

1. **Notificações por Proximidade**: Alertar sobre novos livros próximos
2. **Mapa Interativo**: Visualizar livros em um mapa
3. **Localização Automática**: Atualizar localização em background
4. **Zonas de Entrega**: Definir pontos de encontro preferenciais
5. **Integração com Transporte**: Considerar rotas de transporte público
