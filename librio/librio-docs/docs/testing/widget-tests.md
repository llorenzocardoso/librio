# 🧩 Testes de Widget

## Visão Geral

Testes de widget verificam se os componentes de UI funcionam corretamente de forma isolada, testando renderização, interações e estados visuais.

## Setup Básico

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librio/src/presentation/home/widgets/book_card.dart';

void main() {
  group('BookCard Widget Tests', () {
    testWidgets('deve renderizar informações do livro', (tester) async {
      // Arrange
      final book = createTestBook();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookCard(book: book),
          ),
        ),
      );

      // Assert
      expect(find.text(book.title), findsOneWidget);
      expect(find.text(book.author), findsOneWidget);
    });
  });
}
```

## Testes de Widgets Principais

### 1. BookCard

```dart
testWidgets('BookCard - exibe todas informações', (tester) async {
  final book = Book(
    id: '1',
    title: 'Dom Casmurro',
    author: 'Machado de Assis',
    category: 'Literatura',
    condition: 'Bom',
    location: 'São Paulo',
    isAvailable: true,
  );

  await tester.pumpWidget(MaterialApp(
    home: BookCard(book: book),
  ));

  expect(find.text('Dom Casmurro'), findsOneWidget);
  expect(find.text('Machado de Assis'), findsOneWidget);
  expect(find.text('Literatura'), findsOneWidget);
  expect(find.text('São Paulo'), findsOneWidget);
});

testWidgets('BookCard - responde ao toque', (tester) async {
  bool tapped = false;
  final book = createTestBook();

  await tester.pumpWidget(MaterialApp(
    home: GestureDetector(
      onTap: () => tapped = true,
      child: BookCard(book: book),
    ),
  ));

  await tester.tap(find.byType(BookCard));
  expect(tapped, isTrue);
});
```

### 2. CustomBottomNavigationBar

```dart
testWidgets('BottomNav - exibe todas abas', (tester) async {
  int selectedIndex = 0;

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: selectedIndex,
        onTap: (index) => selectedIndex = index,
      ),
    ),
  ));

  expect(find.byIcon(Icons.home), findsOneWidget);
  expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
  expect(find.byIcon(Icons.chat), findsOneWidget);
  expect(find.byIcon(Icons.person), findsOneWidget);
});

testWidgets('BottomNav - muda seleção ao tocar', (tester) async {
  int selectedIndex = 0;

  await tester.pumpWidget(MaterialApp(
    home: StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          bottomNavigationBar: CustomBottomNavigationBar(
            selectedIndex: selectedIndex,
            onTap: (index) => setState(() => selectedIndex = index),
          ),
        );
      },
    ),
  ));

  // Tocar na aba de chat
  await tester.tap(find.byIcon(Icons.chat));
  await tester.pump();

  expect(selectedIndex, 2);
});
```

### 3. ChatBubble

```dart
testWidgets('ChatBubble - mensagem própria', (tester) async {
  final message = Message(
    id: '1',
    chatId: 'chat1',
    senderId: 'user1',
    content: 'Olá!',
    timestamp: DateTime.now(),
    isRead: true,
  );

  await tester.pumpWidget(MaterialApp(
    home: ChatBubble(
      message: message,
      isOwnMessage: true,
    ),
  ));

  expect(find.text('Olá!'), findsOneWidget);

  // Verificar cor da mensagem própria
  final container = tester.widget<Container>(find.byType(Container));
  expect(container.decoration, isA<BoxDecoration>());
});

testWidgets('ChatBubble - mensagem de outro usuário', (tester) async {
  final message = createTestMessage();

  await tester.pumpWidget(MaterialApp(
    home: ChatBubble(
      message: message,
      isOwnMessage: false,
    ),
  ));

  expect(find.text(message.content), findsOneWidget);

  // Verificar alinhamento diferente
  final positioned = tester.widget<Positioned>(find.byType(Positioned));
  expect(positioned.left, isNotNull);
});
```

## Testes de Estado e Interação

### Loading States

```dart
testWidgets('mostra loading quando carregando', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: BookListWidget(isLoading: true),
  ));

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  expect(find.byType(ListView), findsNothing);
});

testWidgets('mostra lista quando carregado', (tester) async {
  final books = [createTestBook()];

  await tester.pumpWidget(MaterialApp(
    home: BookListWidget(
      isLoading: false,
      books: books,
    ),
  ));

  expect(find.byType(CircularProgressIndicator), findsNothing);
  expect(find.byType(ListView), findsOneWidget);
});
```

### Form Validation

```dart
testWidgets('AddBookForm - validação de campos', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: AddBookForm(),
  ));

  // Tentar submeter sem preencher
  await tester.tap(find.text('Adicionar'));
  await tester.pump();

  expect(find.text('Campo obrigatório'), findsNWidgets(4));

  // Preencher campo título
  await tester.enterText(find.byKey(Key('title_field')), 'Test Book');
  await tester.pump();

  // Verificar que erro do título sumiu
  expect(find.text('Campo obrigatório'), findsNWidgets(3));
});
```

## Golden Tests

### Setup

```dart
// test/widget/golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group('Golden Tests', () {
    testGoldens('BookCard golden test', (tester) async {
      final book = createTestBook();

      await tester.pumpWidgetBuilder(
        BookCard(book: book),
        surfaceSize: Size(300, 200),
      );

      await screenMatchesGolden(tester, 'book_card');
    });
  });
}
```

### Multidevice Testing

```dart
testGoldens('BookCard em diferentes tamanhos', (tester) async {
  final book = createTestBook();

  await tester.pumpWidgetBuilder(
    BookCard(book: book),
    wrapper: materialAppWrapper(theme: ThemeData.light()),
  );

  await multiScreenGolden(
    tester,
    'book_card_multiscreen',
    devices: [
      Device.phone,
      Device.iphone11,
      Device.tabletPortrait,
    ],
  );
});
```

## Helpers e Mocks

### Test Data Factory

```dart
// test/helpers/test_data.dart
Book createTestBook({
  String? title,
  String? author,
  bool? isAvailable,
}) {
  return Book(
    id: 'test_book_${DateTime.now().millisecondsSinceEpoch}',
    title: title ?? 'Test Book',
    author: author ?? 'Test Author',
    category: 'Fiction',
    condition: 'Novo',
    description: 'Test description',
    ownerId: 'test_user',
    isAvailable: isAvailable ?? true,
    createdAt: DateTime.now(),
    location: 'Test Location',
  );
}

Message createTestMessage({
  String? content,
  bool? isRead,
}) {
  return Message(
    id: 'test_msg_${DateTime.now().millisecondsSinceEpoch}',
    chatId: 'test_chat',
    senderId: 'test_user',
    content: content ?? 'Test message',
    timestamp: DateTime.now(),
    isRead: isRead ?? true,
  );
}
```

### Widget Test Wrapper

```dart
Widget createTestWrapper(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

Future<void> pumpWidgetWithProviders(
  WidgetTester tester,
  Widget widget,
) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => MockHomeViewModel(),
        ),
        // outros providers...
      ],
      child: MaterialApp(home: widget),
    ),
  );
}
```

## Execução

```bash
# Testes de widget
flutter test test/widget/

# Com coverage
flutter test test/widget/ --coverage

# Golden tests
flutter test test/widget/golden_test.dart --update-goldens
```

Testes de widget garantem interface robusta e consistente! 🧩
