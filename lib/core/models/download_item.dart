class DownloadItem {
  final String fileName;
  final String filePath;
  final double progress;
  final bool isCompleted;
  final bool hasError;
  final String? error;

  DownloadItem({
    required this.fileName,
    required this.filePath,
    this.progress = 0.0,
    this.isCompleted = false,
    this.hasError = false,
    this.error,
  });

  DownloadItem copyWith({
    String? fileName,
    String? filePath,
    double? progress,
    bool? isCompleted,
    bool? hasError,
    String? error,
  }) {
    return DownloadItem(
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      hasError: hasError ?? this.hasError,
      error: error ?? this.error,
    );
  }
}
