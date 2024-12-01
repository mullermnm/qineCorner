import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  final double progress;

  WaveClipper({
    this.progress = 0.0,
  });

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height * 0.85); //start path with this if you need move it upward

    double x = 0;
    double y = size.height * 0.85;
    double yControlPoint = size.height * 0.85;

    //first point of quadratic bezier curve
    var firstStart = Offset(x, y);
    //point where curve goes
    x = size.width * 0.33;
    y = size.height * 0.85;
    var firstEnd = Offset(x, y);
    //control point through which curve being drawn
    x = size.width * 0.16;
    yControlPoint = size.height * 0.85 + (30 * (1 - progress));
    var firstControl = Offset(x, yControlPoint);
    path.quadraticBezierTo(
        firstControl.dx, firstControl.dy, firstEnd.dx, firstEnd.dy);

    //second point of quadratic bezier curve
    var secondStart = Offset(x, y);
    //point where curve goes
    x = size.width * 0.66;
    y = size.height * 0.85;
    var secondEnd = Offset(x, y);
    //control point through which curve being drawn
    x = size.width * 0.5;
    yControlPoint = size.height * 0.85 - (30 * (1 - progress));
    var secondControl = Offset(x, yControlPoint);
    path.quadraticBezierTo(
        secondControl.dx, secondControl.dy, secondEnd.dx, secondEnd.dy);

    //third point of quadratic bezier curve
    var thirdStart = Offset(x, y);
    //point where curve goes
    x = size.width;
    y = size.height * 0.85;
    var thirdEnd = Offset(x, y);
    //control point through which curve being drawn
    x = size.width * 0.83;
    yControlPoint = size.height * 0.85 + (30 * (1 - progress));
    var thirdControl = Offset(x, yControlPoint);
    path.quadraticBezierTo(
        thirdControl.dx, thirdControl.dy, thirdEnd.dx, thirdEnd.dy);

    //forth point of quadratic bezier curve
    path.lineTo(size.width, 0.0); //end with this

    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) {
    return progress != oldClipper.progress;
  }
}
