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
import 'package:path_provider/path_provider.dart';
import 'package:qine_corner/core/config/app_config.dart';
import 'package:dio/dio.dart';

class DownloadService {
  static Future<void> downloadPDF(
    String url,
    String fileName,
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Request storage permission directly from system
    bool hasPermission = await PermissionService.checkStoragePermission(context);
    
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to download books'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final fullUrl = AppConfig.getAssetUrl(url);
    final dio = Dio();
    
    try {
      // Show download starting
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Starting download...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Get download directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final savePath = "${appDocDir.path}/$fileName";
      
      // Check if file already exists
      if (await File(savePath).exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File already downloaded'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // Add to downloads list as completed since file already exists
        ref.read(downloadsProvider.notifier).addDownload(fileName, savePath);
        ref.read(downloadsProvider.notifier).completeDownload(savePath);
        
        // Navigate to downloads page to show the file
        if (context.mounted) {
          context.push('/downloads');
        }
        return;
      }
      
      // Start download with progress tracking
      await dio.download(
        fullUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            // Update progress in provider
            ref.read(downloadsProvider.notifier).updateProgress(savePath, progress);
          }
        },
      );
      
      // Mark download as complete
      ref.read(downloadsProvider.notifier).completeDownload(savePath);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download complete: $fileName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // Add to downloads list
      ref.read(downloadsProvider.notifier).addDownload(fileName, savePath);
      
      // Navigate to downloads page to show progress
      if (context.mounted) {
        context.push('/downloads');
      }
      
    } catch (e) {
      print('Download error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  static Future<void> openFile(String path, BuildContext context) async {
    try {
      // Implementation depends on what PDF viewer you're using
      // This is a placeholder - will be implemented by the user
      print('Opening file: $path');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
