import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/features/book_rating/domain/book_rating_model.dart';
import 'package:qine_corner/features/book_rating/presentation/widgets/book_rating_dialog.dart';
import 'package:qine_corner/features/book_rating/presentation/widgets/star_rating_widget.dart';
import 'package:qine_corner/features/book_rating/providers/book_rating_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class BookRatingsSection extends ConsumerWidget {
  final String bookId;

  const BookRatingsSection({
    Key? key,
    required this.bookId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userRatingAsync = ref.watch(userBookRatingProvider(bookId));
    final bookRatingsAsync = ref.watch(bookRatingsProvider(bookId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Ratings & Reviews',
            style: theme.textTheme.titleLarge,
          ),
        ),
        
        // User's rating section
        userRatingAsync.when(
          data: (userRating) => _buildUserRatingSection(context, userRating, ref),
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading your rating: $error'),
          ),
        ),

        const Divider(),

        // All ratings section
        bookRatingsAsync.when(
          data: (ratings) => _buildAllRatingsSection(context, ratings),
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading ratings: $error'),
          ),
        ),
      ],
    );
  }

  Widget _buildUserRatingSection(BuildContext context, BookRating? userRating, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userRating != null ? 'Your Rating' : 'Rate This Book',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (userRating != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StarRatingWidget(rating: userRating.rating),
                    const SizedBox(width: 8),
                    Text('${userRating.rating.toStringAsFixed(1)}/5.0'),
                  ],
                ),
                if (userRating.review != null && userRating.review!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(userRating.review!),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showRatingDialog(context, userRating),
                  child: const Text('Edit Your Rating'),
                ),
              ],
            )
          else
            ElevatedButton(
              onPressed: () => _showRatingDialog(context, null),
              child: const Text('Add Your Rating'),
            ),
        ],
      ),
    );
  }

  Widget _buildAllRatingsSection(BuildContext context, List<BookRating> ratings) {
    if (ratings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No ratings yet. Be the first to rate this book!')),
      );
    }

    // Calculate average rating
    final totalRating = ratings.fold<double>(0, (sum, rating) => sum + rating.rating);
    final averageRating = totalRating / ratings.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average rating summary
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StarRatingWidget(rating: averageRating, size: 20),
                  Text('${ratings.length} ${ratings.length == 1 ? 'rating' : 'ratings'}'),
                ],
              ),
            ],
          ),
        ),

        // Individual reviews
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ratings.length,
          itemBuilder: (context, index) {
            final rating = ratings[index];
            return _buildReviewItem(context, rating);
          },
        ),
      ],
    );
  }

  Widget _buildReviewItem(BuildContext context, BookRating rating) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (rating.userProfileImage != null)
                CircleAvatar(
                  backgroundImage: NetworkImage(rating.userProfileImage!),
                  radius: 16,
                )
              else
                const CircleAvatar(
                  child: Icon(Icons.person, size: 16),
                  radius: 16,
                ),
              const SizedBox(width: 8),
              Text(
                rating.userName ?? 'Anonymous',
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (rating.createdAt != null)
                Text(
                  timeago.format(rating.createdAt!),
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: 4),
          StarRatingWidget(rating: rating.rating, size: 16),
          if (rating.review != null && rating.review!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(rating.review!),
          ],
          const Divider(),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, BookRating? existingRating) {
    showDialog(
      context: context,
      builder: (context) => BookRatingDialog(
        bookId: bookId,
        existingRating: existingRating,
      ),
    );
  }
}
