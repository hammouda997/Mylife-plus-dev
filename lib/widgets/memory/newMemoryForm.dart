import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:mapbox_maps_example/repository/dbUtils.dart';
import 'package:mapbox_maps_example/theme.dart';
import 'package:mapbox_maps_example/widgets/settings/Ui_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';




class MemoryForm extends ConsumerStatefulWidget {
  const MemoryForm({super.key});

  @override
  ConsumerState createState() => MemoryFormState();
}

class MemoryFormState extends ConsumerState<MemoryForm> {
  @override
  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    await checkAndRequestPermissions();
    try {
      await _player.openPlayer();
    } catch (e) {
      debugPrint("Error opening player: $e");
    }
    await _initializeRecorder();

    if (_isRecorderInitialized) {
      debugPrint("Recorder is initialized.");
    } else {
      debugPrint("Recorder initialization failed.");
    }
  }

  late AppDatabase appDatabase;


  DateTime _selectedDate = DateTime.now();
  final List<File> _selectedImages = [];

  final List<String> selectedHashtags = [];
  final List<String> selectedContacts = [];
  final List<bool> _isEditing = [];

  bool _isRecording = false;
  final List<Map<String, dynamic>> _audioMessages = [];

  void addHashtag(String hashtag) {
    if (!selectedHashtags.contains(hashtag)) {
      setState(() {
        selectedHashtags.add(hashtag);
      });
    }
  }

  void removeHashtag(String hashtag) {
    setState(() {
      selectedHashtags.remove(hashtag);
    });
  }

  void addContact(String contact) {
    if (!selectedContacts.contains(contact)) {
      setState(() {
        selectedContacts.add(contact);
      });
    }
  }

  void removeContact(String contact) {
    setState(() {
      selectedContacts.remove(contact);
    });
  }

  String formatContact(String contact) {
    List<String> parts = contact.split(' ');
    if (parts.isNotEmpty) {
      return parts.length > 1
          ? '${parts.first} ${parts.last[0]}.'
          : parts.first;
    }
    return contact;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString()
        .padLeft(2, '0')}';
  }

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedImages.add(File(file.path));
      });
    }
  }

  void _removeImage(File file) {
    setState(() {
      _selectedImages.remove(file);
    });
  }


  bool _isRecorderInitialized = false;
  final ValueNotifier<int> _currentDuration = ValueNotifier<int>(0);
  Timer? _recordingTimer;
  Future<void> checkAndRequestPermissions() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      if (result.isGranted) {
        debugPrint("Microphone permission granted");
      } else {
        debugPrint("Microphone permission denied");
        openAppSettings();
      }
    } else if (status.isGranted) {
      debugPrint("Microphone permission already granted");
    } else {
      debugPrint("Microphone permission permanently denied");
      openAppSettings();
    }
  }

  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey<
      AnimatedListState>();
  final GlobalKey _addTextFieldKey = GlobalKey();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  Future<void> _initializeRecorder() async {
    try {
      final status = await Permission.microphone.status;

      if (status.isGranted) {
        await _recorder.openRecorder();
        debugPrint("Recorder initialized successfully");
        setState(() {
          _isRecorderInitialized = true;
        });
      } else {
        debugPrint("Microphone permission not granted");
      }
    } catch (e) {
      debugPrint("Error initializing recorder: $e");
    }
  }

  final ScrollController _scrollController = ScrollController();


  @override
  void dispose() {
    _currentDuration.dispose();
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _scrollController.dispose();


    if (_player.isPlaying) _player.stopPlayer();
    if (_recorder.isRecording) _recorder.stopRecorder();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }


  Future<void> _startRealRecording() async {
    if (!_isRecorderInitialized) {
      debugPrint("Recorder is not initialized.");
      return;
    }

    if (!_isRecording) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/Recording_${DateTime.now().millisecondsSinceEpoch}.aac';

        await _recorder.startRecorder(toFile: filePath);

        setState(() {
          _isRecording = true;
          _currentDuration.value = 0;
        });

        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _currentDuration.value++;
        });

        debugPrint("Recording started: $filePath");
      } catch (e) {
        debugPrint("Error starting recorder: $e");
      }
    } else {
      debugPrint("Already recording.");
    }
  }

  Future<void> _stopRealRecording() async {
    if (_isRecording) {
      try {
        final path = await _recorder.stopRecorder();
        _recordingTimer?.cancel();

        if (path != null) {
          setState(() {
            _audioMessages.add({
              'path': path,
              'duration': _currentDuration.value,
              'name': 'Recording ${_audioMessages.length + 1}',
              'isEditing': false,
              'isPlaying': false,
              'currentPosition': 0,
            });
            _isRecording = false;
          });

          _animatedListKey.currentState?.insertItem(_audioMessages.length - 1);

          // Delay the scroll action to make sure the item has been added
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Future.delayed(Duration(milliseconds: 300), () {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            });
          });
        }
      } catch (e) {
        debugPrint("Error stopping recorder: $e");
      }
    }
  }

  Timer? _playbackTimer;

  Future<void> _playAudio(int index) async {
    try {
      for (var i = 0; i < _audioMessages.length; i++) {
        if (_audioMessages[i]['isPlaying'] && i != index) {
          await _player.stopPlayer();
          _playbackTimer?.cancel();
          setState(() {
            _audioMessages[i]['isPlaying'] = false;
            _audioMessages[i]['currentPosition'] = 0;
          });
        }
      }

      if (_audioMessages[index]['isPlaying']) {
        await _player.stopPlayer();
        _playbackTimer?.cancel();
        setState(() {
          _audioMessages[index]['isPlaying'] = false;
          _audioMessages[index]['currentPosition'] = 0;
        });
      } else {
        await _player.startPlayer(
          fromURI: _audioMessages[index]['path'],
          codec: Codec.aacADTS,
          whenFinished: () {
            print(
                "Playback Finished for Recording ${_audioMessages[index]['name']}");

            _playbackTimer?.cancel();
            setState(() {
              _audioMessages[index]['isPlaying'] = false;
              _audioMessages[index]['currentPosition'] = 0;
            });
          },
        );

        print("Started Playing Recording ${_audioMessages[index]['name']}");

        setState(() {
          _audioMessages[index]['isPlaying'] = true;
        });

        _playbackTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          final currentPosition = _audioMessages[index]['currentPosition'];
          if (currentPosition < _audioMessages[index]['duration']) {
            setState(() {
              _audioMessages[index]['currentPosition']++;
            });
            print(
                "Timer Update - Current Position: ${_audioMessages[index]['currentPosition']} seconds");
          } else {
            timer.cancel();
          }
        });
      }
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  @override
Widget build(BuildContext context) {
  final themeData = ref.watch(themeProvider);
  final selectedLanguage = ref.watch(selectedLanguageProvider);
  final fontSizes = ref.watch(fontSizeProvider);

  return Scaffold(
      backgroundColor: themeData.extension<CustomColors>()?.headerColor,
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateTimeField(themeData, fontSizes),
                _buildDivider(themeData),

                _buildLocationField(themeData, fontSizes),
                _buildDivider(themeData),

                _buildContactField(themeData, fontSizes),
                _buildDivider(themeData),

                _buildTagField(themeData, fontSizes),
                _buildDivider(themeData),

                _buildLibraryField(themeData, fontSizes),
                _buildDivider(themeData),

                _buildTextField(themeData, fontSizes),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTextField(ThemeData theme, FontSizes fontSizes) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    color: theme.cardColor,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/message-text.svg',
              width: 24.0,
              height: 24.0,
              color: theme.iconTheme.color,
            ),
            const SizedBox(width: 8.0),
            Text(
              tr('text_and_audio'),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: fontSizes.bodyFontSize,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        if (_audioMessages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: AnimatedList(
              key: _animatedListKey,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              initialItemCount: _audioMessages.length,
              itemBuilder: (context, index, animation) {
                final audio = _audioMessages[index];
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: 1.0,
                  child: _buildAudioListItem(audio, theme, fontSizes),
                );
              },
            ),
          ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.shadowColor,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    maxLines: null,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: tr('add_text'),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.hintColor,
                        fontSize: fontSizes.bodyFontSize,
                      ),
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: fontSizes.bodyFontSize,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              GestureDetector(
                key: _addTextFieldKey,
                onTapDown: (_) async {
                  _currentDuration.value = 0;
                  await _startRealRecording();
                },
                onTapUp: (_) async => await _stopRealRecording(),
                child: Column(
                  children: [
                    Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          if (_isRecording)
                            BoxShadow(
                              color: Colors.red.withOpacity(0.6),
                              blurRadius: 10.0,
                              spreadRadius: 5.0,
                            ),
                        ],
                        border: Border.all(
                          color: theme.dividerColor,
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/microphone-2.svg',
                          width: 20.0,
                          height: 20.0,
                          color: _isRecording ? Colors.red : theme.iconTheme.color,
                        ),
                      ),
                    ),
                    if (_isRecording)
                      ValueListenableBuilder<int>(
                        valueListenable: _currentDuration,
                        builder: (context, duration, _) {
                          return Text(
                            _formatDuration(duration),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: fontSizes.bodyFontSize,
                              color: Colors.red,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildAudioListItem(Map<String, dynamic> audio, ThemeData theme, FontSizes fontSizes) {
  final TextEditingController editController = TextEditingController(text: audio['name']);
  final bool isEditing = audio['isEditing'];
  final bool isPlaying = audio['isPlaying'];

  return Dismissible(
    key: Key(audio['path']),
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      color: theme.colorScheme.error,
      child: const Padding(
        padding: EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 24.0,
        ),
      ),
    ),
    onDismissed: (direction) {
      final removedAudio = audio;
      final removedIndex = _audioMessages.indexOf(audio);

      _audioMessages.removeAt(removedIndex);

      _animatedListKey.currentState?.removeItem(
        removedIndex,
        (context, animation) => Container(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${removedAudio['name']} ${tr('deleted')}'),
          action: SnackBarAction(
            label: tr('undo'),
            onPressed: () {
              _audioMessages.insert(removedIndex, removedAudio);
              _animatedListKey.currentState?.insertItem(removedIndex);
            },
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    },
    child: GestureDetector(
      onLongPress: () {
        setState(() {
          audio['isEditing'] = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.2),
              blurRadius: 10.0,
              spreadRadius: 5.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: isEditing
                  ? TextField(
                      controller: editController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: tr('enter_audio_name'),
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: fontSizes.bodyFontSize,
                          color: theme.hintColor,
                        ),
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: fontSizes.bodyFontSize,
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          audio['name'] = value.trim().isEmpty ? audio['name'] : value.trim();
                          audio['isEditing'] = false;
                        });
                      },
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          audio['name'],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: fontSizes.bodyFontSize,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${_formatDuration(audio['currentPosition'])} / ${_formatDuration(audio['duration'])}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: fontSizes.bodyFontSize,
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
            ),
            IconButton(
              icon: Icon(
                isEditing ? Icons.check : (isPlaying ? Icons.pause : Icons.play_arrow),
                color: theme.colorScheme.primary,
                size: 24.0,
              ),
              onPressed: isEditing
                  ? () {
                      setState(() {
                        audio['name'] = editController.text.trim().isEmpty
                            ? audio['name']
                            : editController.text.trim();
                        audio['isEditing'] = false;
                      });
                    }
                  : () => _playAudio(_audioMessages.indexOf(audio)),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildDateTimeField(ThemeData themeData, FontSizes fontSizes) {
    final formattedDate = "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
    final formattedTime = "${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}";

    return GestureDetector(
      onTap: _pickDateTime,
      child: _buildSection(
        iconSvg: 'assets/icons/calendar.svg',
        title: tr('date_time'),
        content: "$formattedDate $formattedTime",
        themeData: themeData,
        fontSizes: fontSizes,
      ),
    );
  }


 Widget _buildLocationField(ThemeData themeData, FontSizes fontSizes) {
  return _buildSection(
    iconSvg: 'assets/icons/location.svg',
    title: tr('location'),
    content: "Germany : 46.23, 34.214",
    themeData: themeData,
    fontSizes: fontSizes,
  );
}
Widget _buildContactField(ThemeData themeData, FontSizes fontSizes) {
  return _buildInputFieldSearch(
    iconSvg: 'assets/icons/user.svg',
    title: tr('add_contacts'),
    selectedItems: selectedContacts,
    mockItems: ["John Doe", "Alice Smith", "Bob Johnson", "Alice Smith"],
    onAddItem: (item) {
      setState(() {
        if (!selectedContacts.contains(item)) {
          selectedContacts.add(item);
        }
      });
    },
    onRemoveItem: (item) {
      setState(() {
        selectedContacts.remove(item);
      });
    },
    emptyMessage: tr('no_contacts_found'),
    theme: themeData,
    fontSizes: fontSizes,
  );
}


Widget _buildTagField(ThemeData themeData, FontSizes fontSizes) {
  return _buildInputFieldSearch(
    icon: Icons.tag,
    title: tr('add_tags'),
    selectedItems: selectedHashtags,
    mockItems: ["#Flutter", "#Dart", "#UI", "#Development", "#Code"],
    onAddItem: (item) {
      setState(() {
        if (!selectedHashtags.contains(item)) {
          selectedHashtags.add(item);
        }
      });
    },
    onRemoveItem: (item) {
      setState(() {
        selectedHashtags.remove(item);
      });
    },
    emptyMessage: tr('no_tags_found'),
    theme: themeData,
    fontSizes: fontSizes,
  );
}

Widget _buildLibraryField(ThemeData theme, FontSizes fontSizes) {
  return Container(
    color: theme.cardColor,
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/gallery.svg',
              width: 24.0,
              height: 24.0,
              color: theme.hintColor,
            ),
            const SizedBox(width: 8.0),
            Text(
              tr('photos_videos'),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: fontSizes.bodyFontSize,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 4.0,
          runSpacing: 4.0,
          children: [
            ..._selectedImages.map(
              (file) => _buildMediaItem(
                imageFile: file,
                onDelete: () => _removeImage(file),
                size: 80.0,
                theme: theme,
                fontSizes: fontSizes,
              ),
            ),
            GestureDetector(
              onTap: _pickMedia,
              child: Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? theme.cardColor.withOpacity(0.8)
                      : theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.5),
                      spreadRadius: 1.0,
                      blurRadius: 2.0,
                      offset: const Offset(0, 1.0),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.onSurface,
                  size: 24.0,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildSection({
  required String title,
  required String content,
  String? iconSvg,
  IconData? icon,
  required ThemeData themeData,
  required FontSizes fontSizes,
}) {
  final Widget leadingIcon = iconSvg != null
      ? SvgPicture.asset(
    iconSvg,
    width: fontSizes.bodyFontSize + 4,
    height: fontSizes.bodyFontSize + 4,
    color: themeData.iconTheme.color,
  )
      : Icon(
    icon,
    size: fontSizes.bodyFontSize,
    color: themeData.iconTheme.color,
  );

  return Card(
    color: themeData.cardColor,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal:16, vertical: 8),
      child: Row(
        children: [
          leadingIcon,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: themeData.textTheme.bodyMedium?.copyWith(
                    fontSize: fontSizes.bodyFontSize,
                    color: themeData.colorScheme.onSurface,
                  ),
                ),
                Text(
                  content,
                  style: themeData.textTheme.bodyMedium?.copyWith(
                    fontSize: fontSizes.bodyFontSize,
                    color: themeData.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}



  Widget _buildMediaItem({
  required File imageFile,
  required VoidCallback onDelete,
  required double size,
  required ThemeData theme,
  required FontSizes fontSizes,
  double iconSize = 16.0,
  double padding = 4.0,
}) {
  return Stack(
    children: [
      ClipRRect(
        child: Image.file(
          imageFile,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
      Positioned(
        top: padding,
        right: padding,
        child: GestureDetector(
          onTap: onDelete,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(padding),
            child: Icon(
              Icons.close,
              color: theme.colorScheme.onError,
              size: iconSize,
            ),
          ),
        ),
      ),
    ],
  );
}


Widget _buildInputFieldSearch({
  String? iconSvg,
  IconData? icon,
  required String title,
  required List<String> mockItems,
  required List<String> selectedItems,
  required Function(String) onAddItem,
  required Function(String) onRemoveItem,
  required String emptyMessage,
  required ThemeData theme,
  required FontSizes fontSizes,
 
  double padding = 16.0,
  double spacing = 8.0,
  double borderRadius = 8.0,
  double itemHeight = 48.0,
  double overlayMaxHeight = 270.0,
}) {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  OverlayEntry? overlayEntry;
  List<String> filteredItems = List.from(mockItems);

  String formatContact(String contact) {
    List<String> parts = contact.split(' ');
    return parts.isNotEmpty
        ? (parts.length > 1 ? '${parts.first} ${parts.last[0]}.' : parts.first)
        : contact;
  }

  void hideOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void showOverlay(BuildContext context) {
    hideOverlay();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      final bool hasFilteredItems = filteredItems.isNotEmpty;

      final double overlayHeight = hasFilteredItems
          ? (filteredItems.length * itemHeight).clamp(0.0, overlayMaxHeight)
          : itemHeight + padding;

      overlayEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            GestureDetector(
              onTap: hideOverlay,
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.transparent,
              ),
            ),
            Positioned(
              left: position.dx * 0.2,
              top: position.dy + size.height * 1.4,
              width: size.width * 1.16,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: overlayHeight,
                      minHeight: hasFilteredItems ? 0.0 : itemHeight + padding,
                    ),
                    child: hasFilteredItems
                        ? ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return ListTile(
                          title: Text(
                            item,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: fontSizes.bodyFontSize,
                            ),
                          ),
                          onTap: () {
                            onAddItem(item);
                            searchController.clear();
                            hideOverlay();
                          },
                        );
                      },
                    )
                        : Padding(
                      padding: EdgeInsets.all(padding),
                      child: Center(
                        child: Text(
                          emptyMessage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.disabledColor,
                            fontSize: fontSizes.bodyFontSize,

                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      Overlay.of(context).insert(overlayEntry!);
    });
  }

  void filterItems(String query) {
    filteredItems = mockItems
        .where((item) =>
    item.toLowerCase().contains(query.toLowerCase()) &&
        !selectedItems.contains(item))
        .toList();


    if (searchFocusNode.hasFocus) {
      showOverlay(searchFocusNode.context!);
    }
  }

  searchFocusNode.addListener(() {
    if (!searchFocusNode.hasFocus) hideOverlay();
  });

  final Widget leadingIcon = iconSvg != null
      ? SvgPicture.asset(
          iconSvg,
          width: fontSizes.bodyFontSize +4,
          height: fontSizes.bodyFontSize+4,
          color: theme.hintColor,
        )
      : Icon(
          icon,
          size: fontSizes.bodyFontSize +4,
          color: theme.hintColor,
        );

  return Card(
    color: theme.cardColor,
    margin: EdgeInsets.zero,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              leadingIcon,
              SizedBox(width: spacing),
              Expanded(
                child: Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: selectedItems.map((item) {
                    return Chip(
                      backgroundColor: theme.cardColor,
                      label: Text(
                        formatContact(item),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: fontSizes.bodyFontSize,
                          color: theme.colorScheme.onSurface,

                        ),
                      ),
                      deleteIcon: Icon(
                        Icons.close,
                        size: fontSizes.bodyFontSize / 1.5,
                        color: theme.colorScheme.error,
                      ),
                      onDeleted: () {
                        onRemoveItem(item);
                        filterItems(searchController.text);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: itemHeight,
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    onChanged: filterItems,
                    decoration: InputDecoration(
                      hintText: title,
                      prefixIcon: Icon(
                        Icons.search,
                        size: fontSizes.bodyFontSize +4,
                        color: theme.hintColor,
                      ),
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.hintColor,
                        fontSize: fontSizes.bodyFontSize,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: padding / 2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: fontSizes.bodyFontSize,
                      color: theme.colorScheme.onSurface,

                    ),
                  ),
                ),
              ),
              SizedBox(width: spacing),
              InkWell(
                onTap: () {
                  final newItem = searchController.text.trim();
                  if (newItem.isNotEmpty && !selectedItems.contains(newItem)) {
                    onAddItem(newItem);
                    searchController.clear();
                    hideOverlay();
                  }
                },
                borderRadius: BorderRadius.circular(borderRadius),
                child: Ink(
                  width: fontSizes.bodyFontSize * 2.5,
                  height: itemHeight,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? theme.cardColor.withOpacity(0.8)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    color: theme.colorScheme.onSurface,
                    size: fontSizes.bodyFontSize,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildDivider(ThemeData theme) {
  return Container(
    height: 1.0,
    color: theme.primaryColor,
  );
}


}