import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import 'notes_provider.dart';

final noteRewindProvider = Provider<Note?>((ref) {
  final notes = ref.watch(notesProvider);
  if (notes.isEmpty) return null;

  // Get a random note from the past week
  final now = DateTime.now();
  final pastNotes = notes.where((note) {
    final noteDate = note.updatedAt ?? note.createdAt;
    final difference = now.difference(noteDate).inDays;
    return difference > 7; // Only show notes older than a week
  }).toList();

  if (pastNotes.isEmpty) return null;

  // Get a random note
  final random = Random();
  return pastNotes[random.nextInt(pastNotes.length)];
});

final noteRewindNotifierProvider =
    StateNotifierProvider<NoteRewindNotifier, Note?>((ref) {
  return NoteRewindNotifier(ref);
});

class NoteRewindNotifier extends StateNotifier<Note?> {
  final Ref _ref;
  
  NoteRewindNotifier(this._ref) : super(null) {
    _loadRandomNote();
  }

  Future<void> _loadRandomNote() async {
    state = _ref.read(noteRewindProvider);
  }

  Future<void> refreshRandomNote() async {
    _loadRandomNote();
  }
}
