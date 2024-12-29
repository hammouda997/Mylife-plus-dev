import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeData> {
  FontSizes _fontSizes;
  Color _primaryColor;
  Color _originalPrimaryColor;
  Color _lerpColor;
  bool _isDarkMode;

  FontSizes get fontSizes => _fontSizes;
  Color get primaryColor => _primaryColor;
  Color get lerpColor => _lerpColor;
  bool get isDarkMode => _isDarkMode;
  ThemeNotifier()
      : _fontSizes = FontSizes(),
        _primaryColor = Colors.blue,
        _originalPrimaryColor = Colors.blue,
        _isDarkMode = false ,
        _lerpColor = Colors.blue, 
        super(_buildLightTheme()) {
    _initialize();
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
      dividerColor: const Color(0xFFEEEEEE),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
      ),
      extensions: [
        CustomColors(
          headerColor: Colors.blue.withOpacity(0.8),
          itemBackgroundColor: Colors.grey[200]!,
        ),
      ],
    );
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPrimaryColorValue = prefs.getInt('primaryColor') ?? Colors.blue.value;
    _primaryColor = Color(savedPrimaryColorValue);
    _originalPrimaryColor = _primaryColor;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    state = _isDarkMode ? _buildDarkTheme() : _buildLightTheme();
    final savedLerpColorValue = prefs.getInt('lerpColor') ?? Colors.blue.value;
    _lerpColor = Color(savedLerpColorValue);

    final titleFontSize = prefs.getDouble('titleFontSize') ?? 20.0;
    final subtitleFontSize = prefs.getDouble('subtitleFontSize') ?? 16.0;
    final bodyFontSize = prefs.getDouble('bodyFontSize') ?? 14.0;
    _fontSizes = FontSizes(
      titleFontSize: titleFontSize,
      subtitleFontSize: subtitleFontSize,
      bodyFontSize: bodyFontSize,
    );

    _updateThemeExtensions();
    state = state.copyWith(
      primaryColor: _primaryColor,
      textTheme: state.textTheme.copyWith(
        bodyLarge: state.textTheme.bodyLarge?.copyWith(fontSize: _fontSizes.bodyFontSize),
        bodyMedium: state.textTheme.bodyMedium?.copyWith(fontSize: _fontSizes.subtitleFontSize),
        titleLarge: state.textTheme.titleLarge?.copyWith(fontSize: _fontSizes.titleFontSize),
      ),
    );
  }

  Future<void> updatePrimaryColor(Color color) async {
    _primaryColor = color;
    _originalPrimaryColor = color;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.value);

    _updateThemeExtensions();
    state = state.copyWith(
      primaryColor: _primaryColor,
      appBarTheme: state.appBarTheme.copyWith(backgroundColor: _primaryColor),
    );
  }

  Future<void> updateFontSizes(FontSizes fontSizes) async {
    _fontSizes = fontSizes;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('titleFontSize', fontSizes.titleFontSize);
    await prefs.setDouble('subtitleFontSize', fontSizes.subtitleFontSize);
    await prefs.setDouble('bodyFontSize', fontSizes.bodyFontSize);

    state = state.copyWith(
      textTheme: state.textTheme.copyWith(
        bodyLarge: state.textTheme.bodyLarge?.copyWith(fontSize: fontSizes.bodyFontSize),
        bodyMedium: state.textTheme.bodyMedium?.copyWith(fontSize: fontSizes.subtitleFontSize),
        titleLarge: state.textTheme.titleLarge?.copyWith(fontSize: fontSizes.titleFontSize),
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
      extensions: [
        CustomColors(
          headerColor: Colors.grey.withOpacity(0.8),
          itemBackgroundColor: Colors.grey[700]!,
        ),
      ],
    );
  }


  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);

    state = _isDarkMode ? _buildDarkTheme() : _buildLightTheme();

    _updateThemeExtensions();
  }

  void _updateThemeExtensions() {
    final customColors = CustomColors(
      headerColor: Color.lerp(
        _primaryColor,
        state.brightness == Brightness.light ? Colors.white : Colors.black,
        0.8,
      )!,
      itemBackgroundColor: Color.lerp(_primaryColor, Colors.grey[200], 0.5)!,
    );

    state = state.copyWith(
      extensions: [customColors],
    );
  }



  Future<void> _saveLerpColor(Color lerpColor) async {
    _lerpColor = lerpColor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lerpColor', lerpColor.value);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>(
      (ref) => ThemeNotifier(),
);

class CustomColors extends ThemeExtension<CustomColors> {
  final Color headerColor;
  final Color itemBackgroundColor;

  CustomColors({required this.headerColor, required this.itemBackgroundColor});

  @override
  CustomColors copyWith({Color? headerColor, Color? itemBackgroundColor}) {
    return CustomColors(
      headerColor: headerColor ?? this.headerColor,
      itemBackgroundColor: itemBackgroundColor ?? this.itemBackgroundColor,
    );
  }

  @override
  CustomColors lerp(CustomColors other, double t) {
    return CustomColors(
      headerColor: Color.lerp(headerColor, other.headerColor, t)!,
      itemBackgroundColor: Color.lerp(itemBackgroundColor, other.itemBackgroundColor, t)!,
    );
  }
}


class FontSizes {
  double titleFontSize;
  double subtitleFontSize;
  double bodyFontSize;

  FontSizes({
    this.titleFontSize = 20.0,
    this.subtitleFontSize = 20,
    this.bodyFontSize = 20.0,
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

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, FontSizes>(
      (ref) => FontSizeNotifier(),
);

class FontSizeNotifier extends StateNotifier<FontSizes> {
  static const String _fontSizeKey = 'font_size';

  FontSizeNotifier() : super(FontSizes()) {
    _loadFontSizes();
  }

  Future<void> _loadFontSizes() async {
    final prefs = await SharedPreferences.getInstance();
    final titleFontSize = prefs.getDouble('titleFontSize') ?? 20.0;
    final subtitleFontSize = prefs.getDouble('subtitleFontSize') ?? 16.0;
    final bodyFontSize = prefs.getDouble('bodyFontSize') ?? 14.0;

    state = FontSizes(
      titleFontSize: titleFontSize,
      subtitleFontSize: subtitleFontSize,
      bodyFontSize: bodyFontSize,
    );
  }

  Future<void> updateFontSize(FontSizes fontSizes) async {
    state = fontSizes;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('titleFontSize', fontSizes.titleFontSize);
    await prefs.setDouble('subtitleFontSize', fontSizes.subtitleFontSize);
    await prefs.setDouble('bodyFontSize', fontSizes.bodyFontSize);
  }
}
