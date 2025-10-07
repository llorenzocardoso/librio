/// Configuração do Cloudinary para upload de imagens
///
/// Para obter suas credenciais:
/// 1. Acesse: https://cloudinary.com/users/register/free
/// 2. Após criar sua conta, vá para Dashboard
/// 3. Copie o Cloud Name
/// 4. Vá em Settings > Upload > Upload presets
/// 5. Crie um novo upload preset ou use o padrão "ml_default"
///    - Modo: Unsigned (para não precisar de API Secret no app)
///    - Folder: librio (opcional, para organizar as imagens)
///
/// IMPORTANTE: Mantenha este arquivo privado e não faça commit das credenciais reais!
class CloudinaryConfig {
  /// Nome da sua cloud no Cloudinary
  /// Exemplo: 'demo-cloud-name'
  static const String cloudName = 'dsc5nxkua';

  /// Upload preset para permitir uploads sem assinatura
  /// Exemplo: 'ml_default' ou 'librio_preset'
  static const String uploadPreset = 'librio_preset';

  /// Valida se as configurações foram definidas
  static bool get isConfigured =>
      cloudName != 'YOUR_CLOUD_NAME' && uploadPreset != 'YOUR_UPLOAD_PRESET';

  /// Retorna mensagem de erro se não configurado
  static String get errorMessage => '''
┌────────────────────────────────────────────────────────────────┐
│  🚨 CLOUDINARY NÃO CONFIGURADO                                 │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Por favor, configure suas credenciais do Cloudinary:          │
│                                                                 │
│  1. Abra: lib/src/config/cloudinary_config.dart               │
│  2. Substitua:                                                  │
│     - YOUR_CLOUD_NAME pelo seu Cloud Name                       │
│     - YOUR_UPLOAD_PRESET pelo seu Upload Preset                │
│                                                                 │
│  📖 Veja o guia completo: CLOUDINARY_SETUP.md                  │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
''';
}
