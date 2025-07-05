import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/features/book_rating/domain/book_rating_model.dart';
import 'package:qine_corner/features/book_rating/presentation/widgets/star_rating_widget.dart';
import 'package:qine_corner/features/book_rating/providers/book_rating_provider.dart';

class BookRatingDialog extends ConsumerStatefulWidget {
  final String bookId;
  final BookRating? existingRating;

  const BookRatingDialog({
    Key? key,
    required this.bookId,
    this.existingRating,
  }) : super(key: key);

  @override
  ConsumerState<BookRatingDialog> createState() => _BookRatingDialogState();
}

class _BookRatingDialogState extends ConsumerState<BookRatingDialog> {
  late double _rating;
  late TextEditingController _reviewController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingRating?.rating ?? 0;
    _reviewController = TextEditingController(text: widget.existingRating?.review ?? '');
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(bookRatingNotifierProvider.notifier).rateBook(
            widget.bookId,
            _rating,
            review: _reviewController.text.isNotEmpty ? _reviewController.text : null,
          );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit rating: ${e.toString()}')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _deleteRating() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(bookRatingNotifierProvider.notifier).deleteRating(widget.bookId);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete rating: ${e.toString()}')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existingRating != null ? 'Update Your Rating' : 'Rate This Book',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            StarRatingWidget(
              rating: _rating,
              size: 36,
              interactive: true,
              onRatingChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                hintText: 'Write your review (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.existingRating != null)
                  TextButton(
                    onPressed: _isSubmitting ? null : _deleteRating,
                    child: const Text('Delete Rating'),
                  )
                else
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRating,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.existingRating != null ? 'Update' : 'Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
