import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/domain.dart';


class BookModel extends Book {
  BookModel({
    required String id,
    required String title,
    required String author,
    required String genre,
    required String description,
    required String imageUrl,
    required String condition,
    required String ownerId,
  }) : super(
          id: id,
          title: title,
          author: author,
          genre: genre,
          description: description,
          imageUrl: imageUrl,
          condition: condition,
          ownerId: ownerId,
        );

  factory BookModel.fromFirebaseUser(fb.User user) {
    return BookModel(
      id: user.uid,
      title: user.email ?? '',
      author: user.displayName ?? '',
      genre: user.displayName ?? '',
      description: user.displayName ?? '',
      imageUrl: '',
      condition: '',
      ownerId: '',
    );
  }
}
