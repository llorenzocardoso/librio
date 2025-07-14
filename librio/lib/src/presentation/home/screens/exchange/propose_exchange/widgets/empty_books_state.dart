import 'package:flutter/material.dart';

class EmptyBooksState extends StatelessWidget {
  const EmptyBooksState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
