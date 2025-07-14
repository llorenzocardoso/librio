import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _chatsCollection => _firestore.collection('chats');
  CollectionReference get _messagesCollection =>
      _firestore.collection('messages');
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _exchangesCollection =>
      _firestore.collection('exchanges');

  @override
  Stream<List<Chat>> getUserChats(String userId) {
    return _chatsCollection
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Chat> chats = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Buscar informações dos participantes
        Map<String, dynamic> participantInfo = {};
        List<String> participantIds = List<String>.from(data['participantIds']);

        for (String participantId in participantIds) {
          if (participantId != userId) {
            try {
              final userDoc = await _usersCollection.doc(participantId).get();
              if (userDoc.exists) {
                final userData = userDoc.data() as Map<String, dynamic>;
                participantInfo[participantId] = {
                  'name': userData['name'] ?? 'Usuário',
                  'photoUrl': userData['photoUrl'],
                };
              }
            } catch (e) {
              participantInfo[participantId] = {
                'name': 'Usuário',
                'photoUrl': null,
              };
            }
          }
        }

        data['participantInfo'] = participantInfo;
        chats.add(ChatModel.fromFirestore(data, doc.id));
      }

      return chats;
    });
  }

  @override
  Future<Chat?> getChatById(String chatId) async {
    try {
      final doc = await _chatsCollection.doc(chatId).get();
      if (!doc.exists) return null;

      return ChatModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      throw Exception('Erro ao buscar chat: $e');
    }
  }

  @override
  Future<String> createOrGetChat(List<String> participantIds) async {
    try {

      // Validação básica
      if (participantIds.length != 2) {
        throw Exception('Chat deve ter exatamente 2 participantes');
      }

      if (participantIds[0] == participantIds[1]) {
        throw Exception('Participantes devem ser usuários diferentes');
      }

      // VALIDAÇÃO DE SEGURANÇA: Verificar se existe troca entre os usuários
      final user1 = participantIds[0];
      final user2 = participantIds[1];

      final hasValidExchange = await _hasExchangeBetweenUsers(user1, user2);
      if (!hasValidExchange) {
        throw Exception(
            'Não é possível criar chat: usuários não possuem trocas entre si');
      }

      // Ordenar IDs para facilitar a busca
      participantIds.sort();

      // Verificar se já existe um chat com esses participantes
      final existingChat = await _chatsCollection
          .where('participantIds', isEqualTo: participantIds)
          .limit(1)
          .get();

      if (existingChat.docs.isNotEmpty) {
        return existingChat.docs.first.id;
      }

      // Criar novo chat
      final now = DateTime.now();
      final chatData = {
        'participantIds': participantIds,
        'lastMessage': null,
        'lastMessageTime': now,
        'lastMessageSenderId': null,
        'unreadCount': {for (String id in participantIds) id: 0},
        'createdAt': now,
        'participantInfo': {},
      };

      final docRef = await _chatsCollection.add(chatData);
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar/buscar chat: $e');
    }
  }

  /// Verifica se existe uma troca válida entre dois usuários
  Future<bool> _hasExchangeBetweenUsers(String user1, String user2) async {
    try {
      // Buscar trocas onde user1 é proposer e user2 é receiver
      final query1 = await _exchangesCollection
          .where('proposerId', isEqualTo: user1)
          .where('receiverId', isEqualTo: user2)
          .limit(1)
          .get();

      if (query1.docs.isNotEmpty) {
        return true;
      }

      // Buscar trocas onde user2 é proposer e user1 é receiver
      final query2 = await _exchangesCollection
          .where('proposerId', isEqualTo: user2)
          .where('receiverId', isEqualTo: user1)
          .limit(1)
          .get();

      if (query2.docs.isNotEmpty) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateLastMessage(
      String chatId, String message, String senderId) async {
    try {
      final chatDoc = await _chatsCollection.doc(chatId).get();
      if (!chatDoc.exists) return;

      final chatData = chatDoc.data() as Map<String, dynamic>;
      final participantIds = List<String>.from(chatData['participantIds']);

      // Atualizar contador de não lidas
      Map<String, int> unreadCount =
          Map<String, int>.from(chatData['unreadCount'] ?? {});
      for (String participantId in participantIds) {
        if (participantId != senderId) {
          unreadCount[participantId] = (unreadCount[participantId] ?? 0) + 1;
        }
      }

      await _chatsCollection.doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': DateTime.now(),
        'lastMessageSenderId': senderId,
        'unreadCount': unreadCount,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar última mensagem: $e');
    }
  }

  @override
  Future<void> markAsRead(String chatId, String userId) async {
    try {
      final chatDoc = await _chatsCollection.doc(chatId).get();
      if (!chatDoc.exists) return;

      final chatData = chatDoc.data() as Map<String, dynamic>;
      Map<String, int> unreadCount =
          Map<String, int>.from(chatData['unreadCount'] ?? {});
      unreadCount[userId] = 0;

      await _chatsCollection.doc(chatId).update({
        'unreadCount': unreadCount,
      });
    } catch (e) {
      throw Exception('Erro ao marcar como lida: $e');
    }
  }

  @override
  Stream<List<Message>> getChatMessages(String chatId) {
    return _messagesCollection
        .where('chatId', isEqualTo: chatId)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs.map((doc) {
        return MessageModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Ordenar no cliente enquanto os índices são criados
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return messages;
    });
  }

  @override
  Future<Message> sendMessage(Message message) async {
    try {
      final messageData = MessageModel(
        id: '',
        chatId: message.chatId,
        senderId: message.senderId,
        content: message.content,
        type: message.type,
        timestamp: message.timestamp,
        isRead: message.isRead,
      ).toFirestore();

      final docRef = await _messagesCollection.add(messageData);

      // Atualizar última mensagem do chat
      await updateLastMessage(
          message.chatId, message.content, message.senderId);

      return MessageModel(
        id: docRef.id,
        chatId: message.chatId,
        senderId: message.senderId,
        content: message.content,
        type: message.type,
        timestamp: message.timestamp,
        isRead: message.isRead,
      );
    } catch (e) {
      throw Exception('Erro ao enviar mensagem: $e');
    }
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _messagesCollection.doc(messageId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Erro ao marcar mensagem como lida: $e');
    }
  }
}
