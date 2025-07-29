import 'package:flutter/material.dart';
import 'package:librio/src/domain/domain.dart';

class ExchangeBooksDisplay extends StatelessWidget {
  final Book? selectedBook;
  final Book receiverBook;
  final VoidCallback onSelectBook;

  const ExchangeBooksDisplay({
    Key? key,
    required this.selectedBook,
    required this.receiverBook,
    required this.onSelectBook,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Livro oferecido
        Expanded(
          child: Column(
            children: [
              GestureDetector(
                onTap: onSelectBook,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedBook != null
                          ? Colors.blue.shade300
                          : Colors.grey.shade300,
                      width: selectedBook != null ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: selectedBook != null
                        ? (selectedBook!.imageUrl.isNotEmpty
                            ? Image.network(
                                selectedBook!.imageUrl,
                                fit: BoxFit.contain,
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
                selectedBook?.title ?? 'Seu livro',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                selectedBook?.author ?? '',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (selectedBook != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextButton.icon(
                    onPressed: onSelectBook,
                    icon: const Icon(
                      Icons.swap_horiz,
                      size: 16,
                    ),
                    label: const Text(
                      'Trocar',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
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
                          fit: BoxFit.contain,
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
              Text(
                receiverBook.author,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
