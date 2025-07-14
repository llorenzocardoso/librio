import 'package:flutter/material.dart';
import 'package:librio/src/domain/domain.dart';
import 'package:librio/src/shared/shared.dart';
import 'edit_book_viewmodel.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  late EditBookViewModel viewModel;
  late TextEditingController titleController;
  late TextEditingController authorController;
  String? selectedGenre;
  late TextEditingController descriptionController;
  int conditionIndex = 0;

  final List<String> genres = BookConstants.categories;
  final List<String> conditions = BookConstants.conditions;

  @override
  void initState() {
    super.initState();
    viewModel = EditBookViewModel();
    viewModel.setBook(widget.book);
    viewModel.addListener(() => setState(() {}));

    // Pre-populate form fields
    titleController = TextEditingController(text: widget.book.title);
    authorController = TextEditingController(text: widget.book.author);
    selectedGenre = widget.book.genre;
    descriptionController =
        TextEditingController(text: widget.book.description);
    conditionIndex = conditions
        .indexOf(widget.book.condition)
        .clamp(0, conditions.length - 1);
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    descriptionController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Editar livro',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção de foto do livro
              _buildImageSection(),
              const SizedBox(height: 24),

              // Campos do formulário
              _buildFormFields(),

              // Localização
              _buildLocationSection(),

              // Mostrar erros
              if (viewModel.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          viewModel.error!,
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ),
                      IconButton(
                        onPressed: viewModel.clearError,
                        icon: const Icon(Icons.close),
                        iconSize: 20,
                        color: Colors.red.shade600,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Botão de salvar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _updateBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF176FF1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: viewModel.isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Salvando...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Salvar alterações',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Foto do livro',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => viewModel.pickImage(context),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4EAFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: _buildImageContent(),
                ),
              ),
              if (viewModel.selectedImageFile != null ||
                  viewModel.currentImageUrl != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => viewModel.removeImage(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              if (viewModel.isUploadingImage)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (viewModel.selectedImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          viewModel.selectedImageFile!,
          fit: BoxFit.cover,
        ),
      );
    } else if (viewModel.currentImageUrl != null &&
        viewModel.currentImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          viewModel.currentImageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
        ),
      );
    } else {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 32,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 8),
        Text(
          'Toque para\nalterar foto',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        const Text(
          'Título do livro',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE4EAFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),

        // Autor
        const Text(
          'Autor',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: authorController,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE4EAFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),

        // Gênero
        const Text(
          'Gênero',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedGenre,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE4EAFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          items: genres.map((genre) {
            return DropdownMenuItem(
              value: genre,
              child: Text(genre),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedGenre = value;
            });
          },
        ),
        const SizedBox(height: 16),

        // Condição
        const Text(
          'Condição do livro',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: conditions.asMap().entries.map((e) {
            final idx = e.key;
            final label = e.value;
            final isSelected = idx == conditionIndex;
            return Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.star,
                    color: isSelected
                        ? const Color(0xFF1D4ED8)
                        : Colors.grey[400],
                  ),
                  onPressed: () => setState(() => conditionIndex = idx),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Descrição
        const Text(
          'Descrição',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE4EAFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF176FF1)),
            const SizedBox(width: 8),
            const Text(
              'Localização',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed:
                  viewModel.isLoadingLocation ? null : viewModel.getLocation,
              icon: viewModel.isLoadingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, size: 16),
              label: Text(
                viewModel.isLoadingLocation ? 'Obtendo...' : 'Atualizar',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE4EAFF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                viewModel.city != null && viewModel.state != null
                    ? '${viewModel.city}, ${viewModel.state}'
                    : 'Localização não definida',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (viewModel.latitude != null && viewModel.longitude != null)
                Text(
                  'Coordenadas: ${viewModel.latitude!.toStringAsFixed(4)}, ${viewModel.longitude!.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateBook() {
    if (titleController.text.trim().isEmpty ||
        authorController.text.trim().isEmpty ||
        selectedGenre == null ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    viewModel.updateBook(
      title: titleController.text.trim(),
      author: authorController.text.trim(),
      genre: selectedGenre!,
      description: descriptionController.text.trim(),
      condition: conditions[conditionIndex],
      context: context,
    );
  }

  void _showDeleteConfirmation() {
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
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.deleteBook(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
