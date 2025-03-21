import 'package:flutter/material.dart';
import 'package:qine_corner/core/theme/app_colors.dart';

class AuthConstants {
  static const Color kPrimaryColor = AppColors.accentMint;
  static const Color kPrimaryLightColor = AppColors.lightBackground;

  static const TextStyle titleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: kPrimaryColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle linkTextStyle = TextStyle(
    fontSize: 14,
    color: kPrimaryColor,
    fontWeight: FontWeight.w600,
  );

  static InputDecoration textFieldDecoration({
    required String hintText,
    required IconData icon,
    required String labelText,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      labelStyle: const TextStyle(
        color: kPrimaryColor,
      ),
      prefixIcon: Icon(
        icon,
        color: kPrimaryColor,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(29),
        borderSide: const BorderSide(color: kPrimaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(29),
        borderSide: const BorderSide(color: kPrimaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(29),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
      filled: true,
      fillColor: kPrimaryLightColor,
    );
  }

  static ButtonStyle elevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: kPrimaryColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(29),
      ),
      disabledBackgroundColor: kPrimaryColor,
      disabledForegroundColor: Colors.white,
    );
  }

  static ButtonStyle outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: kPrimaryColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(29),
      ),
      side: const BorderSide(color: kPrimaryColor),
    );
  }
}
