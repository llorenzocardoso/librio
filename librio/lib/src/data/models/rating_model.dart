import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:librio/src/domain/entities/rating.dart';

class RatingModel extends Rating {
  RatingModel({
    required String id,
    required String exchangeId,
    required String evaluatorId,
    required String evaluatedId,
    required int stars,
    required String message,
    required DateTime createdAt,
  }) : super(
          id: id,
          exchangeId: exchangeId,
          evaluatorId: evaluatorId,
          evaluatedId: evaluatedId,
          stars: stars,
          message: message,
          createdAt: createdAt,
        );

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      id: doc.id,
      exchangeId: data['exchangeId'] ?? '',
      evaluatorId: data['evaluatorId'] ?? '',
      evaluatedId: data['evaluatedId'] ?? '',
      stars: data['stars'] ?? 0,
      message: data['message'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'exchangeId': exchangeId,
      'evaluatorId': evaluatorId,
      'evaluatedId': evaluatedId,
      'stars': stars,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
