import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mapbox_maps_example/theme.dart';
import 'package:mapbox_maps_example/widgets/settings/Data_Setting_Screen.dart';
import 'package:mapbox_maps_example/widgets/settings/Ui_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final fontSizes = ref.watch(fontSizeProvider); 

    return Scaffold(
      backgroundColor: themeData.extension<CustomColors>()?.headerColor,
      appBar: _buildAppBar(themeData , fontSizes), 
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: ListView(
                children: _buildSettingsItems(context, themeData, fontSizes),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(ThemeData themeData, FontSizes fontSizes) {
    return AppBar(
      backgroundColor: themeData.primaryColor,
      elevation: 1,
      centerTitle: true,
      toolbarHeight: 50,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '⚙️',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'Inter',
              color: themeData.iconTheme.color,
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            tr('settings'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'Kumbh Sans',
              color: themeData.textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }



  List<Widget> _buildSettingsItems(BuildContext context, ThemeData themeData, FontSizes fontSizes) {
    return [
      _buildSettingsTile(
        icon: '🔐',
        title: tr('security'),
        onTap: () {},
        themeData: themeData,
        fontSizes: fontSizes,
      ),
      _buildSettingsTile(
        icon: '📱',
        title: tr('ui'),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UiSettingsScreen()),
        ),
        themeData: themeData,
        fontSizes: fontSizes,
      ),
      _buildSettingsTile(
        icon: '📁',
        title: tr('data'),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DataSettingScreen()),
        ),
        themeData: themeData,
        fontSizes: fontSizes,
      ),
    ];
  }

  Widget _buildSettingsTile({
    required String icon,
    required String title,
    VoidCallback? onTap,
    required ThemeData themeData,
    required FontSizes fontSizes,
  }) {
    final textColor = themeData.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Column(
      children: [
        ListTile(
          tileColor: themeData.cardColor,
          leading: Text(
            icon,
            style: TextStyle(
              fontSize: fontSizes.titleFontSize,
              fontFamily: 'Inter',
              color: themeData.iconTheme.color,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: fontSizes.bodyFontSize, color: textColor),
          ),
          trailing: Icon(
            Icons.chevron_right,
            size: 24,
          ),
          onTap: onTap,
        ),
        Divider(color: themeData.dividerColor, thickness: 1, height: 0),
      ],
    );
  }
}
