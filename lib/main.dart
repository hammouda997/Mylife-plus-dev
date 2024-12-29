import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_example/theme.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_maps_example/screens/LoginPage.dart';
import 'package:mapbox_maps_example/screens/addMemoryScreen.dart';
import 'package:mapbox_maps_example/screens/homePage.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  const String ACCESS_TOKEN = "pk.eyJ1Ijoib3V0YnVyc3Q5OSIsImEiOiJjbHNrcWlhbnIwNWpwMndyMGYxa20wZnVrIn0.CYAY7qy015Ko5_v2n7MKJQ";

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  MapboxOptions.setAccessToken(ACCESS_TOKEN);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('de')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: MyLifeApp()),
    ),
  );
}

class MyLifeApp extends ConsumerWidget {
  const MyLifeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => Homepage(),
        '/login': (BuildContext context) => LoginPage(),
        '/addMemory': (BuildContext context) => MemoryAddScreen(),
      },
      theme: themeData,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
    );
  }
}
