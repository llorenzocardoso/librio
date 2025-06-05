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
    final doc = await _firestore.collection('users').doc(userId).get();

    if (!doc.exists) {
      throw Exception('Perfil do usuário não encontrado');
    }

    return UserProfileModel.fromFirestore(doc);
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
      // Atualizar também no Firebase Auth se for o usuário atual
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
      // Atualizar também no Firebase Auth se for o usuário atual
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
}
