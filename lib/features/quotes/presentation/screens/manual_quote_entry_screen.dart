import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/features/quotes/domain/models/quote.dart';
import 'package:qine_corner/features/quotes/presentation/providers/quote_provider.dart';

class ManualQuoteEntryScreen extends ConsumerStatefulWidget {
  const ManualQuoteEntryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ManualQuoteEntryScreen> createState() => _ManualQuoteEntryScreenState();
}

class _ManualQuoteEntryScreenState extends ConsumerState<ManualQuoteEntryScreen> {
  final _quoteController = TextEditingController();
  final _bookTitleController = TextEditingController();
  final _authorNameController = TextEditingController();
  final _userNameController = TextEditingController();

  @override
  void dispose() {
    _quoteController.dispose();
    _bookTitleController.dispose();
    _authorNameController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  void _saveQuote() {
    if (_quoteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quote cannot be empty')),
      );
      return;
    }

    final newQuote = Quote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _quoteController.text,
      bookTitle: _bookTitleController.text.isNotEmpty ? _bookTitleController.text : null,
      authorName: _authorNameController.text.isNotEmpty ? _authorNameController.text : null,
      userName: _userNameController.text.isNotEmpty ? _userNameController.text : null,
      createdAt: DateTime.now(),
    );

    ref.read(quoteNotifierProvider.notifier).addQuote(newQuote);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote saved successfully!')),
    );
    context.pop(); // Go back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Quote Manually'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _quoteController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Quote',
                hintText: 'Enter the quote here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _bookTitleController,
              decoration: const InputDecoration(
                labelText: 'Book Title (Optional)',
                hintText: 'e.g., The Great Gatsby',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _authorNameController,
              decoration: const InputDecoration(
                labelText: 'Author Name (Optional)',
                hintText: 'e.g., F. Scott Fitzgerald',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'Your Name (Optional)',
                hintText: 'e.g., John Doe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _saveQuote,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Save Quote',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
