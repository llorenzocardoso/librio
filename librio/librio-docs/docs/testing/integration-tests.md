# 🔗 Testes de Integração

## Visão Geral

Os testes de integração verificam se diferentes partes do sistema funcionam corretamente em conjunto, simulando cenários reais de uso do aplicativo.

## Configuração

### Dependências

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  firebase_auth_mocks: ^0.13.0
  fake_cloud_firestore: ^2.4.6
```

### Setup Inicial

```dart
// integration_test/app_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:librio/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Librio Integration Tests', () {
    setUpAll(() async {
      // Configurações globais
      await _setupTestEnvironment();
    });

    tearDownAll(() async {
      // Limpeza após testes
      await _cleanupTestEnvironment();
    });
  });
}
```

## Fluxos de Teste Principais

### 1. Fluxo de Autenticação Completo

```dart
testWidgets('fluxo completo de autenticação', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  // 1. Tela inicial - Navegar para login
  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();

  // 2. Tentar login com credenciais inválidas
  await tester.enterText(find.byKey(Key('email_field')), 'invalid@email.com');
  await tester.enterText(find.byKey(Key('password_field')), 'wrongpassword');
  await tester.tap(find.byKey(Key('login_submit')));
  await tester.pumpAndSettle(Duration(seconds: 3));

  // Verificar mensagem de erro
  expect(find.text('Usuário não encontrado'), findsOneWidget);

  // 3. Navegar para cadastro
  await tester.tap(find.text('Criar Conta'));
  await tester.pumpAndSettle();

  // 4. Preencher formulário de cadastro
  final testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
  await tester.enterText(find.byKey(Key('name_field')), 'Usuário Teste');
  await tester.enterText(find.byKey(Key('email_field')), testEmail);
  await tester.enterText(find.byKey(Key('password_field')), 'password123');
  await tester.enterText(find.byKey(Key('location_field')), 'São Paulo, SP');

  // 5. Submeter cadastro
  await tester.tap(find.byKey(Key('signup_submit')));
  await tester.pumpAndSettle(Duration(seconds: 5));

  // 6. Verificar navegação para home
  expect(find.text('Biblioteca'), findsOneWidget);
  expect(find.byKey(Key('bottom_nav_home')), findsOneWidget);

  // 7. Fazer logout
  await tester.tap(find.byKey(Key('bottom_nav_profile')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('logout_button')));
  await tester.pumpAndSettle();

  // 8. Verificar volta para tela inicial
  expect(find.text('Entrar'), findsOneWidget);

  // 9. Login com credenciais criadas
  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(Key('email_field')), testEmail);
  await tester.enterText(find.byKey(Key('password_field')), 'password123');
  await tester.tap(find.byKey(Key('login_submit')));
  await tester.pumpAndSettle(Duration(seconds: 3));

  // Verificar login bem-sucedido
  expect(find.text('Biblioteca'), findsOneWidget);
});
```

### 2. Fluxo Completo de Troca de Livros

```dart
testWidgets('fluxo completo de troca de livros', (tester) async {
  // Setup: criar dois usuários
  await _createTestUser(tester, 'user1@test.com', 'User One');
  await _createTestUser(tester, 'user2@test.com', 'User Two');

  // === USUÁRIO 1: Adicionar livro ===
  await _loginAsUser(tester, 'user1@test.com', 'password123');

  // Adicionar livro
  await tester.tap(find.byKey(Key('add_book_fab')));
  await tester.pumpAndSettle();

  await _fillBookForm(tester, {
    'title': 'Dom Casmurro',
    'author': 'Machado de Assis',
    'category': 'Literatura Brasileira',
    'condition': 'Bom',
    'description': 'Clássico da literatura brasileira',
  });

  await tester.tap(find.byKey(Key('add_book_submit')));
  await tester.pumpAndSettle(Duration(seconds: 3));

  // Verificar sucesso
  expect(find.text('Livro adicionado com sucesso!'), findsOneWidget);

  // Logout do usuário 1
  await _logout(tester);

  // === USUÁRIO 2: Ver livro e propor troca ===
  await _loginAsUser(tester, 'user2@test.com', 'password123');

  // Adicionar livro próprio para trocar
  await _addTestBook(tester, 'O Cortiço', 'Aluísio Azevedo');

  // Ver livro do usuário 1
  await tester.tap(find.byKey(Key('bottom_nav_home')));
  await tester.pumpAndSettle();

  final bookCard = find.descendant(
    of: find.byType(Card),
    matching: find.text('Dom Casmurro'),
  );
  await tester.tap(bookCard);
  await tester.pumpAndSettle();

  // Propor troca
  await tester.tap(find.text('Propor troca'));
  await tester.pumpAndSettle();

  // Selecionar livro próprio
  await tester.tap(find.text('O Cortiço'));
  await tester.pumpAndSettle();

  // Confirmar proposta
  await tester.tap(find.text('Enviar Proposta'));
  await tester.pumpAndSettle(Duration(seconds: 3));

  // Verificar sucesso
  expect(find.text('Proposta enviada!'), findsOneWidget);

  // Logout do usuário 2
  await _logout(tester);

  // === USUÁRIO 1: Aceitar proposta ===
  await _loginAsUser(tester, 'user1@test.com', 'password123');

  // Ver propostas recebidas
  await tester.tap(find.byKey(Key('bottom_nav_exchanges')));
  await tester.pumpAndSettle();

  // Aceitar proposta
  await tester.tap(find.text('Aceitar'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Confirmar'));
  await tester.pumpAndSettle(Duration(seconds: 3));

  // Verificar chat habilitado
  expect(find.text('Chat'), findsOneWidget);

  // === AMBOS: Confirmar conclusão ===
  // Usuário 1 confirma
  await tester.tap(find.text('Confirmar Conclusão'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Confirmar'));
  await tester.pumpAndSettle(Duration(seconds: 3));

  await _logout(tester);

  // Usuário 2 confirma
  await _loginAsUser(tester, 'user2@test.com', 'password123');
  await tester.tap(find.byKey(Key('bottom_nav_exchanges')));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Confirmar Conclusão'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Confirmar'));
  await tester.pumpAndSettle(Duration(seconds: 3));

  // Verificar troca concluída
  expect(find.text('Troca concluída!'), findsOneWidget);

  // Verificar que livros não aparecem mais na home
  await tester.tap(find.byKey(Key('bottom_nav_home')));
  await tester.pumpAndSettle();
  expect(find.text('Dom Casmurro'), findsNothing);
});
```

### 3. Fluxo de Chat Completo

```dart
testWidgets('fluxo completo de chat', (tester) async {
  // Setup: dois usuários com proposta aceita
  await _setupExchangeScenario(tester);

  // Usuário 1 inicia chat
  await _loginAsUser(tester, 'user1@test.com', 'password123');

  // Ir para lista de chats
  await tester.tap(find.byKey(Key('bottom_nav_chat')));
  await tester.pumpAndSettle();

  // Verificar lista de chats
  expect(find.byType(ListView), findsOneWidget);

  // Abrir chat específico
  await tester.tap(find.byKey(Key('chat_item_0')));
  await tester.pumpAndSettle();

  // Enviar primeira mensagem
  await tester.enterText(
    find.byKey(Key('message_field')),
    'Olá! Quando podemos nos encontrar?'
  );
  await tester.tap(find.byKey(Key('send_button')));
  await tester.pumpAndSettle();

  // Verificar mensagem enviada
  expect(find.text('Olá! Quando podemos nos encontrar?'), findsOneWidget);

  await _logout(tester);

  // Usuário 2 responde
  await _loginAsUser(tester, 'user2@test.com', 'password123');
  await tester.tap(find.byKey(Key('bottom_nav_chat')));
  await tester.pumpAndSettle();

  // Verificar badge de não lidas
  expect(find.byKey(Key('unread_badge')), findsOneWidget);

  // Abrir chat
  await tester.tap(find.byKey(Key('chat_item_0')));
  await tester.pumpAndSettle();

  // Verificar mensagem recebida
  expect(find.text('Olá! Quando podemos nos encontrar?'), findsOneWidget);

  // Responder
  await tester.enterText(
    find.byKey(Key('message_field')),
    'Que tal amanhã às 14h no shopping?'
  );
  await tester.tap(find.byKey(Key('send_button')));
  await tester.pumpAndSettle();

  // Verificar conversa completa
  expect(find.text('Olá! Quando podemos nos encontrar?'), findsOneWidget);
  expect(find.text('Que tal amanhã às 14h no shopping?'), findsOneWidget);

  // Voltar para lista
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();

  // Verificar que badge de não lidas sumiu
  expect(find.byKey(Key('unread_badge')), findsNothing);
});
```

### 4. Teste de Sincronização de Dados

```dart
testWidgets('sincronização de dados entre telas', (tester) async {
  await _loginAsUser(tester, 'test@example.com', 'password123');

  // 1. Adicionar livro via FAB
  await tester.tap(find.byKey(Key('add_book_fab')));
  await tester.pumpAndSettle();

  await _fillBookForm(tester, {
    'title': 'Livro de Teste',
    'author': 'Autor Teste',
    'category': 'Ficção',
    'condition': 'Novo',
    'description': 'Livro para teste de sincronização',
  });

  await tester.tap(find.byKey(Key('add_book_submit')));
  await tester.pumpAndSettle(Duration(seconds: 3));

  // 2. Verificar que livro NÃO aparece na home (próprios livros)
  await tester.tap(find.byKey(Key('bottom_nav_home')));
  await tester.pumpAndSettle();
  expect(find.text('Livro de Teste'), findsNothing);

  // 3. Verificar que livro APARECE no perfil
  await tester.tap(find.byKey(Key('bottom_nav_profile')));
  await tester.pumpAndSettle();
  expect(find.text('Livro de Teste'), findsOneWidget);

  // 4. Navegar entre abas e verificar consistência
  await tester.tap(find.byKey(Key('bottom_nav_exchanges')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('bottom_nav_profile')));
  await tester.pumpAndSettle();

  // Livro ainda deve estar visível
  expect(find.text('Livro de Teste'), findsOneWidget);

  // 5. Simular troca (marcar como indisponível)
  await _simulateBookExchange(tester, 'Livro de Teste');

  // 6. Verificar que livro fica indisponível
  expect(find.text('Indisponível'), findsOneWidget);
});
```

## Helpers e Utilitários

### Funções de Apoio

```dart
Future<void> _loginAsUser(WidgetTester tester, String email, String password) async {
  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(Key('email_field')), email);
  await tester.enterText(find.byKey(Key('password_field')), password);

  await tester.tap(find.byKey(Key('login_submit')));
  await tester.pumpAndSettle(Duration(seconds: 3));
}

Future<void> _createTestUser(WidgetTester tester, String email, String name) async {
  app.main();
  await tester.pumpAndSettle();

  await tester.tap(find.text('Criar Conta'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(Key('name_field')), name);
  await tester.enterText(find.byKey(Key('email_field')), email);
  await tester.enterText(find.byKey(Key('password_field')), 'password123');
  await tester.enterText(find.byKey(Key('location_field')), 'São Paulo, SP');

  await tester.tap(find.byKey(Key('signup_submit')));
  await tester.pumpAndSettle(Duration(seconds: 5));

  await _logout(tester);
}

Future<void> _fillBookForm(WidgetTester tester, Map<String, String> bookData) async {
  await tester.enterText(find.byKey(Key('title_field')), bookData['title']!);
  await tester.enterText(find.byKey(Key('author_field')), bookData['author']!);

  // Selecionar categoria
  await tester.tap(find.byKey(Key('category_dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(bookData['category']!));
  await tester.pumpAndSettle();

  // Selecionar condição
  await tester.tap(find.byKey(Key('condition_dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(bookData['condition']!));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(Key('description_field')), bookData['description']!);
}

Future<void> _logout(WidgetTester tester) async {
  await tester.tap(find.byKey(Key('bottom_nav_profile')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('logout_button')));
  await tester.pumpAndSettle();
}
```

## Execução dos Testes

### Comandos

```bash
# Executar todos os testes de integração
flutter test integration_test/

# Executar teste específico
flutter test integration_test/auth_flow_test.dart

# Executar com device específico
flutter test integration_test/ -d chrome
flutter test integration_test/ -d android
```

### CI/CD Integration

```yaml
# .github/workflows/integration_tests.yml
name: Integration Tests

on: [push, pull_request]

jobs:
  integration_tests:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.2.3'

    - name: Install dependencies
      run: flutter pub get

    - name: Run integration tests
      run: flutter test integration_test/ -d web-server
```

## Cenários de Teste Críticos

### 1. Performance sob Carga

```dart
testWidgets('performance com múltiplos livros', (tester) async {
  await _loginAsUser(tester, 'test@example.com', 'password123');

  // Adicionar múltiplos livros
  for (int i = 0; i < 20; i++) {
    await _addTestBook(tester, 'Livro $i', 'Autor $i');
  }

  // Medir tempo de carregamento da home
  final stopwatch = Stopwatch()..start();
  await tester.tap(find.byKey(Key('bottom_nav_home')));
  await tester.pumpAndSettle();
  stopwatch.stop();

  // Verificar que carregou em menos de 3 segundos
  expect(stopwatch.elapsedMilliseconds, lessThan(3000));
});
```

### 2. Cenários de Erro

```dart
testWidgets('comportamento sem internet', (tester) async {
  // Simular perda de conexão
  await _simulateOffline();

  app.main();
  await tester.pumpAndSettle();

  // Tentar fazer login
  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
  await tester.enterText(find.byKey(Key('password_field')), 'password123');
  await tester.tap(find.byKey(Key('login_submit')));
  await tester.pumpAndSettle(Duration(seconds: 5));

  // Verificar mensagem de erro apropriada
  expect(find.text('Erro de conexão'), findsOneWidget);

  // Restaurar conexão
  await _simulateOnline();
});
```

### 3. Estados de Loading

```dart
testWidgets('estados de loading são mostrados', (tester) async {
  await _loginAsUser(tester, 'test@example.com', 'password123');

  // Navegar para uma tela que carrega dados
  await tester.tap(find.byKey(Key('bottom_nav_exchanges')));

  // Verificar que loading é mostrado
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  await tester.pumpAndSettle();

  // Verificar que loading desaparece
  expect(find.byType(CircularProgressIndicator), findsNothing);
});
```

## Relatórios e Análise

### Geração de Relatórios

```dart
class IntegrationTestReporter {
  static final List<TestResult> _results = [];

  static void recordTest(String testName, bool passed, Duration duration) {
    _results.add(TestResult(
      name: testName,
      passed: passed,
      duration: duration,
      timestamp: DateTime.now(),
    ));
  }

  static void generateReport() {
    final report = {
      'totalTests': _results.length,
      'passed': _results.where((r) => r.passed).length,
      'failed': _results.where((r) => !r.passed).length,
      'averageDuration': _calculateAverageDuration(),
      'details': _results.map((r) => r.toJson()).toList(),
    };

    // Salvar relatório
    File('integration_test_report.json').writeAsStringSync(
      json.encode(report)
    );
  }
}
```

## Melhores Práticas

### 1. Isolamento de Testes
- Cada teste deve ser independente
- Limpar dados antes/depois dos testes
- Usar dados únicos (timestamps)

### 2. Esperas Inteligentes
```dart
// ❌ Evitar esperas fixas
await Future.delayed(Duration(seconds: 3));

// ✅ Usar pumpAndSettle
await tester.pumpAndSettle();

// ✅ Esperar por elemento específico
await tester.pumpUntil(find.text('Carregado'), Duration(seconds: 10));
```

### 3. Seletores Robustos
```dart
// ❌ Evitar seletores frágeis
find.text('Botão')

// ✅ Usar keys específicas
find.byKey(Key('submit_button'))

// ✅ Seletores hierárquicos
find.descendant(
  of: find.byType(Card),
  matching: find.text('Dom Casmurro')
)
```

Os testes de integração garantem que o Librio funciona perfeitamente em cenários reais! 🔗
