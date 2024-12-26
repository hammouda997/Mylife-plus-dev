import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mapbox_maps_example/screens/Data_Setting_Screen.dart';
import 'package:mapbox_maps_example/screens/Ui_settings.dart';
import 'package:mapbox_maps_example/theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final sizes = ref.watch(responsiveSizeProvider(context));
    final themeData = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final fontSizes = themeNotifier.fontSizes;

    return Scaffold(
      backgroundColor: themeNotifier.headerColor,
      appBar: AppBar(
        backgroundColor: themeData.primaryColor,
        elevation: 0,
        toolbarHeight: sizes.scale(10.0),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: sizes.scale(5.0),
              ),
              color: themeNotifier.primaryColor,
              child: SettingsHeader(
                sizes: sizes,
                fontSizes: fontSizes,
                themeData: themeData,
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  SettingsItem(
                    sizes: sizes,
                    fontSizes: fontSizes,
                    icon: '🔐',
                    title: tr('security'),
                    onTap: () {},
                    themeData: themeData,
                    itemBackgroundColor: themeData.cardColor,
                    headerColor: themeNotifier.headerColor,
                  ),
                  SettingsItem(
                    sizes: sizes,
                    fontSizes: fontSizes,
                    icon: '📱',
                    title: tr('ui'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UiSettingsScreen(),
                        ),
                      );
                    },
                    themeData: themeData,
                    itemBackgroundColor: themeData.cardColor,
                    headerColor: themeNotifier.headerColor,
                  ),
                  SettingsItem(
                    sizes: sizes,
                    fontSizes: fontSizes,
                    icon: '📁',
                    title: tr('data'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DataSettingScreen(),
                        ),
                      );
                    },
                    themeData: themeData,
                    itemBackgroundColor: themeData.cardColor,
                    headerColor: themeNotifier.headerColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsHeader extends StatelessWidget {
  final ResponsiveSize sizes;
  final FontSizes fontSizes;
  final ThemeData themeData;

  const SettingsHeader({
    Key? key,
    required this.sizes,
    required this.fontSizes,
    required this.themeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.paddingSmall,
        vertical: sizes.paddingSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '⚙️',
            style: TextStyle(
              fontSize: sizes.iconSizeLarge,
              fontFamily: 'Inter',
              color: themeData.iconTheme.color,
            ),
          ),
          SizedBox(width: sizes.paddingSmall),
          Text(
            tr('settings'),
            style: TextStyle(
              fontSize: fontSizes.titleFontSize,
              fontWeight: FontWeight.w600,
              fontFamily: 'Kumbh Sans',
              color: themeData.textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final ResponsiveSize sizes;
  final FontSizes fontSizes;
  final String icon;
  final String title;
  final VoidCallback onTap;
  final ThemeData themeData;
  final Color itemBackgroundColor;
  final Color headerColor;

  const SettingsItem({
    Key? key,
    required this.sizes,
    required this.fontSizes,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.themeData,
    required this.itemBackgroundColor,
    required this.headerColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: sizes.paddingMedium,
              vertical: sizes.paddingSmall,
            ),
            color: itemBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      icon,
                      style: TextStyle(
                        fontSize: sizes.iconSizeLarge,
                        fontFamily: 'Inter',
                        color: themeData.iconTheme.color,
                      ),
                    ),
                    SizedBox(width: sizes.paddingSmall),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: fontSizes.bodyFontSize,
                        fontWeight: FontWeight.w500,
                        color: themeData.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right,
                  size: sizes.iconSizeMedium,
                  color: themeData.iconTheme.color,
                ),
              ],
            ),
          ),
        ),
        Divider(
          color: headerColor,
          thickness: 1,
          height: 0,
        ),
      ],
    );
  }
}
