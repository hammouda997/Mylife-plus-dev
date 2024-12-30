import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_example/screens/settingsScreen.dart';
import 'package:mapbox_maps_example/screens/testScreen.dart';
import 'package:mapbox_maps_example/theme.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'memoryFeedScreen.dart';

class Homepage extends ConsumerStatefulWidget {
  const Homepage({super.key});

  @override
  ConsumerState createState() => _HomepageState();
}

double lastOffset = 0.0;
bool showTopBar = true;
bool showBottomBar = true;

class _HomepageState extends ConsumerState<Homepage> with SingleTickerProviderStateMixin {
  ScrollController controller = ScrollController();
  ScrollController mapScrollController = ScrollController();
  ScrollController controllerFeed = ScrollController();

  List tabs = [
    'assets/earth.png',
    'assets/book.png',
    'assets/user.png',
    'assets/cogwheel.png',
  ];

  late TabController _tabController;
  late MapboxMap map;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    controllerFeed.addListener(_scrollListener);

    _tabController.addListener(() {
      setState(() {});
    });
  }

  void _scrollListener() {
    if (controllerFeed.offset > lastOffset && controllerFeed.offset > 100) {
      setState(() {
        showTopBar = false;
        showBottomBar = false;
      });
    } else if (controllerFeed.offset < lastOffset && controllerFeed.offset < controllerFeed.position.maxScrollExtent) {
      setState(() {
        showTopBar = true;
        showBottomBar = true;
      });
    }
    lastOffset = controllerFeed.offset;
  }

  @override
  void dispose() {
    controllerFeed.removeListener(_scrollListener);
    controllerFeed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: showTopBar && _tabController.index != 3
          ? AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 26,
                    color: theme.colorScheme.onSurface,
                  ),
                  SizedBox(width: 12),
                  Text(
                    tr('search'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 26,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.tune,
                    size: 26,
                    color: theme.colorScheme.onSurface,
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    height: 26,
                    width: 26,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).pushNamed("/addMemory");
                      },
                      icon: Icon(
                        Icons.add,
                        size: 26,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
          : null,
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          LayoutBuilder(
            builder: (BuildContext, constraints) => SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  MapWidget(
                    onMapCreated: (mapbox) {
                      map = mapbox;
                      print("Map created: $map");
                    },
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                      ),
                    },
                  ),
                ],
              ),
            ),
          ),
          MemoryFeedScreen(controller: controllerFeed),
          TestScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: showBottomBar
          ? TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.primaryColor,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: [
          ...tabs.asMap().entries.map((entry) {
            String asset = entry.value;

            return Tab(
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Image.asset(
                  asset,
                  width: 32,
                  height: 32,
                ),
              ),
            );
          }).toList(),
        ],
      )
          : null,
    );
  }
}
