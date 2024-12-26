import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_example/widgets/Memory_header.dart';
import 'package:mapbox_maps_example/widgets/Memory_reactions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme.dart';

class MemoryContent extends ConsumerWidget {
  final String date;
  final String country;
  final int reactions;
  final String? content;
  final List<String>? imageUrls;

  const MemoryContent({
    Key? key,
    required this.date,
    required this.country,
    required this.reactions,
    this.content,
    this.imageUrls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final responsiveSize = ResponsiveSize(context);
    final pageController = PageController();

    return Container(
      color: themeData.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(responsiveSize.paddingMedium),
            child: MemoryHeader(
              date: date,
              country: country,
              reactions: reactions,
            ),
          ),
          SizedBox(height: responsiveSize.paddingSmall),

          // Image Carousel with Pagination Dots
          if (imageUrls != null && imageUrls!.isNotEmpty)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: responsiveSize.scale(250),
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: imageUrls!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FullScreenImageView(imageUrl: imageUrls![index]),
                          ),
                        ),
                        child: Image.network(
                          imageUrls![index],
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
                    count: imageUrls!.length,
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

          if (content != null && content!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(responsiveSize.paddingMedium),
              child: Text(
                content!,
                style: themeData.textTheme.bodyMedium?.copyWith(
                  fontSize: responsiveSize.bodyFontSize,
                  fontFamily: 'Kumbh Sans',
                  color: themeData.colorScheme.onSurface,
                ),
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

  const FullScreenImageView({Key? key, required this.imageUrl})
      : super(key: key);

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
