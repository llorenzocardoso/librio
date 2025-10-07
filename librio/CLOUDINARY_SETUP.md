# 📸 Guia de Configuração do Cloudinary

Este guia mostra como configurar o **Cloudinary** para armazenamento de imagens no Librio, substituindo o Firebase Storage.

---

## 🎯 Por que Cloudinary?

- ✅ **25 GB** de armazenamento gratuito
- ✅ **25 GB** de bandwidth/mês
- ✅ **Otimização automática** de imagens
- ✅ **CDN global** incluído
- ✅ **Transformações on-the-fly** (resize, crop, etc)
- ✅ URLs públicas por padrão
- ✅ Fácil integração com Flutter

---

## 📋 Passo a Passo

### 1. Criar Conta no Cloudinary

1. Acesse: [https://cloudinary.com/users/register/free](https://cloudinary.com/users/register/free)
2. Preencha os dados e crie sua conta gratuita
3. Após o login, você será direcionado para o **Dashboard**

### 2. Obter o Cloud Name

No Dashboard do Cloudinary, você verá:

```
Cloud name: seu-cloud-name
```

**Copie esse valor!** Você vai precisar dele.

### 3. Criar Upload Preset (Unsigned)

Para permitir uploads direto do app sem expor sua API Secret:

1. No Dashboard, clique em **Settings** (⚙️ no canto superior direito)
2. Vá para a aba **Upload**
3. Role até **Upload presets**
4. Clique em **Add upload preset**
5. Configure:
   - **Preset name**: `librio_preset` (ou outro nome de sua escolha)
   - **Signing Mode**: Selecione **Unsigned** ⚠️ IMPORTANTE!
   - **Folder**: `librio` (opcional, para organizar as imagens)
   - **Use filename**: Yes (opcional)
   - **Unique filename**: Yes (recomendado)
6. Clique em **Save**

Agora você tem seu **Upload Preset Name**: `librio_preset`

### 4. Configurar no App

Abra o arquivo `lib/src/config/cloudinary_config.dart` e substitua:

```dart
class CloudinaryConfig {
  // Substitua pelo seu Cloud Name
  static const String cloudName = 'seu-cloud-name';

  // Substitua pelo nome do Upload Preset que você criou
  static const String uploadPreset = 'librio_preset';

  // ... resto do código
}
```

### 5. Instalar Dependências

```bash
flutter pub get
```

### 6. Testar

Execute o app e tente fazer upload de uma imagem:

1. Adicionar um novo livro
2. Selecione uma imagem
3. Se tudo estiver configurado corretamente, a imagem será enviada para o Cloudinary! 🎉

---

## 🔍 Verificando Uploads

Para ver as imagens enviadas:

1. Acesse o **Dashboard** do Cloudinary
2. Clique em **Media Library** no menu lateral
3. Você verá todas as imagens organizadas em:
   - `librio/books/` - Capas de livros
   - `librio/profiles/` - Fotos de perfil

---

## 🔒 Segurança

### ⚠️ IMPORTANTE: Não faça commit das credenciais!

Se você estiver usando Git, adicione ao `.gitignore`:

```gitignore
# Cloudinary Config
lib/src/config/cloudinary_config.dart
```

Para compartilhar o projeto, crie um arquivo `cloudinary_config.dart.example`:

```dart
class CloudinaryConfig {
  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String uploadPreset = 'YOUR_UPLOAD_PRESET';
  // ...
}
```

---

## 🎨 Recursos Avançados (Opcional)

### Otimização de Imagens

O `CloudinaryStorageService` já inclui um método para otimizar imagens:

```dart
final optimizedUrl = cloudinaryService.getOptimizedImageUrl(
  originalUrl,
  width: 300,
  height: 400,
  quality: 80,
  format: 'webp', // Formato moderno mais leve
);

// Use essa URL otimizada no Image.network()
Image.network(optimizedUrl)
```

### Transformações Disponíveis

Você pode adicionar transformações diretamente na URL:

```dart
// Exemplo: Redimensionar para 300x300 e converter para WebP
final url = cloudinaryService.getOptimizedImageUrl(
  originalUrl,
  width: 300,
  height: 300,
  quality: 85,
  format: 'webp',
);
```

### Thumbnails Automáticos

No código, você pode criar thumbnails facilmente:

```dart
// Thumbnail pequeno para lista
final thumbUrl = getOptimizedImageUrl(
  book.imageUrl,
  width: 150,
  height: 200,
  quality: 70,
);

// Imagem completa para detalhes
final fullUrl = getOptimizedImageUrl(
  book.imageUrl,
  width: 800,
  height: 1200,
  quality: 90,
);
```

---

## ❓ Solução de Problemas

### Erro: "Configure suas credenciais do Cloudinary"

- Verifique se você editou o arquivo `cloudinary_config.dart`
- Certifique-se de substituir `YOUR_CLOUD_NAME` e `YOUR_UPLOAD_PRESET`
- Execute `flutter pub get` novamente

### Erro 401 Unauthorized

- Verifique se o **Upload Preset** está configurado como **Unsigned**
- Confirme que o nome do preset está correto

### Imagens não aparecem

- Verifique a URL gerada no console/logs
- Acesse a URL diretamente no navegador
- Verifique se o upload foi feito com sucesso no Media Library do Cloudinary

### Upload muito lento

- Reduza o tamanho das imagens antes do upload
- Considere comprimir as imagens localmente antes de enviar

---

## 📊 Monitorando Uso

Para monitorar seu uso gratuito:

1. Acesse o **Dashboard** do Cloudinary
2. Veja o painel **Usage** no topo
3. Você pode ver:
   - Armazenamento usado
   - Bandwidth usado no mês
   - Transformações realizadas

---

## 🚀 Próximos Passos

Agora que o Cloudinary está configurado:

1. ✅ Teste fazer upload de uma imagem de livro
2. ✅ Teste fazer upload de foto de perfil
3. ✅ Teste deletar um livro (deve remover a imagem do Cloudinary)
4. 📖 Explore os recursos de otimização automática
5. 🎨 Experimente transformações de imagem

---

## 📚 Recursos Adicionais

- [Documentação Oficial do Cloudinary](https://cloudinary.com/documentation)
- [Upload Presets Guide](https://cloudinary.com/documentation/upload_presets)
- [Flutter Package: cloudinary_public](https://pub.dev/packages/cloudinary_public)
- [Image Transformations](https://cloudinary.com/documentation/image_transformations)

---

## 🆘 Suporte

Se tiver problemas:

1. Consulte a [documentação oficial](https://cloudinary.com/documentation)
2. Verifique os logs do console para mensagens de erro específicas
3. Abra uma issue no repositório do projeto

---

**Configuração concluída!** 🎉

Seu app agora está usando o Cloudinary para armazenar imagens de forma gratuita e eficiente!
