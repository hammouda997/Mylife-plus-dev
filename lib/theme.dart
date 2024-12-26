import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';





  // Dynamic header and item background colors
  late Color _headerColor;
  late Color _itemBackgroundColor;

  Color get headerColor => _headerColor;
  Color get itemBackgroundColor => _itemBackgroundColor;

class ThemeNotifier extends StateNotifier<ThemeData> {
  FontSizes _fontSizes;
  FontSizes get fontSizes => _fontSizes;


  // Primary color
  Color _primaryColor;
  Color _originalPrimaryColor; // Store the original primary color
  Color get primaryColor => _primaryColor;

  // Dynamic header and item background colors
  late Color _headerColor;
  late Color _itemBackgroundColor;

  Color get headerColor => _headerColor;
  Color get itemBackgroundColor => _itemBackgroundColor;

  ThemeNotifier()
      : _fontSizes = FontSizes(),

        _primaryColor = Colors.blue,
        _originalPrimaryColor = Colors.blue, // Initialize the original color
        super(_buildLightTheme()) {
    _updateDynamicColors(); // Initialize dynamic colors
  }

  static ThemeData _buildLightTheme() {
    return ThemeData.light().copyWith(
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
        titleLarge: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.grey),
      cardColor: Colors.white,
      dividerColor: Color(0xFFEEEEEE),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.grey,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.grey, fontSize: 14),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.grey),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: const Color(0xFF444444),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.grey,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  void _updateDynamicColors() {
    _headerColor = Color.lerp(_primaryColor, state.brightness == Brightness.light ? Colors.white : Colors.black, 0.8)!;
    _itemBackgroundColor = Color.lerp(_primaryColor, Colors.grey[200], 0.5)!;

  }
  void toggleTheme() {
    if (state.brightness == Brightness.light) {
      _primaryColor = Color.lerp(_originalPrimaryColor, Colors.black, 0.5)!;
      state = _buildDarkTheme().copyWith(
        primaryColor: _primaryColor,
        iconTheme: IconThemeData(color: Colors.grey),
        textTheme: state.textTheme.copyWith(
          bodyLarge: state.textTheme.bodyLarge
              ?.copyWith(color: Colors.white, fontSize: _fontSizes.bodyFontSize),
          bodyMedium: state.textTheme.bodyMedium
              ?.copyWith(color: Colors.grey, fontSize: _fontSizes.subtitleFontSize),
          titleLarge: state.textTheme.titleLarge
              ?.copyWith(color: Colors.white, fontSize: _fontSizes.titleFontSize),
        ),
      );
    } else {
      _primaryColor = _originalPrimaryColor;
      state = _buildLightTheme().copyWith(
        primaryColor: _primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        textTheme: state.textTheme.copyWith(
          bodyLarge: state.textTheme.bodyLarge
              ?.copyWith(color: Colors.black, fontSize: _fontSizes.bodyFontSize),
          bodyMedium: state.textTheme.bodyMedium
              ?.copyWith(color: Colors.black54, fontSize: _fontSizes.subtitleFontSize),
          titleLarge: state.textTheme.titleLarge
              ?.copyWith(color: Colors.black, fontSize: _fontSizes.titleFontSize),
        ),
      );
    }
    _updateDynamicColors();
  }


  /// Update the primary color
  void updatePrimaryColor(Color color) {
    _primaryColor = color;
    _originalPrimaryColor = color;

    state = state.copyWith(
      primaryColor: _primaryColor,
      appBarTheme: state.appBarTheme.copyWith(backgroundColor: _primaryColor),
      buttonTheme: state.buttonTheme.copyWith(buttonColor: _primaryColor),
      iconTheme: state.iconTheme.copyWith(color: Colors.grey )
    );

    _updateDynamicColors();
  }

  void updateFontSizes(FontSizes fontSizes) {
    _fontSizes = fontSizes;
    state = state.copyWith(
      textTheme: state.textTheme.copyWith(
        bodyLarge: state.textTheme.bodyLarge?.copyWith(
          fontSize: fontSizes.bodyFontSize,
        ),
        bodyMedium: state.textTheme.bodyMedium?.copyWith(
          fontSize: fontSizes.subtitleFontSize,
        ),
        titleLarge: state.textTheme.titleLarge?.copyWith(
          fontSize: fontSizes.titleFontSize,
        ),
      ),
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>(
      (ref) => ThemeNotifier(),
);

class ResponsiveSize {
  final BuildContext context;

  ResponsiveSize(this.context);

  double get scaleFactor => MediaQuery.of(context).size.width / baseWidth;

  // Font Sizes
  double get titleFontSize => 20.0 * scaleFactor;
  double get subtitleFontSize => 16.0 * scaleFactor;
  double get bodyFontSize => 14.0 * scaleFactor;

  // Icon Sizes
  double get iconSizeLarge => 32.0 * scaleFactor;
  double get iconSizeMedium => 24.0 * scaleFactor;
  double get iconSizeSmall => 16.0 * scaleFactor;

  // Common Sizes (use these for paddings, margins, etc.)
  double get paddingSmall => 4.0 * scaleFactor;
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

/// Colors for static styling
const Color kPrimaryIconColor = Color(0xFFCACACA);
const Color kTitleColor = Colors.black;
const Color kSubtitleColor = Colors.black87;
const Color kHintTextColor = Color(0xFFCACACA);
const Color kBorderColor = Color(0xFFF1F1F1);

/// FontSizes class
class FontSizes {
  double titleFontSize;
  double subtitleFontSize;
  double bodyFontSize;

  FontSizes({
    this.titleFontSize = 20.0,
    this.subtitleFontSize = 16.0,
    this.bodyFontSize = 18.0,
  });

  FontSizes copyWith({
    double? titleFontSize,
    double? subtitleFontSize,
    double? bodyFontSize,
  }) {
    return FontSizes(
      titleFontSize: titleFontSize ?? this.titleFontSize,
      subtitleFontSize: subtitleFontSize ?? this.subtitleFontSize,
      bodyFontSize: bodyFontSize ?? this.bodyFontSize,
    );
  }
}

// ResponsiveSize provider
final responsiveSizeProvider =
Provider.family<ResponsiveSize, BuildContext>((ref, context) {
  return ResponsiveSize(context);
});
