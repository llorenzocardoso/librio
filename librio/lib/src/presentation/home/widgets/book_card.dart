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
    const double cardHeight = 150.0;

    const double bookAspectRatio = 2 / 3;

    const double cardWidth = cardHeight * bookAspectRatio;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: book.imageUrl.isNotEmpty
              ? Image.network(
                  book.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, s) => const Center(
                    child: Icon(Icons.image_not_supported,
                        size: 40, color: Colors.grey),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16.0),
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
