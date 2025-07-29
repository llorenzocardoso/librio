import 'package:flutter/material.dart';
import 'package:librio/src/domain/domain.dart';
import 'exchange_book_thumbnail.dart';

class ExchangeBooksDisplay extends StatelessWidget {
  final Exchange exchange;

  const ExchangeBooksDisplay({
    Key? key,
    required this.exchange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Livro oferecido
        ExchangeBookThumbnail(
          imageUrl: exchange.proposerBookImageUrl,
          title: exchange.proposerBookTitle,
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
        ExchangeBookThumbnail(
          imageUrl: exchange.receiverBookImageUrl,
          title: exchange.receiverBookTitle,
        ),
      ],
    );
  }
}
