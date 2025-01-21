import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier();
});

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier() : super([]) {
    _loadNotes();
  }

  static const String _key = 'notes';

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_key);
    if (notesJson != null) {
      state = notesJson
          .map((noteStr) => Note.fromJson(jsonDecode(noteStr)))
          .toList();
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = state.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList(_key, notesJson);
  }

  Future<void> addNote(Note note) async {
    state = [...state, note];
    await _saveNotes();
  }

  Future<void> updateNote(Note updatedNote) async {
    state = [
      for (final note in state)
        if (note.id == updatedNote.id) updatedNote else note
    ];
    await _saveNotes();
  }

  Future<void> deleteNote(String noteId) async {
    state = state.where((note) => note.id != noteId).toList();
    await _saveNotes();
  }

  List<Note> getNotesByBook(String bookTitle) {
    return state.where((note) => note.bookTitle == bookTitle).toList();
  }

  List<Note> searchNotes(String query) {
    return state.where((note) =>
        note.noteText.toLowerCase().contains(query.toLowerCase()) ||
        note.bookTitle.toLowerCase().contains(query.toLowerCase()) ||
        note.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }
}
