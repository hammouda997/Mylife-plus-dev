import 'package:flutter/material.dart';

class ResponsiveSize {
  final BuildContext context;
  ResponsiveSize(this.context);

  double get scaleFactor => MediaQuery.of(context).size.width / baseWidth;

  // Font Sizes
  double get titleFontSize => 18.0 * scaleFactor;
  double get subtitleFontSize => 18.0 * scaleFactor;
  double get bodyFontSize => 18.0 * scaleFactor;

  // Icon Sizes
  double get iconSizeLarge => 32.0 * scaleFactor;
  double get iconSizeMedium => 22.0 * scaleFactor;
  double get iconSizeSmall => 16.0 * scaleFactor;

  // Common Sizes (use these for paddings, margins, etc.)
  double get paddingSmall => 8.0 * scaleFactor;
  double get paddingMedium => 16.0 * scaleFactor;
  double get paddingLarge => 24.0 * scaleFactor;

  double get borderRadius => 8.0 * scaleFactor;

  // Box Shadow Scaling
  double get blurRadius => 5.0 * scaleFactor;
  double get spreadRadius => 2.0 * scaleFactor;

  // Other Sizes
  double scale(double value) => value * scaleFactor;

  static const double baseWidth = 375.0;
}

// Color constants
const Color kPrimaryIconColor = Color(0xFFCACACA);
const Color kTitleColor = Colors.black;
const Color kSubtitleColor = Colors.black87;
const Color kHintTextColor = Color(0xFFCACACA);
const Color kBorderColor = Color(0xFFF1F1F1);
