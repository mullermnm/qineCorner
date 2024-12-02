import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/download_item.dart';

final downloadsProvider =
    StateNotifierProvider<DownloadsNotifier, List<DownloadItem>>((ref) {
  return DownloadsNotifier();
});

class DownloadsNotifier extends StateNotifier<List<DownloadItem>> {
  DownloadsNotifier() : super([]);

  void addDownload(String fileName, String filePath) {
    state = [
      ...state,
      DownloadItem(
        fileName: fileName,
        filePath: filePath,
      ),
    ];
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
