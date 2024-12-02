import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/providers/favorite_provider.dart';
import 'package:qine_corner/screens/book/pdf_viewer_screen.dart';
import 'widgets/detailed_book_card.dart';
import 'widgets/favorites_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: const FavoritesWidget(
        showTitle: false,
        showRemoveButton: true,
      ),
    );
  }
}
