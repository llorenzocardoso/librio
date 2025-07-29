# ⚙️ CI/CD Pipeline

## GitHub Actions Setup

### Workflow Principal

```yaml
# .github/workflows/main.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.2.3'
        channel: 'stable'

    - name: Install dependencies
      run: flutter pub get

    - name: Run tests
      run: flutter test --coverage

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info

  build_android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
    - uses: actions/checkout@v3

    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.2.3'

    - name: Install dependencies
      run: flutter pub get

    - name: Configure signing
      run: |
        echo "${{ secrets.ANDROID_KEYSTORE }}" | base64 --decode > android/app/key.jks
        echo "storeFile=key.jks" >> android/key.properties
        echo "storePassword=${{ secrets.STORE_PASSWORD }}" >> android/key.properties
        echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
        echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties

    - name: Build AAB
      run: flutter build appbundle --release

    - name: Upload to Play Console
      uses: r0adkll/upload-google-play@v1
      with:
        serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT }}
        packageName: com.librio.app
        releaseFiles: build/app/outputs/bundle/release/app-release.aab
        track: internal

  build_ios:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'

    steps:
    - uses: actions/checkout@v3

    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.2.3'

    - name: Install dependencies
      run: flutter pub get

    - name: Install pods
      run: cd ios && pod install

    - name: Build iOS
      run: flutter build ios --release --no-codesign

    - name: Build IPA
      run: |
        cd ios
        xcodebuild -workspace Runner.xcworkspace \
                   -scheme Runner \
                   -configuration Release \
                   -destination generic/platform=iOS \
                   -archivePath Runner.xcarchive \
                   archive

        xcodebuild -exportArchive \
                   -archivePath Runner.xcarchive \
                   -exportPath . \
                   -exportOptionsPlist ExportOptions.plist

    - name: Upload to TestFlight
      uses: apple-actions/upload-testflight-build@v1
      with:
        app-path: ios/Runner.ipa
        issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
        api-key-id: ${{ secrets.APPSTORE_API_KEY_ID }}
        api-private-key: ${{ secrets.APPSTORE_API_PRIVATE_KEY }}
```

## Firebase Integration

### Deploy Automático

```yaml
# .github/workflows/firebase.yml
name: Firebase Deploy

on:
  push:
    branches: [ main ]
    paths:
      - 'firestore.rules'
      - 'firestore.indexes.json'

jobs:
  deploy_firebase:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'

    - name: Install Firebase CLI
      run: npm install -g firebase-tools

    - name: Deploy Firestore Rules
      run: firebase deploy --only firestore:rules --project librio-bf422
      env:
        FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}

    - name: Deploy Firestore Indexes
      run: firebase deploy --only firestore:indexes --project librio-bf422
      env:
        FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

## Configuração de Secrets

### GitHub Secrets Necessários

```bash
# Android
ANDROID_KEYSTORE          # Base64 do arquivo .jks
STORE_PASSWORD            # Senha do keystore
KEY_PASSWORD              # Senha da chave
KEY_ALIAS                 # Alias da chave
PLAY_SERVICE_ACCOUNT      # JSON do service account

# iOS
APPSTORE_ISSUER_ID        # App Store Connect Issuer ID
APPSTORE_API_KEY_ID       # API Key ID
APPSTORE_API_PRIVATE_KEY  # Chave privada da API

# Firebase
FIREBASE_TOKEN            # Token do Firebase CLI
```

### Configurando Secrets

```bash
# Gerar Firebase token
firebase login:ci

# Codificar keystore em base64
base64 -i android/app/key.jks | pbcopy

# Adicionar no GitHub:
# Settings → Secrets and variables → Actions → New repository secret
```

## Quality Gates

### Code Quality Check

```yaml
# .github/workflows/quality.yml
name: Code Quality

on: [push, pull_request]

jobs:
  analyze:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.2.3'

    - name: Install dependencies
      run: flutter pub get

    - name: Analyze code
      run: flutter analyze

    - name: Check formatting
      run: dart format --set-exit-if-changed .

    - name: Run tests with coverage
      run: flutter test --coverage

    - name: Check coverage threshold
      run: |
        # Verificar se cobertura é >= 80%
        COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | cut -d' ' -f4 | cut -d'%' -f1)
        if (( $(echo "$COVERAGE < 80" | bc -l) )); then
          echo "Coverage $COVERAGE% is below 80% threshold"
          exit 1
        fi
```

### Security Scan

```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Run dependency check
      uses: securecodewarrior/github-action-add-sarif@v1
      with:
        sarif-file: 'security-report.sarif'

    - name: Scan for secrets
      uses: trufflesecurity/trufflehog@main
      with:
        path: ./
        base: main
        head: HEAD
```

## Multi-Environment Setup

### Environment Configs

```yaml
# .github/workflows/deploy-staging.yml
name: Deploy to Staging

on:
  push:
    branches: [ develop ]

jobs:
  deploy_staging:
    runs-on: ubuntu-latest
    environment: staging

    steps:
    - uses: actions/checkout@v3

    - name: Deploy to Firebase Staging
      run: firebase deploy --project librio-staging
      env:
        FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN_STAGING }}

    - name: Run E2E tests
      run: |
        flutter drive \
          --driver=test_driver/integration_test.dart \
          --target=integration_test/app_test.dart \
          --dart-define=ENVIRONMENT=staging
```

### Environment Variables

```dart
// lib/config/environment.dart
class Environment {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isProduction => _environment == 'production';
  static bool get isStaging => _environment == 'staging';
  static bool get isDevelopment => _environment == 'development';

  static String get firebaseProjectId {
    switch (_environment) {
      case 'production':
        return 'librio-bf422';
      case 'staging':
        return 'librio-staging';
      default:
        return 'librio-dev';
    }
  }
}
```

## Automated Testing

### Integration Tests

```yaml
# .github/workflows/integration-tests.yml
name: Integration Tests

on:
  schedule:
    - cron: '0 2 * * *'  # Executa diariamente às 2h
  workflow_dispatch:      # Permite execução manual

jobs:
  integration_tests:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Start Android Emulator
      uses: reactivecircus/android-emulator-runner@v2
      with:
        api-level: 29
        script: flutter test integration_test/

    - name: Upload test results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: integration-test-results
        path: test-results/
```

### Performance Tests

```yaml
name: Performance Tests

on:
  push:
    branches: [ main ]

jobs:
  performance:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Run performance tests
      run: |
        flutter test test/performance/
        flutter build apk --release --analyze-size

    - name: Analyze bundle size
      run: |
        # Verificar se tamanho não excede limite
        SIZE=$(stat -c%s build/app/outputs/flutter-apk/app-release.apk)
        MAX_SIZE=50000000  # 50MB
        if [ $SIZE -gt $MAX_SIZE ]; then
          echo "APK size $SIZE exceeds limit $MAX_SIZE"
          exit 1
        fi
```

## Deployment Strategies

### Blue-Green Deployment

```yaml
# Para Firebase Functions (futuro)
name: Blue-Green Deploy

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Deploy to Blue
      run: firebase deploy --project librio-blue

    - name: Health Check
      run: |
        # Verificar se deploy foi bem-sucedido
        curl -f https://librio-blue.web.app/health || exit 1

    - name: Switch Traffic
      run: |
        # Alternar tráfego para blue
        firebase hosting:channel:deploy live --project librio-prod
```

### Feature Flags

```dart
// lib/config/feature_flags.dart
class FeatureFlags {
  static const bool enableNewChatUI = bool.fromEnvironment(
    'ENABLE_NEW_CHAT_UI',
    defaultValue: false,
  );

  static const bool enableRatingSystem = bool.fromEnvironment(
    'ENABLE_RATING_SYSTEM',
    defaultValue: true,
  );

  // Flags dinâmicos via Firebase Remote Config
  static Future<bool> isFeatureEnabled(String feature) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    return remoteConfig.getBool(feature);
  }
}
```

## Monitoring e Alerts

### Slack Notifications

```yaml
- name: Notify Slack on Failure
  uses: 8398a7/action-slack@v3
  if: failure()
  with:
    status: failure
    channel: '#librio-alerts'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
    fields: repo,message,commit,author,action,eventName,ref,workflow
```

### Status Badges

```markdown
<!-- README.md -->
![Build Status](https://github.com/librio/librio/workflows/CI/badge.svg)
![Coverage](https://codecov.io/gh/librio/librio/branch/main/graph/badge.svg)
![Version](https://img.shields.io/github/v/release/librio/librio)
```

## Rollback Strategy

### Automated Rollback

```yaml
name: Rollback

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to rollback to'
        required: true

jobs:
  rollback:
    runs-on: ubuntu-latest

    steps:
    - name: Rollback Play Store
      run: |
        # Promover versão anterior para production track
        curl -X POST \
          "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/com.librio.app/edits" \
          -H "Authorization: Bearer ${{ secrets.PLAY_ACCESS_TOKEN }}"

    - name: Rollback App Store
      run: |
        # Rejeitar build atual e promover anterior
        xcrun altool --validate-app -f previous-version.ipa
```

## Best Practices

### 1. Versionamento Semântico

```yaml
# Bump version automatically
- name: Bump version
  run: |
    # major.minor.patch+build
    flutter pub global activate cider
    cider bump patch
    cider bump build
```

### 2. Cache Dependencies

```yaml
- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.pub-cache
      ${{ runner.tool_cache }}/flutter
    key: flutter-${{ hashFiles('pubspec.yaml') }}
```

### 3. Parallel Jobs

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest, windows-latest]
    flutter-version: ['3.2.3', '3.3.0']
```

O CI/CD automatiza deploy seguro e confiável! ⚙️
