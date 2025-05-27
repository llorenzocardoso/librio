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
    return LayoutBuilder(
      builder: (context, constraints) {
        // If parent width is unbounded, fallback to a fixed width
        final double cardWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 150;
        return SizedBox(
          width: cardWidth,
          child: GestureDetector(
            onTap: onTap,
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: book.imageUrl.isNotEmpty
                        ? Image.network(
                            book.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, e, s) => const Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.book,
                                  size: 50, color: Colors.grey),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
