import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:librio/src/data/data.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/shared/shared.dart';
import '../../chat/chat_helper.dart';

class ProposeExchangeViewModel extends ChangeNotifier {
  late CreateExchangeUseCase _createExchangeUseCase;
  final BookDataManager _bookDataManager = BookDataManager();

  List<Book> get userBooks => _bookDataManager.userBooks;
  Book? selectedBook;
  bool isLoading = false;
  bool get isLoadingBooks => _bookDataManager.isLoading;
  String? error;

  ProposeExchangeViewModel() {
    _createExchangeUseCase = CreateExchangeUseCase(ExchangeRepositoryImpl());
    _bookDataManager.addListener(_onBooksDataChanged);
  }

  void _onBooksDataChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _bookDataManager.removeListener(_onBooksDataChanged);
    super.dispose();
  }

  Future<void> loadUserBooks() async {
    await _bookDataManager.loadUserBooks();
  }

  void selectBook(Book book) {
    selectedBook = book;
    notifyListeners();
  }

  Future<void> proposeExchange({
    required String receiverBookId,
    required String receiverId,
    String? message,
    required BuildContext context,
  }) async {
    if (selectedBook == null) {
      _showSnackBar(context, 'Selecione um livro para trocar');
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _createExchangeUseCase.execute(
        proposerBookId: selectedBook!.id,
        receiverBookId: receiverBookId,
        receiverId: receiverId,
        message: message,
      );

      _showSnackBar(context, 'Proposta enviada com sucesso!');

      // Iniciar chat automaticamente após proposta enviada
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Dar um pequeno delay para o snackbar aparecer
        await Future.delayed(const Duration(seconds: 1));

        // Oferecer para iniciar conversa
        final shouldStartChat = await _showChatDialog(context);
        if (shouldStartChat) {
          await ChatHelper.startChatWith(
            context,
            receiverId,
            currentUser.uid,
            forceStart: true, // Forçar início pois acabou de enviar proposta
          );
          return; // Não navegar de volta ainda
        }
      }

      navigateBack(context);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void navigateBack(BuildContext context) {
    context.pop();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _showChatDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Iniciar Conversa'),
            content: const Text(
                'Sua proposta foi enviada com sucesso! Gostaria de conversar com o dono do livro?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Agora não'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF176FF1),
                ),
                child: const Text(
                  'Conversar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
