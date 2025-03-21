import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/downloads_provider.dart';
import '../../core/models/download_item.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  void _openFile(String filePath, BuildContext context) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Open PDF viewer in a new screen
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text(file.path.split('/').last),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: SfPdfViewer.file(
                file,
                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error opening PDF: ${details.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: isDark
            ? AppColors.darkSurfaceBackground
            : AppColors.lightSurfaceBackground,
        actions: [
          if (downloads.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                ref.read(downloadsProvider.notifier).clearCompleted();
              },
              tooltip: 'Clear completed downloads',
            ),
        ],
      ),
      body: downloads.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.download_done_rounded,
                    size: 64,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No downloads yet',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: downloads.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final download = downloads[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(download.fileName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!download.isCompleted && !download.hasError)
                          LinearProgressIndicator(
                            value: download.progress,
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceBackground
                                : AppColors.lightSurfaceBackground,
                            valueColor: AlwaysStoppedAnimation(
                              download.progress == 1.0
                                  ? Colors.green
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        if (download.hasError)
                          Text(
                            download.error ?? 'Download failed',
                            style: const TextStyle(color: Colors.red),
                          ),
                        Text(
                          download.isCompleted
                              ? 'Completed'
                              : download.hasError
                                  ? 'Failed'
                                  : '${(download.progress * 100).toInt()}%',
                          style: TextStyle(
                            color: download.isCompleted
                                ? Colors.green
                                : download.hasError
                                    ? Colors.red
                                    : isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (download.isCompleted)
                          IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () => _openFile(download.filePath, context),
                            tooltip: 'Open file',
                          ),
                        IconButton(
                          icon: download.isCompleted
                              ? const Icon(Icons.delete)
                              : download.hasError
                                  ? const Icon(Icons.refresh, color: Colors.orange)
                                  : const Icon(Icons.close),
                          onPressed: () {
                            if (download.hasError) {
                              // TODO: Implement retry functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Retry not implemented yet')),
                              );
                            } else {
                              ref.read(downloadsProvider.notifier).removeDownload(download.filePath);
                            }
                          },
                          tooltip: download.hasError
                              ? 'Retry download'
                              : 'Remove from list',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
