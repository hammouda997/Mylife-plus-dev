import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_example/repository/memoryRepo.dart';
import 'package:mapbox_maps_example/widgets/Memory_content.dart';
import '../theme.dart'; // Ensure the theme provider is imported
import '../models/memory.dart';

class MemoryFeedScreen extends ConsumerStatefulWidget {
  const MemoryFeedScreen({Key? key}) : super(key: key);

  @override
  MemoryFeedScreenState createState() => MemoryFeedScreenState();
}

class MemoryFeedScreenState extends ConsumerState<MemoryFeedScreen> {
  late Future<List<Memory>> _memoryFuture;

  @override
  void initState() {
    super.initState();
    _memoryFuture = MemoryRepository.instance.fetchAllMemories();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeProvider);
    final sizes = ResponsiveSize(context);

    return Scaffold(

      body: FutureBuilder<List<Memory>>(
        future: _memoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No memories found."));
          }

          final memories = snapshot.data!;

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              return Column(
                children: [
                  MemoryContent(
                    memory: Memory(
                      id: memory.id,
                      createdAt: memory.createdAt,
                      updatedAt: memory.updatedAt,
                      xCoordinate: memory.xCoordinate,
                      yCoordinate: memory.yCoordinate,
                      address: memory.address,
                      text: memory.text,
                    ),
                  ),
                  _buildDivider(sizes, themeData),
                ],
              );
            },
          );
        },
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
