import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingAnimation extends StatelessWidget {
  final double size;
  final Color? color;
  final bool repeat;

  const LoadingAnimation({
    super.key,
    this.size = 150,
    this.color,
    this.repeat = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          'assets/animations/loading.json',
          repeat: repeat,
          animate: true,
          frameRate: FrameRate.max,
        ),
      ),
    );
  }
}
