import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/models/book_request.dart';
import 'package:qine_corner/core/providers/auth_provider.dart';
import 'package:qine_corner/core/services/book_request_service.dart';
import 'package:qine_corner/screens/auth/verification_screen.dart';

class BookRequestScreen extends ConsumerStatefulWidget {
  final String? initialTitle;

  const BookRequestScreen({
    Key? key,
    this.initialTitle,
  }) : super(key: key);

  @override
  ConsumerState<BookRequestScreen> createState() => _BookRequestScreenState();
}

class _BookRequestScreenState extends ConsumerState<BookRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  final _authorController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final authState = ref.read(authNotifierProvider);
      
      final userId = authState.whenOrNull(
        data: (state) => state?.userId,
      );

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to request books')),
          );
        }
        return;
      }

      // Get the book request service
      final bookRequestService = ref.read(bookRequestServiceProvider);

      // Submit the request
      await bookRequestService.submitRequest(
        userId: userId,
        title: _titleController.text.trim(),
        author: _authorController.text.trim().isNotEmpty 
            ? _authorController.text.trim() 
            : null,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book request submitted successfully!')),
      );

      // Clear the form
      _titleController.clear();
      _authorController.clear();

      // Navigate back
      context.pop();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting request: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildRequestForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Can\'t find the book you\'re looking for? Request it here!',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Book Title *',
              hintText: 'Enter the book title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the book title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _authorController,
            decoration: const InputDecoration(
              labelText: 'Author Name (Optional)',
              hintText: 'Enter the author\'s name if known',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRequest,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator()
                : const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request a Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: authState.when(
          data: (state) {
            if (state == null || !state.token.isNotEmpty) {
              return const Center(
                child: Text('Please login to request books'),
              );
            }
            if (!state.isVerified) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                        'Please verify your phone number to request books'),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerificationScreen(
                              userId: state.userId!,
                              phone: state.phone!,
                            ),
                          ),
                        );
                      },
                      child: const Text('Verify Now'),
                    ),
                  ],
                ),
              );
            }
            return _buildRequestForm();
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
