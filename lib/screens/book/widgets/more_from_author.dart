import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';
import 'package:qine_corner/core/api/api_service.dart';
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
    final apiService = ref.read(apiServiceProvider);
    final searchService = SearchService(apiService);
    final authorBooks = searchService.getBooksByAuthor(
      currentBook.author.id,
      excludeBookId: currentBook.id,
    );

    return FutureBuilder<List<Book>>(
      future: authorBooks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingAnimation();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
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
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == snapshot.data!.length - 1 ? 0 : 8.0,
                    ),
                    child: SizedBox(
                      width: 160, // Adjust based on your BookCard width
                      child: BookCard(
                        book: snapshot.data![index],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
