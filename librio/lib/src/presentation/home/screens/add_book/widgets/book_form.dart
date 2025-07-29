import 'package:flutter/material.dart';

class BookForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController authorController;
  final String? selectedCondition;
  final String? selectedGenre;
  final Function(String?) onConditionChanged;
  final Function(String?) onGenreChanged;

  const BookForm({
    Key? key,
    required this.formKey,
    required this.titleController,
    required this.authorController,
    this.selectedCondition,
    this.selectedGenre,
    required this.onConditionChanged,
    required this.onGenreChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: titleController,
            label: 'Título do livro',
            hint: 'Digite o título do livro',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Título é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: authorController,
            label: 'Autor',
            hint: 'Digite o nome do autor',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Autor é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Estado de conservação',
            value: selectedCondition,
            items: const [
              'Novo',
              'Seminovo',
              'Usado - Bom estado',
              'Usado - Estado regular',
            ],
            onChanged: onConditionChanged,
            validator: (value) {
              if (value == null) {
                return 'Selecione o estado de conservação';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Gênero/Categoria',
            value: selectedGenre,
            items: const [
              'Ficção',
              'Romance',
              'Fantasia',
              'Mistério',
              'Suspense',
              'Biografia',
              'História',
              'Ciência',
              'Tecnologia',
              'Filosofia',
              'Psicologia',
              'Autoajuda',
              'Negócios',
              'Infantil',
            ],
            onChanged: onGenreChanged,
            validator: (value) {
              if (value == null) {
                return 'Selecione um gênero';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF176FF1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF176FF1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          hint: Text('Selecione $label'),
        ),
      ],
    );
  }
}
