# Instalação e Configuração do Projeto

Este guia cobrirá a instalação completa do projeto Librio, desde o clone do repositório até a execução local.

## 📦 Clonando o Repositório

```bash
# Clone o repositório
git clone https://github.com/your-username/librio.git
cd librio

# Verificar branch atual
git branch
```

## 🔧 Instalação de Dependências

### 1. Dependências Flutter

```bash
# Instalar todas as dependências do pubspec.yaml
flutter pub get

# Verificar dependências desatualizadas
flutter pub outdated
```

### 2. Dependências Principais

O projeto utiliza as seguintes dependências principais:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^2.27.0
  cloud_firestore: ^4.15.8
  firebase_auth: ^4.17.8

  # Navegação
  go_router: ^13.2.0

  # UI & Styling
  cupertino_icons: ^1.0.2
  flutter_svg: ^2.0.5

  # Utilitários
  intl: ^0.19.0
```

### 3. Dependências de Desenvolvimento

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

## 🔥 Configuração do Firebase

### 1. Configuração do Projeto Firebase

1. **Criar projeto no Firebase Console:**
   - Acesse [Firebase Console](https://console.firebase.google.com)
   - Clique em "Adicionar projeto"
   - Nomeie o projeto como "librio"
   - Habilite Google Analytics (opcional)

2. **Adicionar aplicativos:**
   - **Android**: Registre o app com o package name `com.example.librio`
   - **iOS**: Registre o app com o bundle ID `com.example.librio`

### 2. Arquivos de Configuração

#### Android (`android/app/google-services.json`)
```bash
# Baixar do Firebase Console
# Colocar em: android/app/google-services.json
```

#### iOS (`ios/Runner/GoogleService-Info.plist`)
```bash
# Baixar do Firebase Console
# Colocar em: ios/Runner/GoogleService-Info.plist
```

### 3. Configuração dos Serviços

#### Firestore Database
```bash
# No Firebase Console:
# 1. Ir para Firestore Database
# 2. Criar database em modo teste
# 3. Escolher localização (us-central1)
```

#### Authentication
```bash
# No Firebase Console:
# 1. Ir para Authentication
# 2. Ativar método "Email/senha"
# 3. Configurar domínios autorizados
```

#### Storage
```bash
# No Firebase Console:
# 1. Ir para Storage
# 2. Criar bucket padrão
# 3. Configurar regras de segurança
```

## 📱 Configuração por Plataforma

### Android

1. **Configurar build.gradle (Project level)**
```gradle
// android/build.gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

2. **Configurar build.gradle (App level)**
```gradle
// android/app/build.gradle
apply plugin: 'com.google.gms.google-services'

android {
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### iOS

1. **Configurar Podfile**
```ruby
# ios/Podfile
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

2. **Instalar CocoaPods**
```bash
cd ios
pod install
cd ..
```

## 🚀 Executando o Projeto

### 1. Verificação Inicial

```bash
# Verificar status do Flutter
flutter doctor

# Analisar código
flutter analyze

# Executar testes
flutter test
```

### 2. Executar em Desenvolvimento

```bash
# Debug mode (hot reload ativo)
flutter run

# Executar em dispositivo específico
flutter run -d <device_id>

# Executar no Chrome
flutter run -d chrome

# Executar no Android
flutter run -d android

# Executar no iOS (macOS apenas)
flutter run -d ios
```

### 3. Executar em Profile Mode

```bash
# Para análise de performance
flutter run --profile
```

## 📁 Estrutura do Projeto

Após a instalação, a estrutura do projeto será:

```
librio/
├── android/                    # Configuração Android
├── ios/                       # Configuração iOS
├── lib/                       # Código Dart/Flutter
│   ├── main.dart             # Ponto de entrada
│   ├── firebase_options.dart # Configuração Firebase
│   └── src/                  # Código fonte organizado
│       ├── data/             # Camada de dados
│       ├── domain/           # Camada de domínio
│       ├── presentation/     # Camada de apresentação
│       ├── routes/           # Configuração de rotas
│       └── shared/           # Utilitários compartilhados
├── assets/                   # Recursos (imagens, ícones)
├── test/                     # Testes automatizados
├── pubspec.yaml             # Dependências e configurações
└── README.md                # Documentação básica
```

## 🧪 Verificação da Instalação

### 1. Teste de Inicialização

```bash
# O app deve iniciar sem erros
flutter run
```

### 2. Teste de Funcionalidades Básicas

- ✅ Tela de login carrega
- ✅ Pode navegar entre telas
- ✅ Firebase está conectado
- ✅ Hot reload funciona

### 3. Comandos de Verificação

```bash
# Verificar configuração Firebase
flutter packages get
dart run lib/main.dart --dart-define=CHECK_CONFIG=true

# Verificar conectividade
ping google.com
```

## ⚠️ Solução de Problemas

### Erro: "Google Services plugin could not detect"

```bash
# Verificar se google-services.json está na pasta correta
ls android/app/google-services.json

# Re-sincronizar dependências
flutter clean
flutter pub get
```

### Erro: "Pod install failed"

```bash
# Limpar cache CocoaPods
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..
```

### Erro: "Firebase configuration"

```bash
# Verificar configuração
cat ios/Runner/GoogleService-Info.plist
cat android/app/google-services.json

# Reconfigurar Firebase
flutter packages get
```

### Erro: "Hot reload failed"

```bash
# Restart completo
flutter clean
flutter pub get
flutter run
```

## 🎯 Próximos Passos

Com o projeto instalado e funcionando:

1. **[Arquitetura](../architecture/overview)** - Entenda a organização do código
2. **[Firebase](../firebase/firestore)** - Configure o banco de dados
3. **[Funcionalidades](../features/authentication)** - Explore as features

---

:::tip Dica
Mantenha sempre um terminal aberto com `flutter run` durante o desenvolvimento para aproveitar o hot reload.
:::

:::info Scripts Úteis
Adicione estes scripts ao seu `pubspec.yaml` para facilitar o desenvolvimento:
```yaml
scripts:
  analyze: flutter analyze
  test: flutter test
  clean: flutter clean && flutter pub get
```
:::
