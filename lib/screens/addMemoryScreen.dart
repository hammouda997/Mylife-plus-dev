import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mapbox_maps_example/theme.dart';
import 'package:mapbox_maps_example/widgets/memory/newMemoryForm.dart';

class MemoryAddScreen extends ConsumerWidget {
  const MemoryAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: themeData.extension<CustomColors>()?.headerColor,
      appBar: AppBar(
        backgroundColor: themeData.primaryColor,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 50,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            size: 32,
            color: Colors.red,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/book.png',
              width: 28,
              height: 28,
              fit: BoxFit.fill,
            ),
            SizedBox(width: 8),
            Text(
              'new_memory'.tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeData.cardColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              size: 32,
              color: themeData.colorScheme.onPrimary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Memory saved!'.tr())),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8.0,
                    spreadRadius: 2.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
               child: const MemoryForm(),
            ),
          ),
        ],
      ),
    );
  }
}
