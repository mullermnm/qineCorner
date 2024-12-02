import 'package:flutter/material.dart';
import 'package:qine_corner/core/models/book.dart';
import 'package:qine_corner/core/models/library.dart';
import 'package:qine_corner/core/theme/app_colors.dart';

class AddToLibrariesDialog extends StatelessWidget {
  final List<Library> libraries;
  final Book book;
  final Function(Library) onAddToLibrary;
  final Function(String) onCreateLibrary;

  const AddToLibrariesDialog({
    super.key,
    required this.libraries,
    required this.book,
    required this.onAddToLibrary,
    required this.onCreateLibrary,
  });

  void _showCreateLibraryDialog(BuildContext context) {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Library'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Library Name',
              hintText: 'Enter library name',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a library name';
              }
              return null;
            },
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                onCreateLibrary(textController.text.trim());
                Navigator.pop(context); // Close the libraries dialog
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add to Library',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (libraries.isNotEmpty) ...[
              const Text(
                'Choose a library:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: libraries.length,
                  itemBuilder: (context, index) {
                    final library = libraries[index];
                    return ListTile(
                      title: Text(library.name),
                      subtitle: Text('${library.bookCount} books'),
                      trailing: library.books.contains(book)
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : null,
                      onTap: () {
                        if (!library.books.contains(book)) {
                          onAddToLibrary(library);
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 32),
            ],
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create New Library'),
              onPressed: () => _showCreateLibraryDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
