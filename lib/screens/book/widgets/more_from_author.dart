import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/book.dart';
import '../../../core/services/search_service.dart';
import 'book_card.dart';

class MoreFromAuthor extends ConsumerWidget {
  final Book currentBook;

  const MoreFromAuthor({
    Key? key,
    required this.currentBook,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchService = SearchService();
    final authorBooks = searchService.getBooksByAuthor(
      currentBook.author.id,
      excludeBookId: currentBook.id,
    );

    if (authorBooks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            'More from ${currentBook.author.name}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280, // Adjust based on your BookCard height
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            scrollDirection: Axis.horizontal,
            itemCount: authorBooks.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == authorBooks.length - 1 ? 0 : 8.0,
                ),
                child: SizedBox(
                  width: 160, // Adjust based on your BookCard width
                  child: BookCard(
                    book: authorBooks[index],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
