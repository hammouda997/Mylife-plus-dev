import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart'; // Ensure the theme provider is imported

class MemoryReactions extends ConsumerWidget {
  const MemoryReactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final responsiveSize = ResponsiveSize(context);

    return Row(
      children: [
        _buildReactionButton("📝", themeData, responsiveSize),
        _buildReactionButton("🥳", themeData, responsiveSize),
        _buildReactionButton("🏃", themeData, responsiveSize),
        _buildReactionButton("👨‍💻", themeData, responsiveSize),
      ],
    );
  }

  Widget _buildReactionButton(
      String emoji, ThemeData themeData, ResponsiveSize responsiveSize) {
    return Container(
      margin: EdgeInsets.only(right: responsiveSize.paddingSmall / 2),
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize.paddingSmall,
        vertical: responsiveSize.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: themeData.cardColor,
        borderRadius: BorderRadius.circular(responsiveSize.scale(4)),
        boxShadow: [
          BoxShadow(
            color: themeData.shadowColor.withOpacity(0.1),
            blurRadius: responsiveSize.scale(4),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        emoji,
        style: TextStyle(
          fontSize: responsiveSize.bodyFontSize + 5,
          fontFamily: 'Inter',
          decoration: TextDecoration.none,
          color: themeData.colorScheme.onSurface,
        ),
      ),
    );
  }
}
