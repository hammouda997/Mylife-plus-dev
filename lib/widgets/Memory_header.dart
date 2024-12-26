import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart'; // Ensure the theme provider is imported

class MemoryHeader extends ConsumerWidget {
  final String date;
  final String country;
  final int reactions;

  const MemoryHeader({
    Key? key,
    required this.date,
    required this.country,
    required this.reactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final responsiveSize = ResponsiveSize(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Date Section
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: responsiveSize.iconSizeSmall,
              color: themeData.colorScheme.onSurface,
            ),
            SizedBox(width: responsiveSize.paddingSmall / 2),
            Text(
              date,
              style: TextStyle(
                fontFamily: 'Kumbh Sans',
                fontSize: responsiveSize.bodyFontSize,
                fontWeight: FontWeight.w500,
                color: themeData.colorScheme.onSurface,
              ),
            ),
          ],
        ),

        // Country Section
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: responsiveSize.iconSizeSmall,
              color: themeData.colorScheme.onSurface,
            ),
            SizedBox(width: responsiveSize.paddingSmall / 2),
            Text(
              country,
              style: TextStyle(
                fontFamily: 'Kumbh Sans',
                fontSize: responsiveSize.bodyFontSize,
                fontWeight: FontWeight.w500,
                color: themeData.colorScheme.onSurface,
              ),
            ),
          ],
        ),

        // Reactions Section
        Row(
          children: [
            Icon(
              Icons.person,
              size: responsiveSize.iconSizeSmall,
              color: themeData.colorScheme.onSurface,
            ),
            SizedBox(width: responsiveSize.paddingSmall / 2),
            Text(
              reactions.toString(),
              style: TextStyle(
                fontFamily: 'Kumbh Sans',
                fontSize: responsiveSize.bodyFontSize,
                fontWeight: FontWeight.w500,
                color: themeData.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
