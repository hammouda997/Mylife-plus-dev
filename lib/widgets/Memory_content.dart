import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme.dart'; // Ensure the theme provider is imported
import '../models/memory.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class MemoryContent extends ConsumerWidget {
  final Memory memory;

  const MemoryContent({
    Key? key,
    required this.memory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final responsiveSize = ResponsiveSize(context);
    final pageController = PageController();

    final random = Random();
    final shouldShowImage = random.nextBool();

    return Container(
      color: themeData.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(responsiveSize.paddingMedium),
            child: MemoryHeader(
              date: DateFormat('yyyy/MM/dd, HH:mm').format(DateTime.parse(memory.createdAt)),
              country: memory.address,
              reactions: 0, // Replace with actual reaction data if available
            ),
          ),
          SizedBox(height: responsiveSize.paddingSmall),

          if (shouldShowImage)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: responsiveSize.scale(250),
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: 2, // Hardcoded images
                    itemBuilder: (context, index) {
                      final hardcodedImages = [
                        "https://cdn.builder.io/api/v1/image/assets/TEMP/7632e90dad2f4f0ca39a4830dbb1b01d72906e4c0ddc67d230681b967b7cc622?placeholderIfAbsent=true&apiKey=c43da3a161eb4f318c4f96480fdf0876",
                        "https://cdn.builder.io/api/v1/image/assets/TEMP/7632e90dad2f4f0ca39a4830dbb1b01d72906e4c0ddc67d230681b967b7cc622?placeholderIfAbsent=true&apiKey=c43da3a161eb4f318c4f96480fdf0876",
                      ];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageView(imageUrl: hardcodedImages[index]),
                          ),
                        ),
                        child: Image.network(
                          hardcodedImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(child: Icon(Icons.error, size: responsiveSize.iconSizeMedium)),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: responsiveSize.paddingSmall),
                  child: SmoothPageIndicator(
                    controller: pageController,
                    count: 2,
                    effect: WormEffect(
                      dotHeight: responsiveSize.scale(8),
                      dotWidth: responsiveSize.scale(8),
                      spacing: responsiveSize.paddingSmall / 2,
                      dotColor: themeData.disabledColor,
                      activeDotColor: themeData.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

          if (memory.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(responsiveSize.paddingMedium),
              child: Text(
                memory.text,
                style: themeData.textTheme.bodyMedium?.copyWith(
                  fontSize: responsiveSize.bodyFontSize,
                  fontFamily: 'Kumbh Sans',
                  color: themeData.colorScheme.onSurface,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          SizedBox(height: responsiveSize.paddingMedium),

          const MemoryReactions(),
        ],
      ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Center(child: Icon(Icons.error, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}

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
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: responsiveSize.iconSizeSmall,
              color: themeData.colorScheme.onSurface,
            ),
            SizedBox(width: responsiveSize.paddingSmall *1.4 ),
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
        SizedBox(width: responsiveSize.paddingSmall *1.4 ),

        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                size: responsiveSize.iconSizeSmall,
                color: themeData.colorScheme.onSurface,
              ),
              SizedBox(width: responsiveSize.paddingSmall*1.4 ),
              Flexible(
                child: Text(
                  country.isNotEmpty ? country : "Unknown location",
                  style: TextStyle(
                    fontFamily: 'Kumbh Sans',
                    fontSize: responsiveSize.bodyFontSize,
                    fontWeight: FontWeight.w500,
                    color: themeData.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Icon(
              Icons.person,
              size: responsiveSize.iconSizeSmall,
              color: themeData.colorScheme.onSurface,
            ),
            SizedBox(width: responsiveSize.paddingSmall *1.4),
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

class MemoryReactions extends ConsumerWidget {
  const MemoryReactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final responsiveSize = ResponsiveSize(context);

    return Row(

      children: [
        SizedBox(width: responsiveSize.paddingSmall),
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
      margin: EdgeInsets.only(right: responsiveSize.paddingSmall / 2 , left:responsiveSize.paddingSmall*2 ),
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
