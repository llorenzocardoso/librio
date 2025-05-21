import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/repositories/book_repository.dart';
import 'package:librio/src/domain/entities/book.dart';

class BookRepositoryImpl implements BookRepository {
  final FirebaseFirestore _firestore;
  final fb.FirebaseAuth _auth;

  BookRepositoryImpl({FirebaseFirestore? firestore, fb.FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? fb.FirebaseAuth.instance;

  @override
  Future<void> addBook({
    required String title,
    required String author,
    required String genre,
    required String description,
    required String condition,
  }) async {
    final fb.User? user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    await _firestore.collection('books').add({
      'title': title,
      'author': author,
      'genre': genre,
      'description': description,
      'condition': condition,
      'imageUrl': '', // TODO: upload and provide
      'ownerId': user.uid,
      'available': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<Book>> getUserBooks(String ownerId) async {
    final query = await _firestore
        .collection('books')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs.map((doc) {
      final data = doc.data();
      return Book(
        id: doc.id,
        title: data['title'] as String,
        author: data['author'] as String,
        imageUrl: data['imageUrl'] as String? ?? '',
        condition: data['condition'] as String,
        ownerId: data['ownerId'] as String,
        genre: data['genre'] as String,
        description: data['description'] as String? ?? '',
        available: data['available'] as bool? ?? true,
      );
    }).toList();
  }
}
