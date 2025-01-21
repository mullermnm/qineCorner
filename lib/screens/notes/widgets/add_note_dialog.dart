import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/notes_provider.dart';
import '../../../core/models/note.dart';

class AddNoteDialog extends ConsumerStatefulWidget {
  final String bookTitle;
  final int currentPage;

  const AddNoteDialog({
    Key? key,
    required this.bookTitle,
    required this.currentPage,
  }) : super(key: key);

  @override
  ConsumerState<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends ConsumerState<AddNoteDialog> {
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();
  bool _isImportant = false;
  final List<String> _tags = [];

  @override
  void dispose() {
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _saveNote() {
    if (_noteController.text.isEmpty) return;

    final note = Note(
      id: DateTime.now().toIso8601String(),
      bookTitle: widget.bookTitle,
      pageNumber: widget.currentPage,
      noteText: _noteController.text,
      createdAt: DateTime.now(),
      tags: _tags,
      isImportant: _isImportant,
    );

    ref.read(notesProvider.notifier).addNote(note);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Note',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your note...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'Add tag',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          onDeleted: () => _removeTag(tag),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isImportant,
                  onChanged: (value) {
                    setState(() {
                      _isImportant = value ?? false;
                    });
                  },
                ),
                const Text('Mark as Important'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveNote,
                  child: const Text('Save Note'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
