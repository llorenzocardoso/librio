import 'package:flutter/material.dart';
import 'package:librio/src/domain/entities/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // A ListView pai no ProfileScreen renderiza itens com 150px de altura.
    const double cardHeight = 150.0;

    // Defina a proporção desejada para a capa do livro (largura / altura).
    // Uma proporção comum para capas de livro é algo em torno de 2:3.
    // Exemplo: Se a altura tem 3 unidades, a largura terá 2 unidades.
    const double bookAspectRatio = 2 / 3; // Largura dividida pela Altura

    // Calcule a largura do card para manter a proporção com a altura fixa.
    const double cardWidth =
        cardHeight * bookAspectRatio; // Ex: 150 * (2/3) = 100px

    return SizedBox(
      width: cardWidth,
      height: cardHeight, // Garante que o SizedBox tenha as dimensões corretas
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          clipBehavior: Clip
              .antiAlias, // Importante para que a imagem respeite as bordas arredondadas
          elevation: 2,
          shape: RoundedRectangleBorder(
            // Ajuste o raio da borda para se assemelhar ao protótipo (parece ser entre 8 e 12)
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: book.imageUrl.isNotEmpty
              ? Image.network(
                  book.imageUrl,
                  fit: BoxFit
                      .cover, // Faz a imagem cobrir todo o espaço do Card,
                  // mantendo sua proporção e cortando o excesso se necessário.
                  errorBuilder: (ctx, e, s) => const Center(
                    child: Icon(Icons.image_not_supported,
                        size: 40, color: Colors.grey),
                  ),
                )
              : Container(
                  // Placeholder caso não haja imagem
                  decoration: BoxDecoration(
                    color: Colors.grey[
                        200], // Um cinza um pouco mais claro para o placeholder
                    borderRadius:
                        BorderRadius.circular(16.0), // Consistente com o Card
                  ),
                  child: const Center(
                    child: Icon(Icons.book, size: 50, color: Colors.grey),
                  ),
                ),
        ),
      ),
    );
  }
}
