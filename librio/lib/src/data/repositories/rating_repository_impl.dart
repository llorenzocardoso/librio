import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:librio/src/domain/repositories/rating_repository.dart';
import 'package:librio/src/domain/entities/rating.dart';
import 'package:librio/src/domain/entities/user_profile.dart';
import 'package:librio/src/data/models/rating_model.dart';
import 'package:librio/src/data/models/user_profile_model.dart';

class RatingRepositoryImpl implements RatingRepository {
  final FirebaseFirestore _firestore;

  RatingRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createRating({
    required String exchangeId,
    required String evaluatorId,
    required String evaluatedId,
    required int stars,
    required String message,
  }) async {
    final ratingModel = RatingModel(
      id: '',
      exchangeId: exchangeId,
      evaluatorId: evaluatorId,
      evaluatedId: evaluatedId,
      stars: stars,
      message: message,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('ratings').add(ratingModel.toFirestore());

    // Atualizar as estatísticas do usuário avaliado
    await updateUserRatingStats(evaluatedId);
  }

  @override
  Future<List<Rating>> getUserRatings(String userId) async {
    final querySnapshot = await _firestore
        .collection('ratings')
        .where('evaluatedId', isEqualTo: userId)
        .get();

    final ratings = querySnapshot.docs
        .map((doc) => RatingModel.fromFirestore(doc))
        .toList();

    // Ordenar localmente por data de criação (mais recente primeiro)
    ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ratings;
  }

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();

    if (!doc.exists) {
      throw Exception('Usuário não encontrado');
    }

    return UserProfileModel.fromFirestore(doc);
  }

  @override
  Future<bool> hasUserRatedExchange(
      String exchangeId, String evaluatorId) async {
    final querySnapshot = await _firestore
        .collection('ratings')
        .where('exchangeId', isEqualTo: exchangeId)
        .where('evaluatorId', isEqualTo: evaluatorId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Future<void> updateUserRatingStats(String userId) async {
    final ratings = await getUserRatings(userId);

    if (ratings.isEmpty) {
      await _firestore.collection('users').doc(userId).update({
        'averageRating': 0.0,
        'ratingCount': 0,
      });
      return;
    }

    final double averageRating =
        ratings.map((rating) => rating.stars).reduce((a, b) => a + b) /
            ratings.length;

    await _firestore.collection('users').doc(userId).update({
      'averageRating': averageRating,
      'ratingCount': ratings.length,
    });
  }
}
