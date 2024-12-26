import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';


class DataSettingScreen extends ConsumerWidget {
  const DataSettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sizes = ref.watch(responsiveSizeProvider(context));
    final fontSizes = themeNotifier.fontSizes;

    return Scaffold(
      backgroundColor: themeNotifier.headerColor,
      appBar: AppBar(
        backgroundColor: themeNotifier.primaryColor,
        elevation: 1,
        centerTitle: true,
        toolbarHeight: sizes.scale(70.0),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '📁',
              style: TextStyle(fontSize: sizes.iconSizeLarge),
            ),
            SizedBox(width: sizes.paddingSmall),
            Text(
              tr('data'),
              style: TextStyle(
                fontSize: sizes.titleFontSize,
                fontWeight: FontWeight.bold,
                color: themeData.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: themeData.colorScheme.onPrimary),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: sizes.paddingSmall),
            _buildSection(
              title: tr('memory'),
              fontSizes: fontSizes,
              themeData: themeData,
              sizes: sizes,
              items: [
                _buildDataItem(
                  context,
                  title: tr('uploadGpsPoints'),
                  isDestructive: false,
                  themeData: themeData,
                  sizes: sizes,
                  fontSizes: fontSizes,
                  onTap: () {
                    _showDialog(
                      context,
                      tr('uploadGpsPoints'),
                      tr('uploadGpsPointsDescription'),
                    );
                  },
                ),
                _buildDataItem(
                  context,
                  title: tr('uploadMediaWithGps'),
                  isDestructive: false,
                  themeData: themeData,
                  fontSizes: fontSizes,
                  sizes: sizes,
                  onTap: () {
                    _showDialog(
                      context,
                      tr('uploadMediaWithGps'),
                      tr('uploadMediaWithGpsDescription'),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: sizes.paddingSmall),
            _buildSection(
              title: tr('allData'),
              fontSizes: fontSizes,
              themeData: themeData,
              sizes: sizes,
              items: [
                _buildDataItem(
                  context,
                  title: tr('backupData'),
                  isDestructive: false,
                  themeData: themeData,
                  sizes: sizes,
                  fontSizes: fontSizes,
                  onTap: () async {
                    const String assetPath = 'assets/earth.png';
// this is just mock file  !
                    try {
                      final ByteData bytes = await rootBundle.load(assetPath);
                      final Directory tempDir = await Directory.systemTemp.createTemp();
                      final File tempFile = File('${tempDir.path}/earth.png');
                      await tempFile.writeAsBytes(bytes.buffer.asUint8List());
                      Share.shareXFiles(
                        [XFile(tempFile.path)],
                        text: tr('backupDataShared'),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(tr('fileNotFound')),
                        ),
                      );
                    }
                  },
                ),

                _buildDataItem(
                  context,
                  title: tr('uploadData'),
                  isDestructive: false,
                  themeData: themeData,
                  sizes: sizes,
                  fontSizes: fontSizes,
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      final filePath = result.files.single.path;
                      if (filePath != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${tr('fileUploaded')}: $filePath')),
                        );
                      }
                    }
                    },
                ),
                _buildDataItem(
                  context,
                  title: tr('eraseData'),
                  isDestructive: true,
                  themeData: themeData,
                  fontSizes: fontSizes,
                  sizes: sizes,
                  onTap: () async {
                    _showConfirmationDialog(context, fontSizes);
                  },
                ),
              ],
            ),
            SizedBox(height: sizes.paddingMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required FontSizes fontSizes,
    required ThemeData themeData,
    required ResponsiveSize sizes,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: sizes.paddingMedium,
            vertical: sizes.scale(16.0),
          ),

          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSizes.bodyFontSize,
              fontWeight: FontWeight.bold,
              color: themeData.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey[700],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: themeData.cardColor,
            boxShadow: [
              BoxShadow(
                color: themeData.brightness == Brightness.dark
                    ? Colors.black26
                    : Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildDataItem(
      BuildContext context, {
        required String title,
        required bool isDestructive,
        required ThemeData themeData,
        required FontSizes fontSizes,
        required ResponsiveSize sizes,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sizes.paddingMedium,
          vertical: sizes.scale(16.0),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: themeData.dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: fontSizes.bodyFontSize,
                  color: isDestructive
                      ? themeData.colorScheme.error
                      : themeData.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: sizes.iconSizeSmall,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }



  void _showDialog(BuildContext context, String title, String content) {
    final themeData = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeData.cardColor,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeData.colorScheme.onSurface,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(color: themeData.colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              tr('close'),
              style: TextStyle(color: themeData.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, FontSizes fontSizes) async {
    final themeData = Theme.of(context);
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeData.cardColor,
        title: Text(
          tr('eraseData'),
          style: TextStyle(
            fontSize: fontSizes.titleFontSize,
            color: themeData.colorScheme.error,
          ),
        ),
        content: Text(
          tr('eraseDataConfirmation'),
          style: TextStyle(
            fontSize: fontSizes.bodyFontSize,
            color: themeData.colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              tr('cancel'),
              style: TextStyle(
                fontSize: fontSizes.bodyFontSize,
                color: themeData.colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              tr('eraseData'),
              style: TextStyle(
                fontSize: fontSizes.bodyFontSize,
                color: themeData.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('eraseDataConfirmation'),
            style: TextStyle(fontSize: fontSizes.bodyFontSize),
          ),
        ),
      );
    }
  }

}
