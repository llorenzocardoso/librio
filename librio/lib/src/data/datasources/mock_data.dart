import 'package:librio/src/domain/entities/book.dart';

class MockData {
  static List<Book> getMockBooks() {
    return [
      Book(
        id: '1',
        title: 'O Senhor dos Anéis: A Sociedade do Anel',
        author: 'J.R.R. Tolkien',
        imageUrl:
            'https://m.media-amazon.com/images/I/71ZLavBjpRL._AC_UF1000,1000_QL80_.jpg',
        condition: 'Bom',
        ownerId: 'user1',
        genre: 'Fantasia',
        description: 'Descrição do livro 1',
      ),
      Book(
        id: '2',
        title: 'Harry Potter e a Pedra Filosofal',
        author: 'J.K. Rowling',
        imageUrl:
            'https://m.media-amazon.com/images/I/81ibfYk4qmL._AC_UF1000,1000_QL80_.jpg',
        condition: 'Novo',
        ownerId: 'user2',
        genre: 'Fantasia',
        description: 'Descrição do livro 2',
      ),
      Book(
        id: '3',
        title: 'Duna',
        author: 'Frank Herbert',
        imageUrl:
            'https://m.media-amazon.com/images/I/715afDdgKfL._AC_UF1000,1000_QL80_.jpg',
        condition: 'Regular',
        ownerId: 'user3',
        genre: 'Ficção Científica',
        description: 'Descrição do livro 3',
      ),
      Book(
        id: '4',
        title: 'O Guia do Mochileiro das Galáxias',
        author: 'Douglas Adams',
        imageUrl:
            'https://m.media-amazon.com/images/I/81XSN3KysmL._AC_UF1000,1000_QL80_.jpg',
        condition: 'Perfeito',
        ownerId: 'user4',
        genre: 'Comédia',
        description: 'Descrição do livro 4',
      ),
      Book(
        id: '5',
        title: 'Percy Jackson e o Ladrão de Raios',
        author: 'Rick Riordan',
        imageUrl:
            'https://m.media-amazon.com/images/I/71e456+vJbL._AC_UF1000,1000_QL80_.jpg',
        condition: 'Bom',
        ownerId: 'user5',
        genre: 'Aventura',
        description: 'Descrição do livro 5',
      ),
      Book(
        id: '6',
        title: 'Orgulho e Preconceito',
        author: 'Jane Austen',
        imageUrl:
            'https://m.media-amazon.com/images/I/71pcIHByHzL._AC_UF1000,1000_QL80_.jpg',
        condition: 'Regular',
        ownerId: 'user1',
        genre: 'Romance',
        description: 'Descrição do livro 6',
      ),
      Book(
        id: '7',
        title: '1984',
        author: 'George Orwell',
        imageUrl:
            'https://m.media-amazon.com/images/I/81StSOpmkjL._AC_UF1000,1000_QL80_.jpg',
        condition: 'Bom',
        ownerId: 'user2',
        genre: 'Distopia',
        description: 'Descrição do livro 7',
      ),
      Book(
        id: '8',
        title: 'Jogos Vorazes',
        author: 'Suzanne Collins',
        imageUrl:
            'https://m.media-amazon.com/images/I/614SwlZNtJL._AC_UF1000,1000_QL80_.jpg',
        condition: 'Perfeito',
        ownerId: 'user3',
        genre: 'Distopia',
        description: 'Descrição do livro 8',
      ),
    ];
  }
}
