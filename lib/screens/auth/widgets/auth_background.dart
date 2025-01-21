import 'package:flutter/material.dart';
import 'package:qine_corner/core/theme/auth_constants.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: size.width * 0.35,
              height: size.width * 0.35,
              decoration: BoxDecoration(
                color: AuthConstants.kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(size.width * 0.35),
                ),
              ),
              child: const Icon(
                Icons.book,
                size: 50,
                color: AuthConstants.kPrimaryColor,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size.width * 0.4,
              height: size.width * 0.4,
              decoration: BoxDecoration(
                color: AuthConstants.kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size.width * 0.4),
                ),
              ),
              child: const Icon(
                Icons.auto_stories,
                size: 60,
                color: AuthConstants.kPrimaryColor,
              ),
            ),
          ),
          // Add floating book icons
          Positioned(
            top: size.height * 0.2,
            right: size.width * 0.2,
            child: Icon(
              Icons.menu_book,
              size: 40,
              color: AuthConstants.kPrimaryColor.withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: size.height * 0.3,
            left: size.width * 0.1,
            child: Icon(
              Icons.library_books,
              size: 30,
              color: AuthConstants.kPrimaryColor.withOpacity(0.3),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}
