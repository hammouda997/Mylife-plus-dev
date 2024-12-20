import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_example/responsive_constants.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final sizes = ResponsiveSize(context); // Initialize ResponsiveSize here

    return Scaffold(
      backgroundColor: const Color(0xFFFFF2C5),
      appBar: null, // Hide the AppBar
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SettingsHeader(sizes: sizes), // Pass sizes to the header
            Column(
              children: [
                SettingsItem(
                  sizes: sizes, // Pass sizes to SettingsItem
                  icon: '🔐',
                  title: 'Security',
                  onTap: () {},
                ),
                const Divider(
                  color: Color(0xFFE8E8E8),
                  thickness: 1,
                  height: 0,
                ),
                SettingsItem(
                  sizes: sizes,
                  icon: '📱',
                  title: 'UI',
                  onTap: () {},
                ),
                const Divider(
                  color: Color(0xFFE8E8E8),
                  thickness: 1,
                  height: 0,
                ),
                SettingsItem(
                  sizes: sizes,
                  icon: '📁',
                  title: 'Data',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsHeader extends StatelessWidget {
  final ResponsiveSize sizes;

  const SettingsHeader({Key? key, required this.sizes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFD665),
      padding: EdgeInsets.all(sizes.paddingMedium), // Use responsive padding
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '⚙️',
                style: TextStyle(
                  fontSize: sizes.iconSizeLarge, // Use responsive font size
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(width: sizes.paddingSmall), // Add responsive spacing
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: sizes.titleFontSize,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Kumbh Sans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final ResponsiveSize sizes;
  final String icon;
  final String title;
  final VoidCallback onTap;

  const SettingsItem({
    Key? key,
    required this.sizes,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sizes.paddingMedium,
          vertical: sizes.paddingSmall,
        ),
        color: Colors.white,
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
                  ),
                ),
                SizedBox(width: sizes.paddingSmall), // Add responsive spacing
                Text(
                  title,
                  style: TextStyle(
                    fontSize: sizes.bodyFontSize,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Kumbh Sans',
                  ),
                ),
              ],
            ),
            Icon(
              Icons.chevron_right,
              size: sizes.iconSizeMedium,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

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
