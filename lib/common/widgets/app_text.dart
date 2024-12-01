import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  // Heading 1 - Largest
  factory AppText.h1(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) = _H1Text;

  // Heading 2
  factory AppText.h2(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) = _H2Text;

  // Heading 3
  factory AppText.h3(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) = _H3Text;

  // Body text - Regular
  factory AppText.body(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    required bool bold,
    int? maxLines,
    TextOverflow? overflow,
  }) = _BodyText;

  // Body text - Small
  factory AppText.small(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    required bool bold,
    int? maxLines,
    TextOverflow? overflow,
  }) = _SmallText;

  // Label text
  factory AppText.label(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) = _LabelText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Text(
      text,
      style: style?.copyWith(color: style?.color ?? defaultColor),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class _H1Text extends AppText {
  _H1Text(
    String text, {
    super.key,
    Color? color,
    TextAlign? textAlign,
  }) : super(
          text,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1.2,
          ),
          textAlign: textAlign,
        );
}

class _H2Text extends AppText {
  _H2Text(
    String text, {
    super.key,
    Color? color,
    TextAlign? textAlign,
  }) : super(
          text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1.2,
          ),
          textAlign: textAlign,
        );
}

class _H3Text extends AppText {
  _H3Text(
    String text, {
    super.key,
    Color? color,
    TextAlign? textAlign,
  }) : super(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1.2,
          ),
          textAlign: textAlign,
        );
}

class _BodyText extends AppText {
  _BodyText(
    String text, {
    super.key,
    Color? color,
    TextAlign? textAlign,
    required bool bold,
    int? maxLines,
    TextOverflow? overflow,
  }) : super(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            color: color,
            height: 1.5,
          ),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
}

class _SmallText extends AppText {
  _SmallText(
    String text, {
    super.key,
    Color? color,
    TextAlign? textAlign,
    required bool bold,
    int? maxLines,
    TextOverflow? overflow,
  }) : super(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            color: color,
            height: 1.5,
          ),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
}

class _LabelText extends AppText {
  _LabelText(
    String text, {
    super.key,
    Color? color,
    TextAlign? textAlign,
  }) : super(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
            letterSpacing: 0.5,
            height: 1.5,
          ),
          textAlign: textAlign,
        );
}
