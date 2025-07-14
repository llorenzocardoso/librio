import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/entities/user_profile.dart';
import 'package:librio/src/domain/repositories/user_profile_repository.dart';
import 'package:librio/src/data/models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseFirestore _firestore;
  final fb.FirebaseAuth _auth;

  UserProfileRepositoryImpl({
    FirebaseFirestore? firestore,
    fb.FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? fb.FirebaseAuth.instance;

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    // Primeiro tentar buscar na coleção user_profiles (nova estrutura)
    final userProfileDoc = await _firestore.collection('user_profiles').doc(userId).get();

    if (userProfileDoc.exists) {
      return UserProfileModel.fromFirestore(userProfileDoc);
    }

    // Fallback para coleção users (compatibilidade)
    final userDoc = await _firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw Exception('Perfil do usuário não encontrado');
    }

    return UserProfileModel.fromFirestore(userDoc);
  }

  @override
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? description,
    String? photoUrl,
  }) async {
    final Map<String, dynamic> updateData = {};

    if (name != null) {
      updateData['name'] = name;
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        await currentUser.updateDisplayName(name);
      }
    }

    if (description != null) {
      updateData['description'] = description;
    }

    if (photoUrl != null) {
      updateData['photoUrl'] = photoUrl;
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        await currentUser.updatePhotoURL(photoUrl);
      }
    }

    if (updateData.isNotEmpty) {
      updateData['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(updateData);
    }
  }

  @override
  Future<void> updateUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    String? city,
    String? state,
    String? address,
  }) async {
    // Garantir que o perfil do usuário existe antes de atualizar a localização
    await _ensureUserProfileExists(userId);

    final Map<String, dynamic> updateData = {
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (city != null) updateData['city'] = city;
    if (state != null) updateData['state'] = state;
    if (address != null) updateData['address'] = address;

    // Usar set com merge: true para criar o documento se não existir
    await _firestore.collection('user_profiles').doc(userId).set(
      updateData,
      SetOptions(merge: true),
    );
  }

  /// Garante que o perfil do usuário existe na coleção user_profiles
  Future<void> _ensureUserProfileExists(String userId) async {
    try {
      final userProfileDoc = await _firestore.collection('user_profiles').doc(userId).get();

      if (!userProfileDoc.exists) {
        // Tentar obter dados do usuário da coleção 'users' (compatibilidade)
        final userDoc = await _firestore.collection('users').doc(userId).get();

        final userData = userDoc.exists ? userDoc.data() as Map<String, dynamic> : {};

        // Criar perfil básico com dados disponíveis
        final defaultUserData = {
          'name': userData['name'] ?? 'Usuário',
          'email': userData['email'] ?? '',
          'description': userData['description'] ?? '',
          'averageRating': userData['averageRating'] ?? 0.0,
          'ratingCount': userData['ratingCount'] ?? 0,
          'exchangeCount': userData['exchangeCount'] ?? 0,
          'photoUrl': userData['photoUrl'] ?? '',
          'ratings': userData['ratings'] ?? [],
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('user_profiles').doc(userId).set(defaultUserData);
      }
    } catch (e) {
      throw Exception('Erro ao garantir perfil do usuário: $e');
    }
  }
}
