import 'package:flutter/material.dart';
import 'package:librio/src/domain/entities/book.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;
  const BookDetailsScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.star, color: Colors.yellow, size: 16),
                  const SizedBox(width: 4),
                  Text('5 (${book.condition})'),
                  const SizedBox(width: 16),
                  const Icon(Icons.swap_horiz, color: Colors.blue, size: 16),
                  const SizedBox(width: 4),
                  const Text('Trocado 2 vezes',
                      style: TextStyle(color: Colors.blue)),
                ],
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              // Owner info placeholder
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        AssetImage('assets/images/avatar_placeholder.png'),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Julinha Gutheil',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow, size: 16),
                          SizedBox(width: 4),
                          Text('5.0'),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: const Color(0xFF176FF1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Propor troca',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
