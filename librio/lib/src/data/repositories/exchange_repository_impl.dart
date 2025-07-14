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

    // Buscar informações dos livros e usuários
    final proposerBookDoc =
        await _firestore.collection('books').doc(proposerBookId).get();
    final receiverBookDoc =
        await _firestore.collection('books').doc(receiverBookId).get();

    if (!proposerBookDoc.exists || !receiverBookDoc.exists) {
      throw Exception('Livro não encontrado');
    }

    final proposerBookData = proposerBookDoc.data()!;
    final receiverBookData = receiverBookDoc.data()!;

    // Buscar informações dos usuários (assumindo que temos displayName no auth)
    final proposerName = user.displayName ?? user.email ?? 'Usuário';

    // Buscar nome do receiver (por enquanto usando um valor padrão)
    String receiverName = 'Usuário';
    try {
      // Aqui você pode implementar uma busca no perfil do usuário se necessário
      receiverName = 'Usuário';
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
    // Buscar trocas onde o usuário é proposer ou receiver
    final proposerQuery = await _firestore
        .collection('exchanges')
        .where('proposerId', isEqualTo: userId)
        .get();

    final receiverQuery = await _firestore
        .collection('exchanges')
        .where('receiverId', isEqualTo: userId)
        .get();

    final allDocs = [...proposerQuery.docs, ...receiverQuery.docs];

    return allDocs.map((doc) => _mapDocumentToExchange(doc)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
    return _mapDocumentToExchange(doc);
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

    // Marcar confirmação do usuário atual
    if (userId == proposerId && !proposerConfirmed) {
      proposerConfirmed = true;
      proposerConfirmedAt = now;
    } else if (userId == receiverId && !receiverConfirmed) {
      receiverConfirmed = true;
      receiverConfirmedAt = now;
    }

    // Verificar auto-confirmação por timeout (48h após primeira confirmação)
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

    // Verificar se ambos confirmaram
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
      // EXCLUIR os livros da base de dados (não apenas marcar como indisponível)
      await _firestore.collection('books').doc(data['proposerBookId']).delete();
      await _firestore.collection('books').doc(data['receiverBookId']).delete();

      // Incrementar contador de trocas para ambos os usuários
      await _incrementExchangeCount(proposerId);
      await _incrementExchangeCount(receiverId);

      // Notificar BookDataManager sobre mudanças nos livros
      await BookDataManager().notifyBookDataChanged();
    } else {
    }
  }

  Future<void> _incrementExchangeCount(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return;
      }

      final currentCount = userDoc.data()?['exchangeCount'] ?? 0;
      final newCount = currentCount + 1;

      await _firestore.collection('users').doc(userId).update({
        'exchangeCount': newCount,
      });

      // Verificar se foi atualizado corretamente
      final updatedDoc = await _firestore.collection('users').doc(userId).get();
      final finalCount = updatedDoc.data()?['exchangeCount'] ?? 0;
    } catch (e) {
      rethrow;
    }
  }

  Exchange _mapDocumentToExchange(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
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
      proposerName: data['proposerName'],
      receiverName: data['receiverName'],
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
