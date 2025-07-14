import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Verifica se o GPS está habilitado
  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Solicita permissões de localização
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Obtém a localização atual do usuário
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await isLocationEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviços de localização desabilitados');
      }

      LocationPermission permission = await requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  /// Converte coordenadas em endereço
  Future<Map<String, String>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return {
          'city': place.locality ?? '',
          'state': place.administrativeArea ?? '',
          'address': '${place.street ?? ''}, ${place.subLocality ?? ''}'.trim(),
        };
      }
    } catch (e) {
      throw Exception('Erro ao obter endereço: $e');
    }

    return {
      'city': '',
      'state': '',
      'address': '',
    };
  }

  /// Calcula distância entre duas coordenadas (em km)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Verifica se duas localizações estão dentro de uma distância máxima
  bool isWithinDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double maxDistanceKm,
  ) {
    double distance = calculateDistance(lat1, lon1, lat2, lon2);
    return distance <= maxDistanceKm;
  }
}
