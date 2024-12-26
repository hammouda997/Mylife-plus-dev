import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

final selectedLanguageProvider =
StateNotifierProvider<SelectedLanguageNotifier, String>((ref) {
  return SelectedLanguageNotifier();
});

class SelectedLanguageNotifier extends StateNotifier<String> {
  static const _languageCodeKey = 'language_code';

  SelectedLanguageNotifier() : super('en') {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageCodeKey) ?? 'en';
    state = savedLanguage;
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
    final themeNotifier = ref.read(themeProvider.notifier);
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final sizes = ref.watch(responsiveSizeProvider(context));

    return Scaffold(
      backgroundColor: themeNotifier.headerColor,
      appBar: AppBar(
        backgroundColor: themeNotifier.primaryColor,
        elevation: 1,
        centerTitle: true,
        toolbarHeight: sizes.scale(70.0),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.phone_iphone,
              color: Colors.black,
              size: sizes.iconSizeLarge,
            ),
            SizedBox(width: sizes.paddingSmall),
            Text(
              'UI',
              style: TextStyle(
                fontSize: sizes.titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: themeData.colorScheme.onPrimary),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildSection(
              title: tr('preferences'),
              themeData: themeData,

              fontSizes: themeNotifier.fontSizes,
              items: [
                _SettingsTile(
                  title: tr(
                      'language', namedArgs: {'language': selectedLanguage}),
                  onTap: () => _showLanguageSelection(context, ref,themeNotifier.fontSizes),
                  trailing: Icon(
                      Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  themeData: themeData,
                  fontSizes: themeNotifier.fontSizes,

                ),
                _SettingsTile(
                  title: themeData.brightness == Brightness.dark ? tr(
                      'darkMode') : tr('lightMode'),
                  trailing: Switch(
                    value: themeData.brightness == Brightness.dark,
                    onChanged: (_) => themeNotifier.toggleTheme(),
                  ),
                  themeData: themeData,
                  fontSizes: themeNotifier.fontSizes,
                ),
              ],
            ),
            _buildSection(
              title: tr('appearance'),
              fontSizes: themeNotifier.fontSizes,
              themeData: themeData,

              items: [
                _SettingsTile(
                  title: tr('changePrimaryColor'),
                  trailing: Container(
                    width: sizes.iconSizeSmall,
                    height: sizes.iconSizeSmall,
                    decoration: BoxDecoration(
                      color: themeNotifier.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  onTap: () =>
                      _showColorPicker(context, ref, themeNotifier,
                          tr('changePrimaryColor')),
                  themeData: themeData,
                  fontSizes: themeNotifier.fontSizes,
                ),
                _SettingsTile(
                  title: tr('adjustFontSizes'),
                  onTap: () =>
                      _showFontSizeAdjuster(context, ref, themeNotifier, sizes),
                  trailing: Icon(
                      Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  themeData: themeData,
                  fontSizes: themeNotifier.fontSizes,
                ),
              ],
            ),
            SizedBox(height: sizes.paddingMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required FontSizes fontSizes,
    required List<Widget> items,
    required ThemeData themeData,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 16,
          ),

          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSizes.bodyFontSize,
              fontWeight: FontWeight.bold,
              color: themeData.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey[700],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: themeData.cardColor,
            boxShadow: [
              BoxShadow(
                color: themeData.brightness == Brightness.dark
                    ? Colors.black26
                    : Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  void _showLanguageSelection(
      BuildContext context, WidgetRef ref, FontSizes fontSizes) {
    final themeData = Theme.of(context);
    final languages = {
      'en': 'English',
      'fr': 'Français',
      'de': 'Deutsch',
    };
    String selectedLanguageKey = ref.read(selectedLanguageProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: themeData.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Container(
          height: 300,
          color: themeData.cardColor,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: themeData.dividerColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        tr('cancel'),
                        style: TextStyle(
                          color: themeData.colorScheme.onSurface,
                          fontSize: fontSizes.bodyFontSize,
                        ),
                      ),
                    ),
                    Text(
                      tr('selectLanguage'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizes.subtitleFontSize,
                        color: themeData.colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await ref
                            .read(selectedLanguageProvider.notifier)
                            .setLanguage(selectedLanguageKey);
                        context.setLocale(Locale(selectedLanguageKey));
                        Navigator.pop(context);
                      },
                      child: Text(
                        tr('done'),
                        style: TextStyle(
                          color: themeData.colorScheme.onSurface,
                          fontSize: fontSizes.bodyFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: fontSizes.bodyFontSize + 22,
                  onSelectedItemChanged: (index) {
                    selectedLanguageKey = languages.keys.elementAt(index);
                  },
                  scrollController: FixedExtentScrollController(
                    initialItem:
                    languages.keys.toList().indexOf(selectedLanguageKey),
                  ),
                  children: languages.entries
                      .map(
                        (entry) => Center(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: fontSizes.bodyFontSize,
                          color: themeData.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  void _showFontSizeAdjuster(
      BuildContext context, WidgetRef ref, ThemeNotifier themeNotifier, ResponsiveSize sizes) {
    final options = {
      'small': FontSizes(
        titleFontSize: 14,
        subtitleFontSize: 14,
        bodyFontSize: 14,
      ),
      'medium': FontSizes(
        titleFontSize: 18,
        subtitleFontSize: 16,
        bodyFontSize: 18,
      ),
      'big': FontSizes(
        titleFontSize: 24,
        subtitleFontSize: 20,
        bodyFontSize: 24,
      ),
    };
    String selectedSize = options.entries.firstWhere(
          (entry) =>
      entry.value.titleFontSize == themeNotifier.fontSizes.titleFontSize &&
          entry.value.bodyFontSize == themeNotifier.fontSizes.bodyFontSize,
      orElse: () => MapEntry('medium', options['medium']!),
    ).key;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            tr('adjustFontSizes'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: sizes.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.entries.map((entry) {
              final sizeKey = entry.key;
              final fontSize = entry.value;
              return RadioListTile<String>(
                value: sizeKey,
                groupValue: selectedSize,
                title: Text(
                  tr(sizeKey),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: sizes.bodyFontSize,
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    themeNotifier.updateFontSizes(options[value]!);
                    selectedSize = value;
                    Navigator.pop(context);
                  }
                },
                activeColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                tr('close'),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }


  void _showColorPicker(BuildContext context,
      WidgetRef ref,
      ThemeNotifier themeNotifier,
      String colorType,) {
    final themeData = Theme.of(context);
    Color selectedColor = themeNotifier.primaryColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: themeData.cardColor,
          title: Text(
            tr('pickColor', namedArgs: {'colorType': colorType}),
            style: TextStyle(color: themeData.colorScheme.onSurface),
          ),
          content: SingleChildScrollView(
            child: MaterialColorPicker(
              selectedColor: selectedColor,
              onColorChange: (color) {
                selectedColor = color;
              },
              colors: const [
                Colors.red,
                Colors.pink,
                Colors.purple,
                Colors.deepPurple,
                Colors.indigo,
                Colors.blue,
                Colors.lightBlue,
                Colors.cyan,
                Colors.teal,
                Colors.green,
                Colors.lightGreen,
                Colors.lime,
                Colors.yellow,
                Colors.amber,
                Colors.orange,
                Colors.deepOrange,
                Colors.brown,
                Colors.grey,
                Colors.blueGrey,
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                tr('cancel'),
                style: TextStyle(color: themeData.colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                themeNotifier.updatePrimaryColor(selectedColor);
                Navigator.pop(context);
              },
              child: Text(
                tr('select'),
                style: TextStyle(color: themeData.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

}
  class _SettingsTile extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final ThemeData themeData;
  final FontSizes fontSizes;

  const _SettingsTile({
    required this.title,
    this.trailing,
    this.onTap,
    required this.themeData,
    required this.fontSizes,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = themeData.cardColor;
    final textColor = themeData.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Column(
      children: [
        ListTile(
          tileColor: tileColor,
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textColor,
              fontSize: fontSizes.bodyFontSize,
            ),
          ),
          trailing: trailing ?? Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          onTap: onTap,
        ),
        Divider(
          color: themeData.dividerColor,
          thickness: 1,
          height: 0,
        ),
      ],
    );
  }
}