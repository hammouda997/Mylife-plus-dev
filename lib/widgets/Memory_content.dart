import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme.dart';
import '../models/memory.dart';
import 'dart:math';
import 'package:intl/intl.dart';

final memoryContentProvider = Provider.family<MemoryContentViewModel, Memory>((ref, memory) {
  return MemoryContentViewModel(memory);
});

class MemoryContentViewModel {
  final Memory memory;
  MemoryContentViewModel(this.memory);

  String get formattedDate => DateFormat('yyyy/MM/dd, HH:mm').format(DateTime.parse(memory.createdAt));

  String get address => memory.address.isNotEmpty ? memory.address : "Unknown location";

  String get text => memory.text;

  List<String> get hardcodedImages => [
        "https://cdn.builder.io/api/v1/image/assets/TEMP/7632e90dad2f4f0ca39a4830dbb1b01d72906e4c0ddc67d230681b967b7cc622",
        "https://cdn.builder.io/api/v1/image/assets/TEMP/7632e90dad2f4f0ca39a4830dbb1b01d72906e4c0ddc67d230681b967b7cc622",
      ];

  bool get shouldShowImage => Random().nextBool();
}

class MemoryContent extends ConsumerWidget {
  final Memory memory;

  const MemoryContent({Key? key, required this.memory}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final responsiveSize = ResponsiveSize(context);
    final memoryViewModel = ref.watch(memoryContentProvider(memory));

    return Container(
      color: themeData.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(responsiveSize.scaleFactor * 6),
            child: _buildHeader(themeData, responsiveSize, memoryViewModel),
          ),
          if (memoryViewModel.shouldShowImage)
            _buildImageCarousel(responsiveSize, memoryViewModel.hardcodedImages),
          if (memoryViewModel.text.isNotEmpty)
            _buildText(themeData, responsiveSize, memoryViewModel.text),
          SizedBox(height: responsiveSize.scaleFactor * 16),
          _buildReactions(responsiveSize),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData themeData, ResponsiveSize responsiveSize, MemoryContentViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildIconText(
          icon: Icons.calendar_today,
          text: viewModel.formattedDate,
          themeData: themeData,
          responsiveSize: responsiveSize,
        ),
        Expanded(
          child: _buildIconText(
            icon: Icons.location_on,
            text: viewModel.address,
            themeData: themeData,
            responsiveSize: responsiveSize,
            isFlexible: true,
          ),
        ),
        _buildIconText(
          icon: Icons.person,
          text: "0",
          themeData: themeData,
          responsiveSize: responsiveSize,
        ),
      ],
    );
  }

  Widget _buildIconText({
    required IconData icon,
    required String text,
    required ThemeData themeData,
    required ResponsiveSize responsiveSize,
    bool isFlexible = false,
  }) {
    final textWidget = Text(
      text,
      style: TextStyle(
        fontFamily: 'Kumbh Sans',
        fontSize: responsiveSize.scaleFactor * 14,
        fontWeight: FontWeight.w500,
        color: themeData.colorScheme.onSurface,
      ),
      overflow: isFlexible ? TextOverflow.ellipsis : null,
    );

    return Row(
      children: [
        Icon(
          icon,
          size: responsiveSize.scaleFactor * 20,
          color: themeData.colorScheme.onSurface,
        ),
        SizedBox(width: responsiveSize.scaleFactor * 8),
        isFlexible ? Flexible(child: textWidget) : textWidget,
      ],
    );
  }

  Widget _buildImageCarousel(ResponsiveSize responsiveSize, List<String> images) {
    final pageController = PageController();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: responsiveSize.scaleFactor * 250,
          child: PageView.builder(
            controller: pageController,
            itemCount: images.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImageView(imageUrl: images[index]),
                ),
              ),
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Center(child: Icon(Icons.error, size: responsiveSize.scaleFactor * 24)),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: responsiveSize.scaleFactor * 8),
          child: SmoothPageIndicator(
            controller: pageController,
            count: images.length,
            effect: WormEffect(
              dotHeight: responsiveSize.scaleFactor * 8,
              dotWidth: responsiveSize.scaleFactor * 8,
              spacing: responsiveSize.scaleFactor * 4,
              dotColor: Colors.grey,
              activeDotColor: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildText(ThemeData themeData, ResponsiveSize responsiveSize, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsiveSize.scaleFactor * 8, horizontal: responsiveSize.scaleFactor * 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: responsiveSize.scaleFactor * 14,
          fontFamily: 'Kumbh Sans',
          color: themeData.colorScheme.onSurface,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildReactions(ResponsiveSize responsiveSize) {
    final emojis = ["📝", "🥳", "🏃", "👨‍💻"];
    return Row(
      children: emojis.map((emoji) => Padding(
        padding: EdgeInsets.symmetric(horizontal: responsiveSize.scaleFactor * 8),
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: responsiveSize.scaleFactor * 18,
            fontFamily: 'Inter',
            decoration: TextDecoration.none,
            color: Colors.black,
          ),
        ),
      )).toList(),
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
