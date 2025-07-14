import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/presentation/presentation.dart';
import 'package:librio/src/domain/usecases/delete_book_usecase.dart';
import 'package:librio/src/data/repositories/book_repository_impl.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;
  const BookDetailsScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late BookDetailsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = BookDetailsViewModel();
    viewModel.setBook(widget.book);
    viewModel.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  int _getConditionStars(String condition) {
    switch (condition.toLowerCase()) {
      case 'péssimo':
        return 1;
      case 'ruim':
        return 2;
      case 'razoável':
      case 'regular':
        return 3;
      case 'bom':
        return 4;
      case 'novo':
      case 'perfeito':
        return 5;
      default:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = viewModel.book!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          book.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 260,
                    child: book.imageUrl.isNotEmpty
                        ? Image.network(book.imageUrl, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.book, size: 50),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title and basic info
              Text(
                book.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    book.author,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    book.genre,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Informações do livro
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_getConditionStars(book.condition)} (${book.condition})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Owner info
              viewModel.isLoadingOwner
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: viewModel.ownerProfile?.photoUrl !=
                                      null &&
                                  viewModel.ownerProfile!.photoUrl!.isNotEmpty
                              ? null
                              : Colors.grey,
                          backgroundImage: viewModel.ownerProfile?.photoUrl !=
                                      null &&
                                  viewModel.ownerProfile!.photoUrl!.isNotEmpty
                              ? NetworkImage(viewModel.ownerProfile!.photoUrl!)
                              : null,
                          child: viewModel.ownerProfile?.photoUrl != null &&
                                  viewModel.ownerProfile!.photoUrl!.isNotEmpty
                              ? null
                              : const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.ownerProfile?.name ?? 'Usuário',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  viewModel.ownerProfile?.averageRating
                                          .toStringAsFixed(1) ??
                                      "0.0",
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            if (viewModel.ownerProfile != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => UserProfileScreen(
                                    userId: viewModel.ownerProfile!.id,
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Row(
                            children: [
                              Text(
                                'Ver perfil',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.blue,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 16),
              const Text(
                'Descrição',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                book.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: viewModel.isOwnBook
          ? _buildOwnBookButtons(context) // Mostrar botões de editar/excluir se for o próprio livro
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: viewModel.canChat
                  ? Row(
                      children: [
                        // Botão de Chat
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final currentUser =
                                  FirebaseAuth.instance.currentUser;
                              if (currentUser != null &&
                                  viewModel.ownerProfile != null) {
                                ChatHelper.startChatWith(
                                  context,
                                  viewModel.ownerProfile!.id,
                                  currentUser.uid,
                                  otherUserName: viewModel.ownerProfile!.name,
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              side: const BorderSide(
                                  color: Color(0xFF176FF1), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              color: Color(0xFF176FF1),
                              size: 20,
                            ),
                            label: const Text(
                              'Conversar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF176FF1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Botão de Propor Troca
                        Expanded(
                          flex: 1,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              viewModel.navigateToProposeExchange(context);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              backgroundColor: const Color(0xFF176FF1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(
                              Icons.swap_horiz,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'Propor troca',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  :
                  // Apenas botão de propor troca quando não pode conversar
                  ElevatedButton.icon(
                      onPressed: () {
                        viewModel.navigateToProposeExchange(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        backgroundColor: const Color(0xFF176FF1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(
                        Icons.swap_horiz,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Propor troca',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
    );
  }

  Widget _buildOwnBookButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Row(
        children: [
          // Botão de Editar
          Expanded(
            child: OutlinedButton.icon(
                             onPressed: () {
                 context.push('/edit_book', extra: widget.book);
               },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                side: const BorderSide(color: Color(0xFF176FF1), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.edit,
                color: Color(0xFF176FF1),
                size: 20,
              ),
              label: const Text(
                'Editar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF176FF1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Botão de Excluir
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteConfirmation(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                side: const BorderSide(color: Colors.red, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 20,
              ),
              label: const Text(
                'Excluir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir livro'),
        content: const Text(
          'Tem certeza que deseja excluir este livro? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Fechar o dialog

              try {
                // Usar o DeleteBookUseCase para excluir
                final deleteUseCase = DeleteBookUseCase(BookRepositoryImpl());
                                 await deleteUseCase.execute(widget.book.id);

                // Navegar de volta após sucesso
                if (context.mounted) {
                  context.pop();
                }
              } catch (e) {
                // Mostrar erro se ocorrer
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao excluir livro: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
