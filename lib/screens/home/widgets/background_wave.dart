import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BackgroundWave extends StatelessWidget {
  final double height;
  final double scrollProgress;

  const BackgroundWave({
    Key? key, 
    required this.height,
    required this.scrollProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipPath(
          clipper: BackgroundWaveClipper(),
          child: Opacity(
            opacity: 1 - (scrollProgress * 2).clamp(0.0, 1.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  AppColors.accentMint,
                  AppColors.accentMint.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )),
            ),
          )),
    );
  }
}

class BackgroundWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    const minSize = 140.0;

    // when h = max = 280
    // h = 280, p1 = 210, p1Diff = 70
    // when h = min = 140
    // h = 140, p1 = 140, p1Diff = 0
    final p1Diff = ((minSize - size.height) * 0.5).truncate().abs();
    path.lineTo(0.0, size.height - p1Diff);

    final controlPoint = Offset(size.width * 0.4, size.height);
    final endPoint = Offset(size.width, minSize);

    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(BackgroundWaveClipper oldClipper) => oldClipper != this;
}
