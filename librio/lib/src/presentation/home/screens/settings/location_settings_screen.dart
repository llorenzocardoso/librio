import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/data/datasources/location_service.dart';
import 'package:librio/src/domain/usecases/update_user_location_usecase.dart';
import 'package:librio/src/data/repositories/user_profile_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  final LocationService _locationService = LocationService();
  final UpdateUserLocationUseCase _updateLocationUseCase =
      UpdateUserLocationUseCase(
    UserProfileRepositoryImpl(),
  );

  bool _isLoading = false;
  String? _error;
  String? _currentLocation;
  double _selectedDistance = 10.0; // Distância padrão em km
  bool _locationEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDistance = prefs.getDouble('max_distance_km') ?? 10.0;
      _locationEnabled = prefs.getBool('location_enabled') ?? false;
    });
  }

  Future<void> _saveDistancePreference(double distance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('max_distance_km', distance);
    setState(() {
      _selectedDistance = distance;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Distância máxima definida como ${distance.toInt()} km'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Localização'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de Status da Localização
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _locationEnabled
                              ? Icons.location_on
                              : Icons.location_off,
                          color: _locationEnabled ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status da Localização',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                _locationEnabled ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _locationEnabled
                          ? 'Localização ativada - Você pode encontrar trocas próximas'
                          : 'Localização desativada - Ative para encontrar trocas próximas',
                      style: TextStyle(
                        color: _locationEnabled
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Seção de Localização Atual
            if (_currentLocation != null) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.my_location, color: Colors.blue),
                  title: const Text('Localização Atual'),
                  subtitle: Text(_currentLocation!),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _getCurrentLocation,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Seção de Erro
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Botão para obter localização
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _getCurrentLocation,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_isLoading
                    ? 'Obtendo localização...'
                    : _currentLocation != null
                        ? 'Atualizar Localização'
                        : 'Usar Localização Atual'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Seção de Configurações de Distância
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                         Icon(Icons.radar, color: Colors.orange),
                         SizedBox(width: 8),
                         Text(
                          'Distância Máxima',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Defina até que distância você quer ver livros disponíveis para troca.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),

                    // Slider para distância
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedDistance.toInt()} km',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Máximo: 50 km',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
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
                          },
                          onChangeEnd: (value) {
                            _saveDistancePreference(value);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Opções rápidas de distância
                    const Text(
                      'Opções Rápidas:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDistanceOption('5 km', 5.0),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDistanceOption('10 km', 10.0),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDistanceOption('25 km', 25.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Seção de Informações
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                         Icon(Icons.info_outline, color: Colors.blue),
                         SizedBox(width: 8),
                         Text(
                          'Como funciona?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Sua localização é usada apenas para encontrar livros próximos\n'
                      '• A distância máxima define o raio de busca\n'
                      '• Você pode alterar essas configurações a qualquer momento\n'
                      '• Sua localização não é compartilhada com outros usuários',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceOption(String label, double distance) {
    final isSelected = _selectedDistance == distance;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedDistance = distance;
        });
        _saveDistancePreference(distance);
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue.shade50 : null,
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

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

          // Salvar preferências
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('location_enabled', true);

          setState(() {
            _currentLocation = '${address['city']}, ${address['state']}';
            _locationEnabled = true;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Localização atualizada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        setState(() {
          _error =
              'Não foi possível obter sua localização. Verifique se o GPS está ativado e as permissões foram concedidas.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao obter localização: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
