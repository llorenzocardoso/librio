import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseFirestore _firestore;
  final fb.FirebaseAuth _auth;

  NotificationService({
    FirebaseFirestore? firestore,
    fb.FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? fb.FirebaseAuth.instance;

  /// Marcar exchanges específicas como vistas
  Future<void> markExchangesAsViewed(List<String> exchangeIds) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docRef = _firestore.collection('notification_states').doc(user.uid);
      final doc = await docRef.get();

      List<String> currentViewed = [];
      if (doc.exists) {
        final data = doc.data()!;
        currentViewed = List<String>.from(data['viewedExchangeIds'] ?? []);
      }

      // Adicionar novos IDs sem duplicar
      final updatedViewed = {...currentViewed, ...exchangeIds}.toList();

      await docRef.set({
        'userId': user.uid,
        'viewedExchangeIds': updatedViewed,
        'lastViewed': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erro ao marcar notificações como vistas: $e');
    }
  }

  /// Marcar todas as notificações como vistas
  Future<void> markAllAsViewed() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('notification_states').doc(user.uid).set({
        'userId': user.uid,
        'viewedExchangeIds': [],
        'lastViewed': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erro ao marcar todas as notificações como vistas: $e');
    }
  }

  /// Obter exchanges que já foram vistas
  Future<List<String>> getViewedExchangeIds() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final doc = await _firestore
          .collection('notification_states')
          .doc(user.uid)
          .get();
      if (!doc.exists) return [];

      final data = doc.data()!;
      return List<String>.from(data['viewedExchangeIds'] ?? []);
    } catch (e) {
      debugPrint('Erro ao buscar notificações vistas: $e');
      return [];
    }
  }

  /// Obter timestamp da última visualização
  Future<DateTime?> getLastViewedTime() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('notification_states')
          .doc(user.uid)
          .get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final timestamp = data['lastViewed'] as Timestamp?;
      return timestamp?.toDate();
    } catch (e) {
      debugPrint('Erro ao buscar última visualização: $e');
      return null;
    }
  }
}
