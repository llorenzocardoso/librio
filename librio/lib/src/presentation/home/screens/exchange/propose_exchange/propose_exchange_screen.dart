import 'package:flutter/material.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/presentation/presentation.dart';

class ProposeExchangeScreen extends StatefulWidget {
  final Book receiverBook; // Livro que o usuário quer

  const ProposeExchangeScreen({
    Key? key,
    required this.receiverBook,
  }) : super(key: key);

  @override
  State<ProposeExchangeScreen> createState() => _ProposeExchangeScreenState();
}

class _ProposeExchangeScreenState extends State<ProposeExchangeScreen> {
  late ProposeExchangeViewModel viewModel;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewModel = ProposeExchangeViewModel();
    viewModel.addListener(() => setState(() {}));
    viewModel.loadUserBooks();
  }

  @override
  void dispose() {
    viewModel.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showBookSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Título
              const Text(
                'Escolha um dos seus livros',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Lista de livros
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: viewModel.userBooks.length,
                  itemBuilder: (context, index) {
                    final book = viewModel.userBooks[index];
                    final isSelected = viewModel.selectedBook == book;

                    return GestureDetector(
                      onTap: () {
                        viewModel.selectBook(book);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected ? Colors.blue : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                                child: book.imageUrl.isNotEmpty
                                    ? Image.network(
                                        book.imageUrl,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                      )
                                    : Container(
                                        width: double.infinity,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.book,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                book.title,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiverBook = widget.receiverBook;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => viewModel.navigateBack(context),
        ),
        title: const Text(
          'Propor Troca',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _buildBody(receiverBook),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: ElevatedButton(
          onPressed: viewModel.isLoading || viewModel.selectedBook == null
              ? null
              : () => viewModel.proposeExchange(
                    receiverBookId: receiverBook.id,
                    receiverId: receiverBook.ownerId,
                    message: _messageController.text.trim().isEmpty
                        ? null
                        : _messageController.text.trim(),
                    context: context,
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF176FF1),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: viewModel.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Propor Troca',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBody(Book receiverBook) {
    if (viewModel.isLoadingBooks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.userBooks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Você não tem livros para trocar',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Adicione alguns livros primeiro!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          const Text(
            'Detalhes da Troca',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Exibição dos livros simplificada
          Row(
            children: [
              // Livro oferecido
              Expanded(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showBookSelectionModal,
                      child: Container(
                        height: 220,
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: viewModel.selectedBook != null
                                ? Colors.blue.shade300
                                : Colors.grey.shade300,
                            width: viewModel.selectedBook != null ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: viewModel.selectedBook != null
                              ? (viewModel.selectedBook!.imageUrl.isNotEmpty
                                  ? Image.network(
                                      viewModel.selectedBook!.imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.book,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ))
                              : Container(
                                  color: Colors.grey[100],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Toque para\nselecionar',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.selectedBook?.title ?? 'Seu livro',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Seta
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.arrow_forward,
                  size: 24,
                  color: Colors.grey,
                ),
              ),

              // Livro desejado
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 220,
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: receiverBook.imageUrl.isNotEmpty
                            ? Image.network(
                                receiverBook.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.book,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      receiverBook.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          // Campo de mensagem
          const Text(
            'Mensagem (opcional):',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Escreva uma mensagem para o proprietário...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
