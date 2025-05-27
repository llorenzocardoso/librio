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
        .get();
    final books = query.docs.map((doc) {
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

    // Ordenar no lado do cliente (mais recentes primeiro)
    books.sort((a, b) => b.id.compareTo(a.id));
    return books;
  }

  @override
  Future<List<Book>> getAllBooks({String? excludeUserId}) async {
    final query = await _firestore
        .collection('books')
        .where('available', isEqualTo: true)
        .get();
    final books = query.docs.map((doc) {
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

    // Filtrar livros do usuário especificado (se fornecido)
    if (excludeUserId != null) {
      books.removeWhere((book) => book.ownerId == excludeUserId);
    }

    // Ordenar no lado do cliente por enquanto (mais recentes primeiro)
    books.sort((a, b) => b.id.compareTo(a.id));
    return books;
  }

  @override
  Future<void> updateBookAvailability(String bookId, bool available) async {
    await _firestore.collection('books').doc(bookId).update({
      'available': available,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
