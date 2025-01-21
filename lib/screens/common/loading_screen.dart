import 'package:flutter/material.dart';
import 'package:qine_corner/common/widgets/loading_animation.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: LoadingAnimation(),
      ),
    );
  }
}
