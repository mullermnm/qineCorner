import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qine_corner/features/milestones/domain/milestone_model.dart';

class MilestoneCard extends StatefulWidget {
  final Milestone milestone;
  final GlobalKey repaintBoundaryKey;

  const MilestoneCard({
    Key? key,
    required this.milestone,
    required this.repaintBoundaryKey,
  }) : super(key: key);

  @override
  State<MilestoneCard> createState() => _MilestoneCardState();
}

class _MilestoneCardState extends State<MilestoneCard> {
  Future<void> _shareMilestone() async {
    try {
      RenderRepaintBoundary boundary = widget.repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/milestone_${widget.milestone.id}.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Check out my reading milestone!');
    } catch (e) {
      print('Error sharing milestone: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share milestone: $e')),
      );
    }
  }

  Future<void> _saveMilestone() async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required to save the milestone')),
        );
        return;
      }

      // Capture the milestone card as an image
      RenderRepaintBoundary boundary = widget.repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Get the pictures directory
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'milestone_${widget.milestone.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '${directory.path}/$fileName';

      // Save the image to the file system
      final File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Copy to downloads folder (for Android 10+)
      if (Platform.isAndroid) {
        final downloadsStatus = await Permission.manageExternalStorage.request();
        if (downloadsStatus.isGranted) {
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (await downloadsDir.exists()) {
            final downloadFile = File('${downloadsDir.path}/$fileName');
            await file.copy(downloadFile.path);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Milestone saved to Downloads folder: ${downloadFile.path}')),
            );
            return;
          }
        }
      }

      // If we couldn't save to downloads, just share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Save this milestone image');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please save the shared image to your gallery')),
      );
    } catch (e) {
      print('Error saving milestone: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save milestone: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return RepaintBoundary(
      key: widget.repaintBoundaryKey,
      child: Card(
        margin: const EdgeInsets.all(16.0),
        elevation: 6.0,
        shadowColor: colorScheme.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withOpacity(0.9),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        widget.milestone.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    widget.milestone.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16.0,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Achieved on: ${widget.milestone.achievedDate.toLocal().toString().split(' ')[0]}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _saveMilestone,
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: colorScheme.onPrimary,
                        backgroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    ElevatedButton.icon(
                      onPressed: _shareMilestone,
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        backgroundColor: colorScheme.primaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
