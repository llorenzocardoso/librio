import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception('Usuário não autenticado');

      final String fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final Reference ref =
          _storage.ref().child('profile_images').child(fileName);

      // Upload do arquivo
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      // Obter URL de download
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<String?> uploadBookImage(File imageFile) async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception('Usuário não autenticado');

      final String fileName =
          'book_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final Reference ref = _storage.ref().child('book_images').child(fileName);

      // Upload do arquivo
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      // Obter URL de download
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem do livro: $e');
    }
  }

  Future<bool> deleteProfileImage(String imageUrl) async {
    try {
      // Extrair o caminho da imagem da URL
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      throw Exception('Erro ao deletar imagem: $e');
    }
  }

  Future<bool> deleteBookImage(String imageUrl) async {
    try {
      // Extrair o caminho da imagem da URL
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      throw Exception('Erro ao deletar imagem do livro: $e');
    }
  }
}
