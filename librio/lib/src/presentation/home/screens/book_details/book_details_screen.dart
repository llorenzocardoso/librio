import 'package:flutter/material.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/presentation/presentation.dart';

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

  Widget _buildConditionStars(String condition) {
    final stars = _getConditionStars(condition);
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star,
          size: 16,
          color: index < stars ? Colors.orange : Colors.grey[300],
        );
      }),
    );
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
                  borderRadius: BorderRadius.circular(8),
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
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(book.author,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text(book.genre,
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              // Informações do livro
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_getConditionStars(book.condition)} (${book.condition})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Owner info
              viewModel.isLoadingOwner
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: viewModel.ownerProfile?.photoUrl !=
                                      null &&
                                  viewModel.ownerProfile!.photoUrl!.isNotEmpty
                              ? NetworkImage(viewModel.ownerProfile!.photoUrl!)
                              : const AssetImage(
                                      'assets/images/avatar_placeholder.png')
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.ownerProfile?.name ?? 'Usuário',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.yellow, size: 16),
                                const SizedBox(width: 4),
                                Text(viewModel.ownerProfile?.averageRating
                                        .toStringAsFixed(1) ??
                                    "0.0"),
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
                              Text('Ver perfil',
                                  style: TextStyle(color: Colors.blue)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios,
                                  color: Colors.blue, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 16),
              const Text('Descrição',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Informações detalhadas sobre o livro serão exibidas aqui.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: viewModel.isOwnBook
          ? null // Não mostrar botão se for o próprio livro
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: ElevatedButton(
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
                child: const Text(
                  'Propor troca',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
    );
  }
}
