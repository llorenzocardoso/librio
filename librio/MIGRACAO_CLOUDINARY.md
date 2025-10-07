# 🔄 Migração Firebase Storage → Cloudinary

Este documento descreve a migração do sistema de armazenamento de imagens do Firebase Storage para o Cloudinary.

---

## 📊 Comparação

| Feature | Firebase Storage | Cloudinary |
|---------|------------------|------------|
| **Armazenamento Free** | 5 GB | 25 GB |
| **Bandwidth Free** | 1 GB/dia | 25 GB/mês |
| **CDN** | ✅ Sim | ✅ Sim (Cloudflare) |
| **Otimização Automática** | ❌ Não | ✅ Sim |
| **Transformações** | ❌ Não | ✅ Sim (on-the-fly) |
| **URLs Públicas** | ⚠️ Requer config | ✅ Por padrão |
| **Facilidade de Setup** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 🎯 Motivação da Mudança

### Problemas com Firebase Storage

1. **Erro 412 (Precondition Failed)**:
   - Storage rules exigiam autenticação para ler imagens
   - URLs de download não passavam token de auth automaticamente
   - Usuários não conseguiam ver capas de livros de outros usuários

2. **Limites Restritivos**:
   - Apenas 5 GB de armazenamento gratuito
   - Apenas 1 GB/dia de bandwidth (muito limitado)

3. **Falta de Otimização**:
   - Imagens armazenadas no tamanho original
   - Sem compressão automática
   - Sem suporte a formatos modernos (WebP)

### Vantagens do Cloudinary

1. **25 GB** de armazenamento gratuito (5x mais!)
2. **25 GB/mês** de bandwidth (muito mais generoso)
3. **Otimização automática** de imagens
4. **CDN global** com Cloudflare
5. **Transformações on-the-fly** sem armazenar múltiplas versões
6. **URLs públicas** por padrão (sem problemas de permissão)

---

## 🔧 Mudanças Implementadas

### 1. Novo Serviço de Storage

Criado `CloudinaryStorageService` que substitui `StorageService`:

```dart
// Antes (Firebase)
final storageService = StorageService();
final url = await storageService.uploadBookImage(imageFile);

// Depois (Cloudinary)
final storageService = CloudinaryStorageService();
final url = await storageService.uploadBookImage(imageFile);
```

**A interface é idêntica!** Não é necessário mudar lógica de negócio.

### 2. Arquivos Modificados

#### Novos Arquivos Criados:
- ✅ `lib/src/data/datasources/cloudinary_storage_service.dart`
- ✅ `lib/src/config/cloudinary_config.dart`
- ✅ `lib/src/config/cloudinary_config.dart.example`
- ✅ `CLOUDINARY_SETUP.md`
- ✅ `MIGRACAO_CLOUDINARY.md`

#### Arquivos Atualizados:
- ✅ `pubspec.yaml` - Adicionado `cloudinary_public: ^0.21.0`
- ✅ `lib/src/data/datasources/datasources.dart` - Export do novo serviço
- ✅ `lib/src/presentation/home/screens/add_book/add_book_viewmodel.dart`
- ✅ `lib/src/presentation/home/screens/edit_book/edit_book_viewmodel.dart`
- ✅ `lib/src/presentation/home/screens/profile/profile_viewmodel.dart`
- ✅ `lib/src/presentation/home/screens/edit_profile/edit_profile_viewmodel.dart`
- ✅ `lib/src/data/repositories/book_repository_impl.dart`

### 3. Estrutura de Pastas no Cloudinary

```
cloudinary.com/seu-cloud-name/
├── librio/
│   ├── profiles/
│   │   └── profile_{userId}_{timestamp}.jpg
│   └── books/
│       └── book_{userId}_{timestamp}.jpg
```

---

## 📝 Nomenclatura de Arquivos

### Imagens de Perfil
```
Padrão: profile_{userId}_{timestamp}
Exemplo: profile_abc123xyz_1234567890.jpg
```

### Imagens de Livros
```
Padrão: book_{userId}_{timestamp}
Exemplo: book_abc123xyz_1234567890.jpg
```

---

## 🚀 Como Configurar

### Passo 1: Criar Conta Cloudinary

1. Acesse: https://cloudinary.com/users/register/free
2. Crie sua conta gratuita
3. Anote seu **Cloud Name** do Dashboard

### Passo 2: Criar Upload Preset

1. Settings → Upload → Upload presets
2. Clique em "Add upload preset"
3. Configure:
   - **Preset name**: `librio_preset`
   - **Signing Mode**: **Unsigned** ⚠️
   - **Folder**: `librio`
4. Salve

### Passo 3: Configurar no App

Edite `lib/src/config/cloudinary_config.dart`:

```dart
class CloudinaryConfig {
  static const String cloudName = 'seu-cloud-name'; // ← Seu Cloud Name
  static const String uploadPreset = 'librio_preset'; // ← Seu Preset
  // ...
}
```

### Passo 4: Instalar Dependências

```bash
flutter pub get
```

### Passo 5: Testar

Execute o app e teste:
- ✅ Upload de foto de perfil
- ✅ Upload de imagem de livro
- ✅ Visualização das imagens
- ✅ Deleção de livro (deve remover imagem)

---

## 🔄 Migração de Dados Existentes (Opcional)

Se você já tem imagens no Firebase Storage e quer migrá-las para o Cloudinary:

### Script de Migração (Node.js)

```javascript
// migrate-images.js
const admin = require('firebase-admin');
const cloudinary = require('cloudinary').v2;
const axios = require('axios');

// Configurar Firebase
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  storageBucket: 'seu-bucket.appspot.com'
});

// Configurar Cloudinary
cloudinary.config({
  cloud_name: 'seu-cloud-name',
  api_key: 'sua-api-key',
  api_secret: 'sua-api-secret'
});

async function migrateImages() {
  const db = admin.firestore();
  const books = await db.collection('books').get();

  for (const doc of books.docs) {
    const book = doc.data();

    if (book.imageUrl && book.imageUrl.includes('firebasestorage')) {
      try {
        // Upload para Cloudinary
        const result = await cloudinary.uploader.upload(book.imageUrl, {
          folder: 'librio/books',
          public_id: `book_${book.ownerId}_${Date.now()}`
        });

        // Atualizar Firestore com nova URL
        await doc.ref.update({
          imageUrl: result.secure_url
        });

        console.log(`✅ Migrado: ${doc.id}`);
      } catch (error) {
        console.error(`❌ Erro: ${doc.id}`, error);
      }
    }
  }

  console.log('🎉 Migração concluída!');
}

migrateImages();
```

**Executar:**
```bash
npm install firebase-admin cloudinary axios
node migrate-images.js
```

---

## ⚠️ Notas Importantes

### Segurança

1. **Não faça commit** do arquivo `cloudinary_config.dart` com credenciais reais
2. Adicione ao `.gitignore`:
   ```gitignore
   # Cloudinary Config
   lib/src/config/cloudinary_config.dart
   ```
3. Use o arquivo `.example` para compartilhar template

### Compatibilidade

- ✅ **StorageService antigo ainda funciona** (marcado como deprecated)
- ✅ URLs antigas do Firebase continuam funcionando
- ✅ Migração gradual é possível
- ✅ Rollback fácil se necessário

### Custos

O plano gratuito do Cloudinary é mais que suficiente para um app pequeno/médio:

| Métrica | Limite Free | Estimativa de Uso |
|---------|-------------|-------------------|
| Armazenamento | 25 GB | ~50.000 imagens de 500KB |
| Bandwidth | 25 GB/mês | ~50.000 visualizações/mês |
| Transformações | 25.000/mês | Mais que suficiente |

---

## 📊 Monitoramento

Para monitorar o uso:

1. Acesse o Dashboard do Cloudinary
2. Veja o painel **Usage**
3. Configure alertas se chegar perto do limite

---

## 🆘 Rollback (Se Necessário)

Se precisar voltar para Firebase Storage:

1. Reverta os arquivos modificados:
   ```bash
   git revert HEAD~1
   ```

2. Ou simplesmente troque de volta nos ViewModels:
   ```dart
   // Voltar para Firebase
   _storageService = storageService ?? StorageService()
   ```

---

## ✅ Checklist de Migração

- [x] Pacote `cloudinary_public` adicionado
- [x] `CloudinaryStorageService` criado
- [x] Arquivo de configuração criado
- [x] ViewModels atualizados
- [x] Repository atualizado
- [x] Documentação criada
- [ ] Configurar credenciais do Cloudinary
- [ ] Testar upload de imagem de perfil
- [ ] Testar upload de imagem de livro
- [ ] Testar deleção de livro
- [ ] (Opcional) Migrar dados existentes

---

## 📚 Recursos Úteis

- [Documentação Cloudinary](https://cloudinary.com/documentation)
- [Flutter Package](https://pub.dev/packages/cloudinary_public)
- [Upload Presets Guide](https://cloudinary.com/documentation/upload_presets)
- [Image Transformations](https://cloudinary.com/documentation/image_transformations)

---

**Migração implementada com sucesso!** 🎉

Se tiver dúvidas, consulte `CLOUDINARY_SETUP.md` para instruções detalhadas de configuração.
