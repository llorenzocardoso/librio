import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get usersCollection => _firestore.collection('users');

  Future<DocumentReference?> addUser(Map<String, dynamic> userData) async {
    try {
      return await usersCollection.add(userData);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<DocumentSnapshot?> getUser(String userId) async {
    try {
      return await usersCollection.doc(userId).get();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await usersCollection.doc(userId).update(userData);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await usersCollection.doc(userId).delete();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addBook(String userId, Map<String, dynamic> bookData) async {
    try {
      await usersCollection.doc(userId).collection('books').add(bookData);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateBook(String userId, String bookId, Map<String, dynamic> bookData) async {
    try {
      await usersCollection.doc(userId).collection('books').doc(bookId).update(bookData);
    } catch (e) {
      throw Exception(e);
    }
  }

}
