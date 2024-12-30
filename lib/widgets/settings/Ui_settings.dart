import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme.dart';

final selectedLanguageProvider = StateNotifierProvider<SelectedLanguageNotifier, String>((ref) {
  return SelectedLanguageNotifier();
});

class SelectedLanguageNotifier extends StateNotifier<String> {
  static const _languageCodeKey = 'language_code';

  SelectedLanguageNotifier() : super('en') {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_languageCodeKey) ?? 'en';
  }

  Future<void> setLanguage(String languageCode) async {
    state = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }
}

class UiSettingsScreen extends ConsumerWidget {
  const UiSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final fontSizes = ref.watch(fontSizeProvider);

    return Scaffold(
      backgroundColor: themeData.extension<CustomColors>()?.headerColor,
      appBar: _buildAppBar(themeData.primaryColor, fontSizes),
      body: SafeArea(
        child: ListView(
          key: ValueKey(fontSizes.bodyFontSize),
          padding: EdgeInsets.zero,
          children: [
            _buildSection(
              title: tr('preferences'),
              items: [
                _buildSettingsTile(
                  title: tr('language', namedArgs: {'language': selectedLanguage}),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: fontSizes.bodyFontSize),
                  onTap: () => _showLanguageSelection(context, ref, fontSizes),
                  themeData: themeData,
                  fontSizes: fontSizes,
                ),
                _buildSettingsTile(
                  title: themeData.brightness == Brightness.dark ? tr('darkMode') : tr('lightMode'),
                  trailing: Switch(
                    value: themeData.brightness == Brightness.dark,
                    onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                  ),
                  themeData: themeData,
                  fontSizes: fontSizes,
                ),
              ],
              themeData: themeData,
              fontSizes: fontSizes,
            ),
            _buildSection(
              title: tr('appearance'),
              items: [
                _buildSettingsTile(
                  title: tr('changePrimaryColor'),
                  trailing: _buildColorPreview(themeData.primaryColor),
                  onTap: () => _showColorPicker(context, ref, themeData.primaryColor),
                  themeData: themeData,
                  fontSizes: fontSizes,
                ),
                _buildSettingsTile(
                  title: tr('adjustFontSizes'),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: fontSizes.bodyFontSize),
                  onTap: () => _showFontSizeAdjuster(context, ref),
                  themeData: themeData,
                  fontSizes: fontSizes,
                ),
              ],
              themeData: themeData,
              fontSizes: fontSizes,
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(Color primaryColor, FontSizes fontSizes) {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 1,
      centerTitle: true,
      toolbarHeight: 50,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '📱',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          SizedBox(width: 8.0),
          Text(
            'UI',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
    required ThemeData themeData,
    required FontSizes fontSizes,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSizes.bodyFontSize,
              fontWeight: FontWeight.bold,
              color: themeData.brightness == Brightness.dark ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: themeData.cardColor,
            boxShadow: [
              BoxShadow(
                color: themeData.brightness == Brightness.dark ? Colors.black26 : Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    required ThemeData themeData,
    required FontSizes fontSizes,
  }) {
    final textColor = themeData.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Column(
      children: [
        ListTile(
          tileColor: themeData.cardColor,
          title: Text(
            title,
            style: TextStyle(fontSize: fontSizes.bodyFontSize, color: textColor),
          ),
          trailing: trailing,
          onTap: onTap,
        ),
        Divider(color: themeData.dividerColor, thickness: 1, height: 0),
      ],
    );
  }

  Widget _buildColorPreview(Color color) {
    return Container(
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
    );
  }

  void _showLanguageSelection(BuildContext context, WidgetRef ref, FontSizes fontSizes) {
    final languages = {
      'en': 'English',
      'fr': 'Français',
      'de': 'Deutsch',
    };
    String selectedLanguage = ref.read(selectedLanguageProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      tr('selectLanguage'),
                      style: TextStyle(
                        fontSize: fontSizes.titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ...languages.entries.map((entry) {
                    final isSelected = entry.key == selectedLanguage;

                    return ListTile(
                      title: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: fontSizes.bodyFontSize,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      )
                          : null,
                      onTap: () {
                        setState(() {
                          selectedLanguage = entry.key;
                        });
                      },
                    );
                  }).toList(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            tr('cancel'),
                            style: TextStyle(
                              fontSize: fontSizes.subtitleFontSize,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await ref.read(selectedLanguageProvider.notifier).setLanguage(selectedLanguage);
                            context.setLocale(Locale(selectedLanguage));
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: Text(
                            tr('confirm'),
                            style: TextStyle(
                              fontSize: fontSizes.subtitleFontSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFontSizeAdjuster(BuildContext context, WidgetRef ref) {
    final fontOptions = {
      'Small': FontSizes(titleFontSize: 14, subtitleFontSize: 12, bodyFontSize: 14),
      'Medium': FontSizes(titleFontSize: 18, subtitleFontSize: 16, bodyFontSize: 18),
      'Large': FontSizes(titleFontSize: 24, subtitleFontSize: 18, bodyFontSize: 24),
    };
    FontSizes currentFontSize = ref.watch(fontSizeProvider);
    String selectedKey = fontOptions.entries.firstWhere(
          (entry) => entry.value.bodyFontSize == currentFontSize.bodyFontSize,
      orElse: () => MapEntry('Medium', fontOptions['Medium']!),
    ).key;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text(
                tr('adjustFontSizes'),
                style: TextStyle(
                  fontSize: currentFontSize.titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              children: [
                ...fontOptions.entries.map((entry) {
                  final isSelected = entry.key == selectedKey;

                  return SimpleDialogOption(
                    onPressed: () {
                      setState(() {
                        selectedKey = entry.key;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: currentFontSize.bodyFontSize,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                      ],
                    ),
                  );
                }).toList(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      final selectedFontSize = fontOptions[selectedKey]!;
                      ref.read(fontSizeProvider.notifier).updateFontSize(selectedFontSize);
                      ref.read(themeProvider.notifier).updateFontSizes(selectedFontSize);

                      Navigator.pop(context); 
                    },
                    child: Text(
                      tr('select'),
                      style: TextStyle(
                        fontSize: currentFontSize.bodyFontSize,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

void _showColorPicker(BuildContext context, WidgetRef ref, Color primaryColor) {
  final themeData = Theme.of(context);
  Color selectedColor = primaryColor;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          tr('pickColor'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeData.brightness == Brightness.light ? Colors.black : Colors.white,
          ),
        ),
        content: MaterialColorPicker(
          selectedColor: selectedColor,
          onColorChange: (color) => selectedColor = color,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              tr('cancel'),
              style: TextStyle(color: themeData.colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(themeProvider.notifier).updatePrimaryColor(selectedColor);
              Navigator.pop(context);
            },
            child: Text(
              tr('select'),
              style: TextStyle(color: themeData.primaryColor),
            ),
          ),
        ],
      );
    },
  );
}

extension ColorExtensions on Color {
  String toHex() => '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}