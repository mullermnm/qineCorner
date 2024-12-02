import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    return true; // iOS doesn't need storage permission for app's documents directory
  }

  static Future<String> getDownloadPath() async {
    try {
      if (Platform.isAndroid) {
        // For Android, use the Downloads directory
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('Could not access storage directory');
        }
        
        // Create a specific folder for our app's downloads
        final downloadDir = Directory('${directory.path}/QineCorner/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir.path;
      } else {
        // For iOS, use the Documents directory
        final directory = await getApplicationDocumentsDirectory();
        final downloadDir = Directory('${directory.path}/QineCorner/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir.path;
      }
    } catch (e) {
      debugPrint('Error getting download path: $e');
      rethrow;
    }
  }
}
