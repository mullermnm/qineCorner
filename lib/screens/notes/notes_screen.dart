import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/notes_provider.dart';
import '../../core/models/note.dart';

class NotesScreen extends ConsumerWidget {
  final String? initialBookTitle;

  const NotesScreen({
    Key? key,
    this.initialBookTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final filteredNotes = initialBookTitle != null
        ? notes.where((note) => note.bookTitle == initialBookTitle).toList()
        : notes;
    final groupedNotes = _groupNotesByBook(filteredNotes);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reading Notes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groupedNotes.length,
        itemBuilder: (context, index) {
          final bookTitle = groupedNotes.keys.elementAt(index);
          final bookNotes = groupedNotes[bookTitle]!;
          
          return ExpansionTile(
            title: Text(
              bookTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: bookNotes.map((note) => NoteCard(note: note)).toList(),
          );
        },
      ),
    );
  }

  Map<String, List<Note>> _groupNotesByBook(List<Note> notes) {
    final grouped = <String, List<Note>>{};
    for (final note in notes) {
      if (!grouped.containsKey(note.bookTitle)) {
        grouped[note.bookTitle] = [];
      }
      grouped[note.bookTitle]!.add(note);
    }
    return grouped;
  }
}

class NoteCard extends ConsumerWidget {
  final Note note;

  const NoteCard({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page ${note.pageNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editNote(context, ref),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteNote(context, ref),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.noteText,
              style: const TextStyle(fontSize: 16),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: note.tags.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _editNote(BuildContext context, WidgetRef ref) {
    // TODO: Implement edit note functionality
  }

  void _deleteNote(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(notesProvider.notifier).deleteNote(note.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
