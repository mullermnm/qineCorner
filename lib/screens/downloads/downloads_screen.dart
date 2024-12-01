import 'package:flutter/material.dart';
import '../../common/widgets/app_text.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.h1('Downloads'),
      ),
      body: Center(
        child: AppText.body('Downloads Screen', bold: false),
      ),
    );
  }
}
