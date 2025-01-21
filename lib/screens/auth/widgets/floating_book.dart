import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingBook extends StatefulWidget {
  const FloatingBook({super.key});

  @override
  State<FloatingBook> createState() => _FloatingBookState();
}

class _FloatingBookState extends State<FloatingBook>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      top: MediaQuery.of(context).size.height * 0.15,
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Transform.rotate(
              angle: -math.pi / 12,
              child: SizedBox(
                width: 150,
                height: 150,
                child: Icon(
                  Icons.menu_book,
                  size: 150,
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
