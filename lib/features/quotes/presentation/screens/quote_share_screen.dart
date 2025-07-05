import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';

import 'package:qine_corner/features/quotes/domain/models/quote.dart';
import 'package:qine_corner/features/quotes/presentation/widgets/quote_card.dart';

class QuoteShareScreen extends ConsumerStatefulWidget {
  final Quote quote;

  const QuoteShareScreen({Key? key, required this.quote}) : super(key: key);

  @override
  ConsumerState<QuoteShareScreen> createState() => _QuoteShareScreenState();
}

class _QuoteShareScreenState extends ConsumerState<QuoteShareScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  String _selectedTemplate = 'default';

  final List<String> _templates = [
    'default',
    'bold',
    'calm',
    'dark',
    'poetic',
    'minimalist',
  ];

  Future<void> _shareQuoteCard() async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/quote_${widget.quote.id}.png');
      await file.writeAsBytes(pngBytes);

      // TODO: Implement deep link and fallback message
      final String shareText = "Want to read more? Download Qine Corner now. [Deep Link/App Store Link]";

      await Share.shareXFiles([XFile(file.path)], text: shareText);
    } catch (e) {
      print('Error sharing quote: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share quote: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Quote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareQuoteCard,
            tooltip: 'Share Quote',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _repaintBoundaryKey,
                child: QuoteCard(
                  quote: widget.quote,
                  templateId: _selectedTemplate,
                ),
              ),
            ),
          ),
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTemplate = template;
                    });
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedTemplate == template
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        width: 3.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Stack(
                        children: [
                          // Placeholder for template preview
                          Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Text(
                                template,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          // You might render a miniature QuoteCard here for a real preview
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
