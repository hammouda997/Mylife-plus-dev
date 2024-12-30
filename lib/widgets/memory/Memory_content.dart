import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_example/models/memory.dart';
import 'package:mapbox_maps_example/theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:math';
import 'package:intl/intl.dart';

final memoryContentProvider = Provider.family<MemoryContentViewModel, Memory>((ref, memory) {
  return MemoryContentViewModel(memory);
});

class MemoryContentViewModel {
  final Memory memory;
  final bool shouldShowImage;  

  MemoryContentViewModel(this.memory) : shouldShowImage = Random().nextBool();  

  String get formattedTime => DateFormat('HH:mm').format(DateTime.parse(memory.createdAt));
  String get address => memory.address.isNotEmpty ? memory.address : "Unknown location";
  String get text => memory.text;

  List<String> get hardcodedImages => [
    "https://cdn.builder.io/api/v1/image/assets/TEMP/7632e90dad2f4f0ca39a4830dbb1b01d72906e4c0ddc67d230681b967b7cc622",
    "https://cdn.builder.io/api/v1/image/assets/TEMP/7632e90dad2f4f0ca39a4830dbb1b01d72906e4c0ddc67d230681b967b7cc622",
  ];
}

class MemoryContent extends ConsumerWidget {
  final Memory memory;

  const MemoryContent({Key? key, required this.memory}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final fontSizes = ref.watch(fontSizeProvider);
    final memoryViewModel = ref.watch(memoryContentProvider(memory));

    return Card(
      color: themeData.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0 , top: 8.0 ),
            child: _buildHeader(themeData, fontSizes, memoryViewModel),
          ),
          if (memoryViewModel.shouldShowImage)
            _buildImageCarousel(memoryViewModel.hardcodedImages, fontSizes),
          if (memoryViewModel.text.isNotEmpty)
            _buildText(themeData, fontSizes, memoryViewModel.text),
          const SizedBox(height: 16),
          _buildReactions(fontSizes),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData themeData, FontSizes fontSizes, MemoryContentViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: _buildIconText(
              icon: Icons.access_time,
              text: viewModel.formattedTime,
              themeData: themeData,
              fontSizes: fontSizes,
            ),
          ),
          Flexible(
            flex: 6,
            child: _buildIconText(
              icon: Icons.location_on,
              text: viewModel.address,
              themeData: themeData,
              fontSizes: fontSizes,
              isFlexible: true,
            ),
          ),
          Flexible(
            flex: 2,
            child: _buildIconText(
              icon: Icons.person,
              text: "0",
              themeData: themeData,
              fontSizes: fontSizes,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText({
    required IconData icon,
    required String text,
    required ThemeData themeData,
    required FontSizes fontSizes,
    bool isFlexible = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: fontSizes.bodyFontSize ,
          color: themeData.colorScheme.onSurface,
        ),
        const SizedBox(width: 8.0),

        isFlexible
            ? Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Kumbh Sans',
              fontSize: fontSizes.bodyFontSize,
              fontWeight: FontWeight.w500,
              color: themeData.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        )
            : Text(
          text,
          style: TextStyle(
            fontFamily: 'Kumbh Sans',
            fontSize: fontSizes.bodyFontSize,
            fontWeight: FontWeight.w500,
            color: themeData.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(List<String> images, FontSizes fontSizes) {
    final pageController = PageController();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: fontSizes.bodyFontSize * 18,
          child: PageView.builder(
            controller: pageController,
            itemCount: images.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImageView(
                    images: images,
                    initialIndex: index,
                  ),
                ),
              ),
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Center(child: Icon(Icons.error, size: fontSizes.bodyFontSize + 6)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SmoothPageIndicator(
            controller: pageController,
            count: images.length,
            effect: WormEffect(
              dotHeight: fontSizes.bodyFontSize / 2,
              dotWidth: fontSizes.bodyFontSize / 2,
              spacing: 4,
              dotColor: Colors.grey,
              activeDotColor: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildText(ThemeData themeData, FontSizes fontSizes, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSizes.bodyFontSize,
          fontFamily: 'Kumbh Sans',
          color: themeData.colorScheme.onSurface,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildReactions(FontSizes fontSizes) {
    final emojis = ["📝", "🥳", "🏃", "👨‍💻"];
    return Row(
      children: emojis.map((emoji) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: fontSizes.bodyFontSize + 4,
              fontFamily: 'Inter',
              decoration: TextDecoration.none,
              color: Colors.black,
            ),
          ),
        );
      }).toList(),
    );
  }
}
class FullScreenImageView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageView({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenImageViewState createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_pageController.page != widget.images.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: SizedBox.expand(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.error, color: Colors.white)),
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            top: 40.0,
            right: 20.0,
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
