import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  static Future<bool> checkStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      // Get the appropriate permission based on Android version
      Permission permission;
      if (await _isAndroid13OrHigher()) {
        permission = Permission.photos; // For Android 13+ (SDK 33+)
      } else {
        permission = Permission.storage; // For older Android versions
      }
      
      // Check current permission status
      PermissionStatus status = await permission.status;
      
      // If not granted yet, directly request from system
      if (!status.isGranted) {
        status = await permission.request();
      }
      
      // If still not granted and permanently denied, guide user to settings
      if (status.isPermanentlyDenied && context.mounted) {
        final shouldOpenSettings = await _showSettingsDialog(context);
        if (shouldOpenSettings) {
          await openAppSettings();
        }
      }
      
      return status.isGranted;
    }
    
    // iOS handles permissions differently
    if (Platform.isIOS) {
      return true; // iOS handles this when actually accessing files
    }
    
    return false;
  }
  
  // Helper to check Android version
  static Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    
    // Android 13 is API level 33
    return await DeviceInfoPlugin().androidInfo.then((info) => 
      info.version.sdkInt >= 33);
  }

  static Future<bool> _showSettingsDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Storage Permission Required'),
          content: const Text(
            'Storage permission is permanently denied. Please enable it in app settings to download books.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
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

  static Future<bool> isPermissionPermanentlyDenied() async {
    final status = await Permission.storage.status;
    return status.isPermanentlyDenied;
  }
}
