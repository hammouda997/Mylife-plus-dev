import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_example/widgets/Memory_content.dart';
import '../theme.dart'; // Ensure the theme provider is imported

class MemoryFeedScreen extends ConsumerStatefulWidget {
  const MemoryFeedScreen({Key? key}) : super(key: key);

  @override
  MemoryFeedScreenState createState() => MemoryFeedScreenState();
}

class MemoryFeedScreenState extends ConsumerState<MemoryFeedScreen> {
  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeProvider);
    final sizes = ResponsiveSize(context);

    return Container(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            color: themeData.cardColor,
            margin: EdgeInsets.only(top: sizes.paddingMedium),
            child: Column(
              children: [
                MemoryContent(
                  date: "24/12/2024, 15:30",
                  country: "Country Name",
                  reactions: 3,
                  content:
                  "Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit ametLorem ipsum dolor sit amet Lorem ipsum dolor sit amet",
                ),
                _buildDivider(sizes, themeData),
                MemoryContent(
                  date: "24/12/2024, 15:30",
                  country: "Country Name",
                  reactions: 3,
                  content: "Lorem ipsum dolor sit amet...",
                  imageUrls: [
                    "https://cdn.builder.io/api/v1/image/assets/TEMP/7632e90dad2f4f0ca39a4830dbb1b01d72906e4c0ddc67d230681b967b7cc622?placeholderIfAbsent=true&apiKey=c43da3a161eb4f318c4f96480fdf0876",
                    "https://cdn.builder.io/api/v1/image/assets/TEMP/7632e90dad2f4f0ca39a4830dbb1b01d72906e4c0ddc67d230681b967b7cc622?placeholderIfAbsent=true&apiKey=c43da3a161eb4f318c4f96480fdf0876",
                  ],
                ),
                _buildDivider(sizes, themeData),
                MemoryContent(
                  date: "24/12/2024, 15:30",
                  country: "Country Name",
                  reactions: 3,
                  content:
                  "Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit ametLorem ipsum dolor sit amet Lorem ipsum dolor sit amet",
                  imageUrls: [
                    "https://cdn.builder.io/api/v1/image/assets/TEMP/7632e90dad2f4f0ca39a4830dbb1b01d72906e4c0ddc67d230681b967b7cc622?placeholderIfAbsent=true&apiKey=c43da3a161eb4f318c4f96480fdf0876",
                    "https://cdn.builder.io/api/v1/image/assets/TEMP/7632e90dad2f4f0ca39a4830dbb1b01d72906e4c0ddc67d230681b967b7cc622?placeholderIfAbsent=true&apiKey=c43da3a161eb4f318c4f96480fdf0876",
                  ],
                ),
                _buildDivider(sizes, themeData),
                MemoryContent(
                  date: "24/12/2024, 15:30",
                  country: "Country Name",
                  reactions: 3,
                  content:
                  "I am the test dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit amet Lorem ipsum dolor sit ametLorem ipsum dolor sit amet Lorem ipsum dolor sit amet",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ResponsiveSize sizes, ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: sizes.paddingSmall),
      height: sizes.scale(1.5),
      color: theme.dividerColor,
    );
  }
}
