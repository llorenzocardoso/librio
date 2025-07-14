import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const SearchBarWidget({Key? key, this.onChanged}) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          setState(() {}); // Para atualizar o botão de limpar
          widget.onChanged?.call(value);
        },
        decoration: InputDecoration(
          hintText: 'Buscar livros',
          hintStyle: const TextStyle(color: Color(0xFFB8B8B8)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFB8B8B8)),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFFB8B8B8)),
                  onPressed: _clearSearch,
                  tooltip: 'Limpar pesquisa',
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
