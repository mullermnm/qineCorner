import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/notes_provider.dart';

class NotesFilterBar extends ConsumerWidget {
  final Function(String) onSearchChanged;
  final Function(String) onTagSelected;
  final Set<String> selectedTags;

  const NotesFilterBar({
    Key? key,
    required this.onSearchChanged,
    required this.onTagSelected,
    required this.selectedTags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final allTags = notes.fold<Set<String>>(
      {},
      (tags, note) => tags..addAll(note.tags),
    ).toList()..sort();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search notes...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        if (allTags.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: allTags.map((tag) {
                final isSelected = selectedTags.contains(tag);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(tag),
                    onSelected: (selected) => onTagSelected(tag),
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }).toList(),
            ),
          ),
        SizedBox(height: 8),
      ],
    );
  }
}
