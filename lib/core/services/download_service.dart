// download_service.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/services/permission_service.dart';
import 'package:go_router/go_router.dart';
import 'package:qine_corner/core/providers/downloads_provider.dart';
import 'package:path/path.dart' as path;

class DownloadService {
  static Future<bool> downloadPDF(
    String assetPath,
    String fileName,
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Get download directory first to check if file exists
      final downloadPath = await PermissionService.getDownloadPath();
      final filePath = path.join(downloadPath, fileName);
      final file = File(filePath);

      // Check if file already exists and is in downloads list
      final downloads = ref.read(downloadsProvider);
      final existingDownload = downloads.where((d) => d.filePath == filePath).firstOrNull;

      if (await file.exists() || existingDownload != null) {
        if (context.mounted) {
          // If file exists but not in downloads list, add it
          if (existingDownload == null) {
            ref.read(downloadsProvider.notifier).addDownload(fileName, filePath);
            ref.read(downloadsProvider.notifier).completeDownload(filePath);
          }

          // Navigate to downloads screen
          GoRouter.of(context).push('/downloads');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File already downloaded'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return true;
      }

      // Request storage permission first
      final hasPermission = await PermissionService.requestStoragePermission();
      
      // If permission is denied and context is still valid
      if (!hasPermission && context.mounted) {
        await PermissionService.requestStoragePermission();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Storage permission is required to download books. Please grant permission in settings.'),
            duration: Duration(seconds: 3),
          ),
        );
        return false;
      }

      // If we have permission, proceed with download
      if (hasPermission) {
        // Create directory if it doesn't exist
        final directory = Directory(downloadPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        // Add to downloads screen and navigate immediately
        ref.read(downloadsProvider.notifier).addDownload(fileName, filePath);
        if (context.mounted) {
          GoRouter.of(context).push('/downloads');
        }

        try {
          // Load asset file
          final ByteData data = await rootBundle.load(assetPath);
          final bytes = data.buffer.asUint8List();
          final totalBytes = bytes.length;
          var downloadedBytes = 0;

          // Write to file in chunks to show progress
          final sink = file.openWrite();

          // Process download in chunks
          const chunkSize = 1024 * 10; // 10KB chunks
          for (var i = 0; i < bytes.length; i += chunkSize) {
            final end =
                (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
            final chunk = bytes.sublist(i, end);
            sink.add(chunk);
            downloadedBytes += chunk.length;

            // Update progress
            final progress = downloadedBytes / totalBytes;
            ref
                .read(downloadsProvider.notifier)
                .updateProgress(filePath, progress);

            // Small delay to show progress (remove in production if not needed)
            await Future.delayed(const Duration(milliseconds: 50));
          }

          await sink.close();
          ref.read(downloadsProvider.notifier).completeDownload(filePath);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Download completed successfully'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.greenAccent,
              ),
            );
          }

          return true;
        } catch (e) {
          ref.read(downloadsProvider.notifier).setError(filePath, e.toString());
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error downloading file: ${e.toString()}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          return false;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return false;
    }
  }
}
