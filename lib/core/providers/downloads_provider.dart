import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/download_item.dart';
import 'dart:io';

final downloadsProvider =
    StateNotifierProvider<DownloadsNotifier, List<DownloadItem>>((ref) {
  return DownloadsNotifier();
});

class DownloadsNotifier extends StateNotifier<List<DownloadItem>> {
  DownloadsNotifier() : super([]);

  void addDownload(String fileName, String filePath) {
    // Check if download already exists in the list
    final existing = state.where((item) => item.filePath == filePath).toList();
    
    if (existing.isNotEmpty) {
      // If already in the list, update it instead of adding a duplicate
      final existingItem = existing.first;
      if (!existingItem.isCompleted) {
        // Update the existing item's progress if needed
        completeDownload(filePath);
      }
    } else {
      // Add new download item
      final file = File(filePath);
      final isCompleted = file.existsSync();
      
      state = [
        ...state,
        DownloadItem(
          fileName: fileName,
          filePath: filePath,
          progress: isCompleted ? 1.0 : 0.0,
          isCompleted: isCompleted,
        ),
      ];
      
      // If file already exists, mark as completed
      if (isCompleted) {
        completeDownload(filePath);
      }
    }
  }

  void updateProgress(String filePath, double progress) {
    state = [
      for (final item in state)
        if (item.filePath == filePath)
          item.copyWith(progress: progress)
        else
          item,
    ];
  }

  void completeDownload(String filePath) {
    state = [
      for (final item in state)
        if (item.filePath == filePath)
          item.copyWith(isCompleted: true, progress: 1.0)
        else
          item,
    ];
  }

  void setError(String filePath, String error) {
    state = [
      for (final item in state)
        if (item.filePath == filePath)
          item.copyWith(hasError: true, error: error)
        else
          item,
    ];
  }

  void removeDownload(String filePath) {
    state = state.where((item) => item.filePath != filePath).toList();
  }

  void clearCompleted() {
    state = state.where((item) => !item.isCompleted).toList();
  }
}
