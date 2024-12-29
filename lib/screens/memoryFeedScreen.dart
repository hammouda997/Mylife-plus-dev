import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../repository/memoryRepo.dart';
import '../theme.dart';
import '../models/memory.dart';
import '../widgets/memory/Memory_content.dart';
import '../widgets/settings/Ui_settings.dart';

final memoryProvider = FutureProvider<List<Memory>>((ref) {
  return MemoryRepository.instance.fetchAllMemories();
});

class MemoryFeedScreen extends ConsumerWidget {
  final ScrollController controller;

  const MemoryFeedScreen({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final fontSizes = ref.watch(fontSizeProvider);

    return Scaffold(
      backgroundColor: themeData.scaffoldBackgroundColor,
      body: SafeArea(
        child: ref.watch(memoryProvider).when(
          data: (memories) => MemoryList(memories: memories, controller: controller),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorView(error: error),
        ),
      ),
    );
  }
}

class MemoryList extends ConsumerWidget {
  final List<Memory> memories;
  final ScrollController controller;

  const MemoryList({Key? key, required this.memories, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedMemories = _groupMemoriesByDate(memories);

    return ListView.builder(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      itemCount: groupedMemories.keys.length,
      itemBuilder: (context, index) {
        final date = groupedMemories.keys.elementAt(index);
        final memoriesForDate = groupedMemories[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) Separator(),
            DateHeader(date: date),
            Separator(),
            ...memoriesForDate.map((memory) => MemoryContent(memory: memory)),
          ],
        );
      },
    );
  }

  Map<String, List<Memory>> _groupMemoriesByDate(List<Memory> memories) {
    return memories.fold<Map<String, List<Memory>>>({}, (map, memory) {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.parse(memory.createdAt));
      map.putIfAbsent(date, () => []).add(memory);
      return map;
    });
  }
}

class DateHeader extends ConsumerWidget {
  final String date;

  const DateHeader({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final fontSizes = ref.watch(fontSizeProvider);
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final fullText = DateFormat('EEEE, dd/MM/yyyy', selectedLanguage)
        .format(DateTime.parse(date));

    final GlobalKey _textKey = GlobalKey();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/calendar.svg',
                width: fontSizes.bodyFontSize * 1.2,
                height: fontSizes.bodyFontSize * 1.2,
                color: themeData.colorScheme.onBackground,
              ),
              const SizedBox(width: 8.0),
              Flexible(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // Text widget to check for overflow
                    final text = Text(
                      fullText,
                      key: _textKey,
                      style: TextStyle(
                        fontSize: fontSizes.bodyFontSize,
                        fontWeight: FontWeight.w500,
                        color: themeData.colorScheme.onBackground,
                      ),
                      overflow: TextOverflow.ellipsis, 
                    );

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
                      final isOverflowing =
                          renderBox != null && renderBox.size.width > constraints.maxWidth;

                      if (isOverflowing) {
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Text(
                                    fullText,
                                    style: TextStyle(
                                      fontSize: fontSizes.bodyFontSize,
                                      fontWeight: FontWeight.w500,
                                      color: themeData.colorScheme.onBackground,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text(
                                        'Close',
                                        style: TextStyle(color: themeData.primaryColor),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      }
                    });

                    return text;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Separator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Divider(
        thickness: 1.5,
        color: themeData.dividerColor.withOpacity(0.6),
        height: 8.0,
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final Object error;

  const ErrorView({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Error: $error",
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
            },
            child: Text("Retry".tr()),
          ),
        ],
      ),
    );
  }
}
