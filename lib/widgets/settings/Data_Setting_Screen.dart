import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mapbox_maps_example/theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class DataSettingScreen extends ConsumerWidget {
  const DataSettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final fontSizes = ref.watch(fontSizeProvider);

    return Scaffold(
      backgroundColor: themeData.extension<CustomColors>()?.headerColor,
      appBar: _buildAppBar(themeData.primaryColor, fontSizes),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildSection(
              title: tr('memory'),
              items: [
                _buildSettingsTile(
                  title: tr('uploadGpsPoints'),
                  trailing: Icon(Icons.arrow_forward_ios, size: fontSizes.bodyFontSize, color: Colors.grey),
                  onTap: () {
                    _showDialog(
                      context,
                      tr('uploadGpsPoints'),
                      tr('uploadGpsPointsDescription'),
                    );
                  },
                  themeData: themeData,
                  fontSizes: fontSizes,
                ),
                _buildSettingsTile(
                  title: tr('uploadMediaWithGps'),
                  trailing: Icon(Icons.arrow_forward_ios, size: fontSizes.bodyFontSize, color: Colors.grey),
                  onTap: () {
                    _showDialog(
                      context,
                      tr('uploadMediaWithGps'),
                      tr('uploadMediaWithGpsDescription'),
                    );
                  },
                  themeData: themeData,
                  fontSizes: fontSizes,
                ),
              ],
              themeData: themeData,
              fontSizes: fontSizes,
            ),
            _buildSection(
              title: tr('allData'),
              items: [
                _buildSettingsTile(
                  title: tr('backupData'),
                  trailing: Icon(Icons.arrow_forward_ios, size: fontSizes.bodyFontSize, color: Colors.grey),
                  onTap: () async {
                    const String assetPath = 'assets/earth.png';
                    try {
                      final ByteData bytes = await rootBundle.load(assetPath);
                      final Directory tempDir = await Directory.systemTemp.createTemp();
                      final File tempFile = File('${tempDir.path}/earth.png');
                      await tempFile.writeAsBytes(bytes.buffer.asUint8List());
                      Share.shareXFiles([
                        XFile(tempFile.path)
                      ], text: tr('backupDataShared'));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr('fileNotFound'))),
                      );
                    }
                  },
                  themeData: themeData,
                  fontSizes: fontSizes,
                ),
                _buildSettingsTile(
                  title: tr('uploadData'),
                  trailing: Icon(Icons.arrow_forward_ios, size: fontSizes.bodyFontSize, color: Colors.grey),
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
                  themeData: themeData,
                  fontSizes: fontSizes,
                ),
                _buildSettingsTile(
                  title: tr('eraseData'),
                  trailing: Icon(Icons.arrow_forward_ios, size: fontSizes.bodyFontSize, color: Colors.grey),
                  onTap: () {
                    _showConfirmationDialog(context, fontSizes);
                  },
                  themeData: themeData,
                  fontSizes: fontSizes,
                ),
              ],
              themeData: themeData,
              fontSizes: fontSizes,
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(Color primaryColor, FontSizes fontSizes) {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 1,
      centerTitle: true,
      toolbarHeight: 50,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '📁',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(width: 8.0),
          Text(
            tr('data'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
    required ThemeData themeData,
    required FontSizes fontSizes,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSizes.bodyFontSize,
              fontWeight: FontWeight.bold,
              color: themeData.brightness == Brightness.dark ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: themeData.cardColor,
            boxShadow: [
              BoxShadow(
                color: themeData.brightness == Brightness.dark ? Colors.black26 : Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    required ThemeData themeData,
    required FontSizes fontSizes,
  }) {
    final textColor = themeData.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Column(
      children: [
        ListTile(
          tileColor: themeData.cardColor,
          title: Text(
            title,
            style: TextStyle(fontSize: fontSizes.bodyFontSize, color: textColor),
          ),
          trailing: trailing,
          onTap: onTap,
        ),
        Divider(color: themeData.dividerColor, thickness: 1, height: 0),
      ],
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              tr('close'),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
            tr('dataErased'),
            style: TextStyle(fontSize: fontSizes.bodyFontSize),
          ),
        ),
      );
    }
  }
}
