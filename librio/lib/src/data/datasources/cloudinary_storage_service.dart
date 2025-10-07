import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:librio/src/config/cloudinary_config.dart';

/// Serviço de armazenamento de imagens usando Cloudinary
///
/// Cloudinary Free Tier:
/// - 25 GB de armazenamento
/// - 25 GB de bandwidth/mês
/// - Otimização automática de imagens
/// - CDN global incluído
/// - Transformações de imagem on-the-fly
///
/// Configuração:
/// Edite lib/src/config/cloudinary_config.dart com suas credenciais
class CloudinaryStorageService {
  final CloudinaryPublic _cloudinary;
  final FirebaseAuth _auth;

  CloudinaryStorageService({FirebaseAuth? auth})
      : _cloudinary = CloudinaryPublic(
          CloudinaryConfig.cloudName,
          CloudinaryConfig.uploadPreset,
        ),
        _auth = auth ?? FirebaseAuth.instance {
    // Validar credenciais
    if (!CloudinaryConfig.isConfigured) {
      throw Exception(CloudinaryConfig.errorMessage);
    }
  }

  /// Upload de imagem de perfil do usuário
  ///
  /// As imagens são armazenadas com o padrão:
  /// - Folder: librio/profiles
  /// - Nome: profile_{userId}_{timestamp}
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception('Usuário não autenticado');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicId = 'librio/profiles/profile_${userId}_$timestamp';

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'librio/profiles',
          publicId: publicId,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      // Retorna a URL segura da imagem
      return response.secureUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem de perfil: $e');
    }
  }

  /// Upload de imagem de capa de livro
  ///
  /// As imagens são armazenadas com o padrão:
  /// - Folder: librio/books
  /// - Nome: book_{userId}_{timestamp}
  Future<String?> uploadBookImage(File imageFile) async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception('Usuário não autenticado');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicId = 'librio/books/book_${userId}_$timestamp';

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'librio/books',
          publicId: publicId,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      // Retorna a URL segura da imagem
      return response.secureUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem do livro: $e');
    }
  }

  /// Deleta uma imagem de perfil do Cloudinary
  ///
  /// ⚠️ NOTA: O pacote cloudinary_public não suporta deleção.
  /// As imagens continuarão no Cloudinary mas não afetarão o app.
  ///
  /// Opções para deletar:
  /// 1. Manualmente via Dashboard do Cloudinary
  /// 2. Configurar Auto-deletion policy no Cloudinary
  /// 3. Usar a API Admin do Cloudinary (requer API Secret no backend)
  Future<bool> deleteProfileImage(String imageUrl) async {
    try {
      // O pacote cloudinary_public não suporta deleção
      // A imagem permanecerá no Cloudinary mas não será referenciada no app
      // Isso não afeta o funcionamento e a imagem pode ser deletada manualmente
      print('⚠️ Imagem não deletada do Cloudinary: $imageUrl');
      print(
          '💡 Dica: Delete manualmente via Dashboard do Cloudinary se necessário');
      return true;
    } catch (e) {
      print('Erro ao processar deleção de imagem: $e');
      return true; // Não falhar mesmo que não consiga deletar
    }
  }

  /// Deleta uma imagem de livro do Cloudinary
  ///
  /// ⚠️ NOTA: O pacote cloudinary_public não suporta deleção.
  /// As imagens continuarão no Cloudinary mas não afetarão o app.
  ///
  /// Opções para deletar:
  /// 1. Manualmente via Dashboard do Cloudinary
  /// 2. Configurar Auto-deletion policy no Cloudinary
  /// 3. Usar a API Admin do Cloudinary (requer API Secret no backend)
  Future<bool> deleteBookImage(String imageUrl) async {
    try {
      // O pacote cloudinary_public não suporta deleção
      // A imagem permanecerá no Cloudinary mas não será referenciada no app
      // Isso não afeta o funcionamento e a imagem pode ser deletada manualmente
      print('⚠️ Imagem não deletada do Cloudinary: $imageUrl');
      print(
          '💡 Dica: Delete manualmente via Dashboard do Cloudinary se necessário');
      return true;
    } catch (e) {
      print('Erro ao processar deleção de imagem: $e');
      return true; // Não falhar mesmo que não consiga deletar
    }
  }

  /// Retorna uma URL de imagem otimizada com transformações do Cloudinary
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final optimizedUrl = getOptimizedImageUrl(
  ///   originalUrl,
  ///   width: 300,
  ///   height: 400,
  ///   quality: 80,
  /// );
  /// ```
  String getOptimizedImageUrl(
    String originalUrl, {
    int? width,
    int? height,
    int? quality,
    String? format,
  }) {
    try {
      final uri = Uri.parse(originalUrl);
      final pathSegments = uri.pathSegments.toList();

      // Encontrar o índice de 'upload'
      final uploadIndex =
          pathSegments.indexWhere((segment) => segment == 'upload');

      if (uploadIndex == -1) {
        return originalUrl;
      }

      // Construir transformações
      final transformations = <String>[];

      if (width != null) transformations.add('w_$width');
      if (height != null) transformations.add('h_$height');
      if (quality != null) transformations.add('q_$quality');
      if (format != null) transformations.add('f_$format');

      // Adicionar transformações padrão para otimização
      transformations.addAll(['c_fill', 'g_auto']);

      if (transformations.isEmpty) {
        return originalUrl;
      }

      // Inserir transformações após 'upload'
      pathSegments.insert(uploadIndex + 1, transformations.join(','));

      return uri.replace(pathSegments: pathSegments).toString();
    } catch (e) {
      print('Erro ao otimizar URL da imagem: $e');
      return originalUrl;
    }
  }
}
