import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/domain/repositories/exchange_repository.dart';
import 'package:librio/src/domain/entities/exchange.dart';
import 'package:librio/src/shared/shared.dart';

class ExchangeRepositoryImpl implements ExchangeRepository {
  final FirebaseFirestore _firestore;
  final fb.FirebaseAuth _auth;

  ExchangeRepositoryImpl({FirebaseFirestore? firestore, fb.FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? fb.FirebaseAuth.instance;

  @override
  Future<void> createExchange({
    required String proposerBookId,
    required String receiverBookId,
    required String receiverId,
    String? message,
  }) async {
    final fb.User? user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final proposerBookDoc =
        await _firestore.collection('books').doc(proposerBookId).get();
    final receiverBookDoc =
        await _firestore.collection('books').doc(receiverBookId).get();

    if (!proposerBookDoc.exists || !receiverBookDoc.exists) {
      throw Exception('Livro não encontrado');
    }

    final proposerBookData = proposerBookDoc.data()!;
    final receiverBookData = receiverBookDoc.data()!;

    final proposerName = user.displayName ?? user.email ?? 'Usuário';

    String receiverName = 'Usuário';
    try {
      // Tentar buscar do perfil do usuário receptor
      final receiverProfileDoc =
          await _firestore.collection('user_profiles').doc(receiverId).get();
      if (receiverProfileDoc.exists) {
        final receiverData = receiverProfileDoc.data() as Map<String, dynamic>;
        receiverName = receiverData['name'] ?? 'Usuário';
      } else {
        // Fallback para coleção users
        final receiverUserDoc =
            await _firestore.collection('users').doc(receiverId).get();
        if (receiverUserDoc.exists) {
          final receiverData = receiverUserDoc.data() as Map<String, dynamic>;
          receiverName = receiverData['name'] ?? 'Usuário';
        }
      }
    } catch (e) {
      receiverName = 'Usuário';
    }

    await _firestore.collection('exchanges').add({
      'proposerId': user.uid,
      'receiverId': receiverId,
      'proposerBookId': proposerBookId,
      'receiverBookId': receiverBookId,
      'proposerBookTitle': proposerBookData['title'],
      'receiverBookTitle': receiverBookData['title'],
      'proposerBookImageUrl': proposerBookData['imageUrl'] ?? '',
      'receiverBookImageUrl': receiverBookData['imageUrl'] ?? '',
      'proposerBookAuthor': proposerBookData['author'] ?? '',
      'receiverBookAuthor': receiverBookData['author'] ?? '',
      'proposerBookGenre': proposerBookData['genre'] ?? '',
      'receiverBookGenre': receiverBookData['genre'] ?? '',
      'proposerBookCondition': proposerBookData['condition'] ?? '',
      'receiverBookCondition': receiverBookData['condition'] ?? '',
      'proposerName': proposerName,
      'receiverName': receiverName,
      'status': ExchangeStatus.pending.name,
      'message': message,
      'proposerConfirmed': false,
      'receiverConfirmed': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<Exchange>> getUserExchanges(String userId) async {
    final proposerQuery = await _firestore
        .collection('exchanges')
        .where('proposerId', isEqualTo: userId)
        .get();

    final receiverQuery = await _firestore
        .collection('exchanges')
        .where('receiverId', isEqualTo: userId)
        .get();

    final allDocs = [...proposerQuery.docs, ...receiverQuery.docs];

    final exchanges = <Exchange>[];
    for (final doc in allDocs) {
      final exchange = await _mapDocumentToExchange(doc);
      exchanges.add(exchange);
    }

    return exchanges..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> updateExchangeStatus(
      String exchangeId, ExchangeStatus status) async {
    await _firestore.collection('exchanges').doc(exchangeId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Exchange?> getExchangeById(String exchangeId) async {
    final doc = await _firestore.collection('exchanges').doc(exchangeId).get();
    if (!doc.exists) return null;
    return await _mapDocumentToExchange(doc);
  }

  @override
  Future<void> confirmExchangeCompletion(
      String exchangeId, String userId) async {
    final doc = await _firestore.collection('exchanges').doc(exchangeId).get();
    if (!doc.exists) throw Exception('Troca não encontrada');

    final data = doc.data()!;
    final proposerId = data['proposerId'];
    final receiverId = data['receiverId'];

    bool proposerConfirmed = data['proposerConfirmed'] ?? false;
    bool receiverConfirmed = data['receiverConfirmed'] ?? false;
    DateTime? proposerConfirmedAt = data['proposerConfirmedAt'] != null
        ? (data['proposerConfirmedAt'] as Timestamp).toDate()
        : null;
    DateTime? receiverConfirmedAt = data['receiverConfirmedAt'] != null
        ? (data['receiverConfirmedAt'] as Timestamp).toDate()
        : null;

    final now = DateTime.now();

    if (userId == proposerId && !proposerConfirmed) {
      proposerConfirmed = true;
      proposerConfirmedAt = now;
    } else if (userId == receiverId && !receiverConfirmed) {
      receiverConfirmed = true;
      receiverConfirmedAt = now;
    }

    if (!proposerConfirmed && receiverConfirmedAt != null) {
      final hoursSinceReceiverConfirmed =
          now.difference(receiverConfirmedAt).inHours;
      if (hoursSinceReceiverConfirmed >= 48) {
        proposerConfirmed = true;
        proposerConfirmedAt = now;
      }
    }

    if (!receiverConfirmed && proposerConfirmedAt != null) {
      final hoursSinceProposerConfirmed =
          now.difference(proposerConfirmedAt).inHours;
      if (hoursSinceProposerConfirmed >= 48) {
        receiverConfirmed = true;
        receiverConfirmedAt = now;
      }
    }

    final bothConfirmed = proposerConfirmed && receiverConfirmed;
    final newStatus =
        bothConfirmed ? ExchangeStatus.completed : ExchangeStatus.accepted;

    await _firestore.collection('exchanges').doc(exchangeId).update({
      'proposerConfirmed': proposerConfirmed,
      'receiverConfirmed': receiverConfirmed,
      'proposerConfirmedAt': proposerConfirmedAt != null
          ? Timestamp.fromDate(proposerConfirmedAt)
          : null,
      'receiverConfirmedAt': receiverConfirmedAt != null
          ? Timestamp.fromDate(receiverConfirmedAt)
          : null,
      'status': newStatus.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'completedAt': bothConfirmed ? FieldValue.serverTimestamp() : null,
    });

    if (bothConfirmed) {
      await _firestore.collection('books').doc(data['proposerBookId']).delete();
      await _firestore.collection('books').doc(data['receiverBookId']).delete();

      await _incrementExchangeCount(proposerId);
      await _incrementExchangeCount(receiverId);

      await BookDataManager().notifyBookDataChanged();

      UserProfileManager().notifyProfileChanged();
    } else {}
  }

  Future<void> _incrementExchangeCount(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final currentCount = userDoc.data()?['exchangeCount'] ?? 0;
        final newCount = currentCount + 1;

        await _firestore.collection('users').doc(userId).update({
          'exchangeCount': newCount,
        });
      }

      final userProfileDoc =
          await _firestore.collection('user_profiles').doc(userId).get();
      if (userProfileDoc.exists) {
        final currentCount = userProfileDoc.data()?['exchangeCount'] ?? 0;
        final newCount = currentCount + 1;

        await _firestore.collection('user_profiles').doc(userId).update({
          'exchangeCount': newCount,
        });
      } else {
        final userData =
            userDoc.exists ? userDoc.data() as Map<String, dynamic> : {};
        final initialCount = (userData['exchangeCount'] ?? 0) + 1;

        // Tentar obter nome mais apropriado
        String userName = userData['name'] ?? 'Usuário';
        String userEmail = userData['email'] ?? '';
        String userPhotoUrl = userData['photoUrl'] ?? '';

        // Se não há dados locais, tentar do Firebase Auth
        if (userName == 'Usuário' || userName.isEmpty) {
          try {
            final user = _auth.currentUser;
            if (user != null && user.uid == userId) {
              userName =
                  user.displayName ?? user.email?.split('@')[0] ?? 'Usuário';
              userEmail = user.email ?? userEmail;
              userPhotoUrl = user.photoURL ?? userPhotoUrl;
            }
          } catch (e) {
            // Ignorar erros do Firebase Auth
          }
        }

        await _firestore.collection('user_profiles').doc(userId).set({
          'name': userName,
          'email': userEmail,
          'description': userData['description'] ?? '',
          'averageRating': userData['averageRating'] ?? 0.0,
          'ratingCount': userData['ratingCount'] ?? 0,
          'exchangeCount': initialCount,
          'photoUrl': userPhotoUrl,
          'ratings': userData['ratings'] ?? [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Método para corrigir nomes de usuários em trocas existentes
  Future<void> fixExistingExchangeNames() async {
    try {
      final exchangesSnapshot = await _firestore.collection('exchanges').get();

      for (final doc in exchangesSnapshot.docs) {
        final data = doc.data();
        bool needsUpdate = false;
        final Map<String, dynamic> updateData = {};

        // Verificar se precisa atualizar o nome do proposer
        if (data['proposerName'] == null ||
            data['proposerName'] == 'Usuário' ||
            data['proposerName'].isEmpty) {
          final proposerName = await _getUserName(data['proposerId']);
          if (proposerName != 'Usuário') {
            updateData['proposerName'] = proposerName;
            needsUpdate = true;
          }
        }

        // Verificar se precisa atualizar o nome do receiver
        if (data['receiverName'] == null ||
            data['receiverName'] == 'Usuário' ||
            data['receiverName'].isEmpty) {
          final receiverName = await _getUserName(data['receiverId']);
          if (receiverName != 'Usuário') {
            updateData['receiverName'] = receiverName;
            needsUpdate = true;
          }
        }

        if (needsUpdate) {
          await _firestore
              .collection('exchanges')
              .doc(doc.id)
              .update(updateData);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Método auxiliar para buscar o nome de um usuário
  Future<String> _getUserName(String userId) async {
    try {
      // Tentar buscar do perfil do usuário
      final userProfileDoc =
          await _firestore.collection('user_profiles').doc(userId).get();
      if (userProfileDoc.exists) {
        final userData = userProfileDoc.data() as Map<String, dynamic>;
        final name = userData['name'];
        if (name != null && name.isNotEmpty && name != 'Usuário') {
          return name;
        }
      }

      // Fallback para coleção users
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final name = userData['name'];
        if (name != null && name.isNotEmpty && name != 'Usuário') {
          return name;
        }
      }

      return 'Usuário';
    } catch (e) {
      return 'Usuário';
    }
  }

  Future<Exchange> _mapDocumentToExchange(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    // Verificar se os nomes estão presentes e válidos, se não buscar novamente
    String proposerName = data['proposerName'] ?? 'Usuário';
    String receiverName = data['receiverName'] ?? 'Usuário';

    if (proposerName == 'Usuário' || proposerName.isEmpty) {
      proposerName = await _getUserName(data['proposerId']);
    }

    if (receiverName == 'Usuário' || receiverName.isEmpty) {
      receiverName = await _getUserName(data['receiverId']);
    }

    return Exchange(
      id: doc.id,
      proposerId: data['proposerId'],
      receiverId: data['receiverId'],
      proposerBookId: data['proposerBookId'],
      receiverBookId: data['receiverBookId'],
      proposerBookTitle: data['proposerBookTitle'],
      receiverBookTitle: data['receiverBookTitle'],
      proposerBookImageUrl: data['proposerBookImageUrl'] ?? '',
      receiverBookImageUrl: data['receiverBookImageUrl'] ?? '',
      proposerBookAuthor: data['proposerBookAuthor'] ?? '',
      receiverBookAuthor: data['receiverBookAuthor'] ?? '',
      proposerBookGenre: data['proposerBookGenre'] ?? '',
      receiverBookGenre: data['receiverBookGenre'] ?? '',
      proposerBookCondition: data['proposerBookCondition'] ?? '',
      receiverBookCondition: data['receiverBookCondition'] ?? '',
      proposerName: proposerName,
      receiverName: receiverName,
      status: ExchangeStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ExchangeStatus.pending,
      ),
      message: data['message'],
      proposerConfirmed: data['proposerConfirmed'] ?? false,
      receiverConfirmed: data['receiverConfirmed'] ?? false,
      proposerConfirmedAt:
          (data['proposerConfirmedAt'] as Timestamp?)?.toDate(),
      receiverConfirmedAt:
          (data['receiverConfirmedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}
