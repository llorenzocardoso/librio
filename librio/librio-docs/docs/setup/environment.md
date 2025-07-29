# Configuração do Ambiente de Desenvolvimento

Este guia ajudará você a configurar o ambiente de desenvolvimento necessário para trabalhar no projeto Librio.

## 📋 Pré-requisitos

### 1. Flutter SDK
- **Versão mínima**: 3.2.3
- **Download**: [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

```bash
# Verificar instalação do Flutter
flutter --version
flutter doctor
```

### 2. IDEs Recomendadas

#### Visual Studio Code
- **Extensions necessárias**:
  - Flutter
  - Dart
  - Bracket Pair Colorizer
  - GitLens

#### Android Studio
- **Plugins necessários**:
  - Flutter Plugin
  - Dart Plugin

### 3. SDKs Adicionais

#### Android SDK
```bash
# Verificar Android SDK
flutter doctor --android-licenses
```

#### iOS SDK (macOS apenas)
```bash
# Verificar Xcode
xcode-select --install
```

### 4. Conta Firebase
- Criar projeto no [Firebase Console](https://console.firebase.google.com)
- Habilitar Authentication, Firestore e Storage

## 🛠️ Configuração Passo a Passo

### 1. Verificar Sistema

Execute o comando para verificar se tudo está configurado corretamente:

```bash
flutter doctor -v
```

**Saída esperada**:
```
[✓] Flutter (Channel stable, 3.2.3)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Visual Studio Code (version 1.84.0)
[✓] Connected device (1 available)
[✓] Network resources
```

### 2. Configurar Firebase CLI

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Fazer login
firebase login

# Verificar projetos
firebase projects:list
```

### 3. Configurar Emuladores (Opcional)

#### Android Emulator
```bash
# Listar AVDs disponíveis
flutter emulators

# Iniciar emulador
flutter emulators --launch <emulator_id>
```

#### iOS Simulator (macOS)
```bash
# Abrir simulador iOS
open -a Simulator
```

## 🔧 Configurações Adicionais

### 1. Configurar Editor

#### VS Code Settings (`.vscode/settings.json`)
```json
{
  "dart.flutterSdkPath": "caminho/para/flutter",
  "dart.enableSdkFormatter": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
}
```

### 2. Configurar Git Hooks

```bash
# Configurar pre-commit hook
echo "#!/bin/sh\nflutter analyze\nflutter test" > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### 3. Variáveis de Ambiente

#### Windows (PowerShell)
```powershell
$env:FLUTTER_ROOT = "C:\flutter"
$env:PATH += ";$env:FLUTTER_ROOT\bin"
```

#### macOS/Linux
```bash
export FLUTTER_ROOT=$HOME/flutter
export PATH=$PATH:$FLUTTER_ROOT/bin
```

## 🧪 Validação da Configuração

### 1. Teste Básico

```bash
# Criar projeto de teste
flutter create test_app
cd test_app

# Executar em diferentes plataformas
flutter run -d chrome        # Web
flutter run -d android       # Android
flutter run -d ios          # iOS (macOS apenas)
```

### 2. Teste Firebase

```bash
# Adicionar Firebase ao projeto teste
flutter pub add firebase_core
flutter pub add cloud_firestore
flutter pub add firebase_auth
```

## ⚠️ Problemas Comuns

### Erro: "Flutter command not found"
```bash
# Verificar PATH
echo $PATH

# Adicionar Flutter ao PATH
export PATH="$PATH:/caminho/para/flutter/bin"
```

### Erro: "Android license status unknown"
```bash
flutter doctor --android-licenses
# Aceitar todas as licenças
```

### Erro: "No Xcode installation found"
```bash
# Instalar Xcode Command Line Tools
sudo xcode-select --install
```

### Erro: "CocoaPods not installed"
```bash
# Instalar CocoaPods (macOS)
sudo gem install cocoapods
```

## 📱 Testando com Dispositivos Físicos

### Android
1. Habilitar **Opções do desenvolvedor**
2. Ativar **Depuração USB**
3. Conectar dispositivo via USB

```bash
# Verificar dispositivos conectados
flutter devices
adb devices
```

### iOS
1. Registrar dispositivo no Apple Developer
2. Configurar certificados de desenvolvimento
3. Confiar no desenvolvedor (Configurações > Geral > Gerenciamento de Dispositivos)

## 🎯 Próximos Passos

Com o ambiente configurado, você pode:

1. **[Instalar Dependências](installation)** - Configurar o projeto Librio
2. **[Arquitetura](../architecture/overview)** - Entender a estrutura do projeto
3. **[Firebase Setup](../firebase/firestore)** - Configurar o backend

---

:::tip Dica de Performance
Para melhor performance durante o desenvolvimento, considere usar o modo **profile** para testes de performance:
```bash
flutter run --profile
```
:::

:::warning Atenção
Certifique-se de que todas as verificações do `flutter doctor` estejam ✅ antes de continuar.
:::
