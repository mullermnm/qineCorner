import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/note.dart';
import '../../core/providers/notes_provider.dart';
import 'widgets/note_card.dart';
import 'widgets/notes_filter_bar.dart';

enum NotesViewType {
  list,
  grid,
  timeline
}

enum NotesSortType {
  recent,
  book,
  tags,
}

class NotesOverviewScreen extends ConsumerStatefulWidget {
  const NotesOverviewScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotesOverviewScreen> createState() => _NotesOverviewScreenState();
}

class _NotesOverviewScreenState extends ConsumerState<NotesOverviewScreen> {
  NotesViewType _viewType = NotesViewType.grid;
  NotesSortType _sortType = NotesSortType.recent;
  String _searchQuery = '';
  Set<String> _selectedTags = {};

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final filteredNotes = _filterAndSortNotes(notes);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes'),
        actions: [
          IconButton(
            icon: Icon(_viewType == NotesViewType.grid 
              ? Icons.view_list 
              : Icons.grid_view),
            onPressed: () {
              setState(() {
                _viewType = _viewType == NotesViewType.grid 
                  ? NotesViewType.list 
                  : NotesViewType.grid;
              });
            },
          ),
          PopupMenuButton<NotesSortType>(
            icon: Icon(Icons.sort),
            onSelected: (NotesSortType type) {
              setState(() {
                _sortType = type;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: NotesSortType.recent,
                child: Text('Most Recent'),
              ),
              PopupMenuItem(
                value: NotesSortType.book,
                child: Text('By Book'),
              ),
              PopupMenuItem(
                value: NotesSortType.tags,
                child: Text('By Tags'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          NotesFilterBar(
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onTagSelected: (tag) {
              setState(() {
                if (_selectedTags.contains(tag)) {
                  _selectedTags.remove(tag);
                } else {
                  _selectedTags.add(tag);
                }
              });
            },
            selectedTags: _selectedTags,
          ),
          Expanded(
            child: _viewType == NotesViewType.grid
                ? GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      return NoteCard(
                        note: filteredNotes[index],
                        onTap: () => _openNoteDetails(filteredNotes[index]),
                      );
                    },
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: NoteCard(
                          note: filteredNotes[index],
                          onTap: () => _openNoteDetails(filteredNotes[index]),
                          isListView: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new note creation
        },
        child: Icon(Icons.add),
      ),
    );
  }

  List<Note> _filterAndSortNotes(List<Note> notes) {
    var filtered = notes.where((note) {
      final matchesSearch = _searchQuery.isEmpty ||
          note.noteText.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.bookTitle.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesTags = _selectedTags.isEmpty ||
          note.tags.any((tag) => _selectedTags.contains(tag));
      
      return matchesSearch && matchesTags;
    }).toList();

    switch (_sortType) {
      case NotesSortType.recent:
        filtered.sort((a, b) => b.updatedAt?.compareTo(a.updatedAt ?? a.createdAt) ?? 
                               b.createdAt.compareTo(a.createdAt));
        break;
      case NotesSortType.book:
        filtered.sort((a, b) => a.bookTitle.compareTo(b.bookTitle));
        break;
      case NotesSortType.tags:
        filtered.sort((a, b) {
          if (a.tags.isEmpty && b.tags.isEmpty) return 0;
          if (a.tags.isEmpty) return 1;
          if (b.tags.isEmpty) return -1;
          return a.tags.first.compareTo(b.tags.first);
        });
        break;
    }

    return filtered;
  }

  void _openNoteDetails(Note note) {
    // TODO: Implement note details navigation
  }
}
