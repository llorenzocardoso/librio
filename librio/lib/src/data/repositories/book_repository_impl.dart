import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/repositories/book_repository.dart';
import 'package:librio/src/domain/entities/book.dart';
import 'package:librio/src/shared/shared.dart';
import 'package:librio/src/data/datasources/storage_service.dart';

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
    required String? imageUrl,
    double? latitude,
    double? longitude,
    String? city,
    String? state,
  }) async {
    // Verificar se o usuário está autenticado
    final fb.User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
    await _firestore.collection('books').add({
      'title': title,
      'author': author,
      'genre': genre,
      'description': description,
      'condition': condition,
        'imageUrl': imageUrl,
        'ownerId': currentUser.uid,
      'available': true,
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'state': state,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Notificar BookDataManager sobre novo livro adicionado
    await BookDataManager().notifyBookDataChanged();
    } catch (e) {
      throw Exception('Erro ao adicionar livro: $e');
    }
  }

  @override
  Future<List<Book>> getUserBooks(String ownerId) async {
    // Verificar se o usuário está autenticado
    final fb.User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
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
          latitude: data['latitude'] as double?,
          longitude: data['longitude'] as double?,
          city: data['city'] as String?,
          state: data['state'] as String?,
        );
      }).toList();

      // Ordenar no lado do cliente (mais recentes primeiro)
      books.sort((a, b) => b.id.compareTo(a.id));
      return books;
    } catch (e) {
      throw Exception('Erro ao buscar livros do usuário: $e');
    }
  }

  @override
  Future<List<Book>> getAllBooks({String? excludeUserId}) async {
    // Verificar se o usuário está autenticado
    final fb.User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // Aguardar um pouco para garantir que a autenticação está completa
      await Future.delayed(const Duration(milliseconds: 100));

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
          latitude: data['latitude'] as double?,
          longitude: data['longitude'] as double?,
          city: data['city'] as String?,
          state: data['state'] as String?,
        );
      }).toList();

      // Filtrar livros do usuário especificado (se fornecido)
      if (excludeUserId != null) {
        books.removeWhere((book) => book.ownerId == excludeUserId);
      }

      // Ordenar no lado do cliente por enquanto (mais recentes primeiro)
      books.sort((a, b) => b.id.compareTo(a.id));
      return books;
    } catch (e) {
      // Se for erro de permissão, tentar reautenticar
      if (e.toString().contains('permission-denied') ||
          e.toString().contains('PERMISSION_DENIED')) {
        throw Exception('Erro de permissão: Verifique se você está logado. $e');
      }
      throw Exception('Erro ao buscar livros: $e');
    }
  }

  @override
  Future<void> updateBookAvailability(String bookId, bool available) async {
    // Verificar se o usuário está autenticado
    final fb.User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      await _firestore.collection('books').doc(bookId).update({
        'available': available,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notificar BookDataManager sobre mudanças nos livros
      await BookDataManager().notifyBookDataChanged();
    } catch (e) {
      throw Exception('Erro ao atualizar livro: $e');
    }
  }

  @override
  Future<List<Book>> getBooksByDistance({
    required double userLatitude,
    required double userLongitude,
    required double maxDistanceKm,
    String? genre,
  }) async {
    // Verificar se o usuário está autenticado
    final fb.User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      Query query =
          _firestore.collection('books').where('available', isEqualTo: true);

      if (genre != null && genre.isNotEmpty) {
        query = query.where('genre', isEqualTo: genre);
      }

      final querySnapshot = await query.get();
      final books = <Book>[];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        if (data == null) continue;

        final Map<String, dynamic> bookData = data as Map<String, dynamic>;
        final bookLatitude = bookData['latitude'] as double?;
        final bookLongitude = bookData['longitude'] as double?;

        if (bookLatitude != null && bookLongitude != null) {
          final distance = _calculateDistance(
            userLatitude,
            userLongitude,
            bookLatitude,
            bookLongitude,
          );

          if (distance <= maxDistanceKm) {
            books.add(Book(
              id: doc.id,
              title: bookData['title'] as String,
              author: bookData['author'] as String,
              imageUrl: bookData['imageUrl'] as String? ?? '',
              condition: bookData['condition'] as String,
              ownerId: bookData['ownerId'] as String,
              genre: bookData['genre'] as String,
              description: bookData['description'] as String? ?? '',
              available: bookData['available'] as bool? ?? true,
              latitude: bookData['latitude'] as double?,
              longitude: bookData['longitude'] as double?,
              city: bookData['city'] as String?,
              state: bookData['state'] as String?,
            ));
          }
        }
      }

      return books;
    } catch (e) {
      throw Exception('Erro ao buscar livros por distância: $e');
    }
  }

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

  @override
  Future<void> updateBook({
    required String bookId,
    required String title,
    required String author,
    required String genre,
    required String description,
    required String condition,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? city,
    String? state,
  }) async {
    // Verificar se o usuário está autenticado
    final fb.User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // Verificar se o livro pertence ao usuário atual
      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      if (!bookDoc.exists) {
        throw Exception('Livro não encontrado');
      }

      final bookData = bookDoc.data() as Map<String, dynamic>;
      if (bookData['ownerId'] != currentUser.uid) {
        throw Exception('Você só pode editar seus próprios livros');
      }

      // Atualizar os dados do livro
      await _firestore.collection('books').doc(bookId).update({
        'title': title,
        'author': author,
        'genre': genre,
        'description': description,
        'condition': condition,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'state': state,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notificar BookDataManager sobre mudanças nos livros
      await BookDataManager().notifyBookDataChanged();
    } catch (e) {
      throw Exception('Erro ao atualizar livro: $e');
    }
  }

  @override
  Future<void> deleteBook(String bookId) async {
    // Verificar se o usuário está autenticado
    final fb.User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // Verificar se o livro pertence ao usuário atual
      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      if (!bookDoc.exists) {
        throw Exception('Livro não encontrado');
      }

      final bookData = bookDoc.data() as Map<String, dynamic>;
      if (bookData['ownerId'] != currentUser.uid) {
        throw Exception('Você só pode excluir seus próprios livros');
      }

      // Verificar se o livro não está em nenhuma troca ativa
      final exchangesQuery = await _firestore
          .collection('exchanges')
          .where('proposerBookId', isEqualTo: bookId)
          .where('status', whereIn: ['pending', 'accepted'])
          .get();

      final receiverExchangesQuery = await _firestore
          .collection('exchanges')
          .where('receiverBookId', isEqualTo: bookId)
          .where('status', whereIn: ['pending', 'accepted'])
          .get();

      if (exchangesQuery.docs.isNotEmpty || receiverExchangesQuery.docs.isNotEmpty) {
        throw Exception('Não é possível excluir um livro que está em uma troca ativa');
      }

      // Deletar a imagem do storage se existir
      final imageUrl = bookData['imageUrl'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final storageService = StorageService();
          await storageService.deleteBookImage(imageUrl);
        } catch (e) {
          throw Exception('Erro ao deletar imagem do livro: $e');
        }
      }

      // Deletar o livro do Firestore
      await _firestore.collection('books').doc(bookId).delete();

      await BookDataManager().notifyBookDataChanged();
    } catch (e) {
      throw Exception('Erro ao excluir livro: $e');
    }
  }
}
