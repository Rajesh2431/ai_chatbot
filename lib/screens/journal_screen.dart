import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/audio_player_widget.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:animated_emoji/animated_emoji.dart';
import '../models/journal_entry.dart';
import '../providers/journal_entries_provider.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final TextEditingController _controller = TextEditingController();
  String? _selectedMood;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _audioPath;
  bool _isRecording = false;
  bool _showTextField = false;
  bool _showRecording = false;
  bool _showControls = false;
  bool _emojiSelected = false;
  final bool _emojiVisible = true;
  final bool _calendarVisible = true;
  late final AnimationController _animationController;
  late final ScrollController _scrollController;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  Future<bool> _onWillPop() async {
    if (_calendarFormat == CalendarFormat.week) {
      setState(() {
        _calendarFormat = CalendarFormat.month;
      });
      return false; // Prevent pop
    }
    if (_emojiSelected) {
      setState(() {
        _emojiSelected = false;
        _showControls = false;
        _showTextField = false;
        _showRecording = false;
      });
      return false; // Prevent pop
    }
    return true; // Allow pop
  }

  final Map<String, AnimatedEmojiData> _moodEmojis = {
    "Happy": AnimatedEmojis.smile,
    "Very Happy": AnimatedEmojis.warmSmile,
    "Sad": AnimatedEmojis.sad,
    "Angry": AnimatedEmojis.angry,
  };

  List<JournalEntry> getEventsForDay(DateTime day) {
    final allEntries = Provider.of<JournalEntriesProvider>(
      context,
      listen: false,
    ).entries;
    return allEntries.where((entry) => isSameDay(entry.date, day)).toList();
  }

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scrollController = ScrollController();
    // Removed scroll listener to prevent emoji and calendar from disappearing on scroll
    // _scrollController.addListener(() {
    //   if (_scrollController.offset > 100 && (_emojiVisible || _calendarVisible)) {
    //     setState(() {
    //       _emojiVisible = false;
    //       _calendarVisible = false;
    //     });
    //   } else if (_scrollController.offset <= 100 && (!_emojiVisible || !_calendarVisible)) {
    //     setState(() {
    //       _emojiVisible = true;
    //       _calendarVisible = true;
    //     });
    //   }
    // });
  }

  Future<void> _initializeRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  void _confirmEntry() async {
    if (_selectedMood == null && _controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a mood and write something.'),
        ),
      );
    } else if (_selectedMood == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a mood.')));
    } else if (_controller.text.isEmpty && _audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something in the journal or record.'),
        ),
      );
    } else {
      final TextEditingController nameController = TextEditingController();

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Enter a name for your journal entry'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    Navigator.pop(context, nameController.text.trim());
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ).then((name) {
        if (name != null && name is String && name.isNotEmpty) {
          final newEntry = JournalEntry(
            date: _selectedDay,
            name: name,
            note: _controller.text,
            mood: _selectedMood,
            audioPath: _audioPath,
            time: DateFormat.Hm().format(DateTime.now()),
          );
          Provider.of<JournalEntriesProvider>(
            context,
            listen: false,
          ).addEntry(newEntry);

          setState(() {
            _controller.clear();
            _selectedMood = null;
            _audioPath = null;
            _calendarFormat = CalendarFormat.month;
            _showTextField = false;
            _showRecording = false;
            _showControls = false;
            _emojiSelected = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Journal entry saved!')));
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _recorder.closeRecorder();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/journal_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);
    _animationController.reset();
    _animationController.repeat();
    setState(() {
      _audioPath = path;
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    _animationController.stop();
    setState(() {
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final entriesForDay = context
        .watch<JournalEntriesProvider>()
        .getEntriesForDate(_selectedDay);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_calendarVisible)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade50,
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2010, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      eventLoader: getEventsForDay,
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isNotEmpty) {
                            final mood = (events.first as JournalEntry).mood;
                            if (mood != null && _moodEmojis.containsKey(mood)) {
                              return Positioned(
                                bottom: 1,
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: AnimatedEmoji(
                                    _moodEmojis[mood]!,
                                    size: 20,
                                  ),
                                ),
                              );
                            } else {
                              return Positioned(
                                bottom: 1,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                ),
                              );
                            }
                          }
                          return null;
                        },
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarFormat: _calendarFormat,
                      onFormatChanged: (format) {
                        setState(() => _calendarFormat = format);
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                if (_emojiVisible) ...[
                  const Text(
                    'Choose your mood',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(221, 46, 46, 46),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      border: _emojiSelected
                          ? null
                          : Border.all(color: Colors.blue.shade100),
                      boxShadow: _emojiSelected
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.blue.shade50,
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    // Removed fixed height to allow content to size naturally
                    child: _emojiSelected
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedEmoji(
                                  _moodEmojis[_selectedMood] ??
                                      AnimatedEmojis.smile,
                                  size: 64,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedMood ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _moodEmojis.entries.map((entry) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedMood = entry.key;
                                    _showControls = true;
                                    _emojiSelected = true;
                                    _calendarFormat = CalendarFormat.week;
                                  });
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedEmoji(entry.value, size: 48),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
                if (_emojiSelected) ...[
                  const SizedBox(height: 16),
                  const Text("Add your memories as text or record audio."),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => setState(() {
                            _showTextField = true;
                            _showRecording = false;
                          }),
                          child: const Text("Text"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => setState(() {
                            _showRecording = true;
                            _showTextField = false;
                          }),
                          child: const Text("Record"),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_showTextField)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Write your memory...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade100),
                        ),
                      ),
                    ),
                  ),
                if (_showRecording)
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _isRecording ? _stopRecording : _startRecording,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade100,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: Colors.blue,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isRecording)
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 40,
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: WaveformPainter(
                                  _animationController.value,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                if (_showControls)
                  ElevatedButton.icon(
                    onPressed: _confirmEntry,
                    icon: const Icon(Icons.check),
                    label: const Text("Confirm"),
                  ),
                const SizedBox(height: 24),
                if (entriesForDay.isNotEmpty) ...[
                  const Text(
                    "Your Entry",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: entriesForDay
                        .map(
                          (entry) => Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            entry.name.isNotEmpty
                                                ? InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) => AlertDialog(
                                                          title: const Text(
                                                            "Journal Name",
                                                          ),
                                                          content: Text(
                                                            entry.name,
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                              child: const Text(
                                                                "Close",
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          entry.name.length >
                                                                  100
                                                              ? "${entry.name.substring(0, 100)}..."
                                                              : entry.name,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        if (entry.mood !=
                                                            null) ...[
                                                          Text(
                                                            entry.mood!,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .blueAccent,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                        ],
                                                        if (entry.audioPath !=
                                                            null) ...[
                                                          const Icon(
                                                            Icons.mic,
                                                            size: 16,
                                                            color: Colors
                                                                .blueAccent,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                        ],
                                                        if (entry
                                                            .note
                                                            .isNotEmpty) ...[
                                                          const Icon(
                                                            Icons.text_snippet,
                                                            size: 16,
                                                            color: Colors
                                                                .blueAccent,
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                            const SizedBox(height: 8),
                                            entry.note.isNotEmpty
                                                ? InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) => AlertDialog(
                                                          title: const Text(
                                                            "Journal Note",
                                                          ),
                                                          content: SingleChildScrollView(
                                                            child: Text(
                                                              entry.note,
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                              child: const Text(
                                                                "Close",
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      constraints:
                                                          const BoxConstraints(
                                                            maxHeight: 55,
                                                          ),
                                                      child: Text(
                                                        entry.note.length > 100
                                                            ? "${entry.note.substring(0, 100)}..."
                                                            : entry.note,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black87,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert),
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                final TextEditingController
                                                editNameController =
                                                    TextEditingController(
                                                      text: entry.name,
                                                    );
                                                final TextEditingController
                                                editNoteController =
                                                    TextEditingController(
                                                      text: entry.note,
                                                    );
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                        'Edit Journal Entry',
                                                      ),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          TextField(
                                                            controller:
                                                                editNameController,
                                                            decoration:
                                                                const InputDecoration(
                                                                  labelText:
                                                                      'Name',
                                                                ),
                                                          ),
                                                          TextField(
                                                            controller:
                                                                editNoteController,
                                                            maxLines: 4,
                                                            decoration:
                                                                const InputDecoration(
                                                                  labelText:
                                                                      'Note',
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            final newName =
                                                                editNameController
                                                                    .text
                                                                    .trim();
                                                            final newNote =
                                                                editNoteController
                                                                    .text
                                                                    .trim();
                                                            if (newName
                                                                    .isNotEmpty &&
                                                                newNote
                                                                    .isNotEmpty) {
                                                              final updatedEntry =
                                                                  JournalEntry(
                                                                    date: entry
                                                                        .date,
                                                                    name:
                                                                        newName,
                                                                    note:
                                                                        newNote,
                                                                    audioPath: entry
                                                                        .audioPath,
                                                                    time: entry
                                                                        .time,
                                                                  );
                                                              Provider.of<
                                                                    JournalEntriesProvider
                                                                  >(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  )
                                                                  .updateEntry(
                                                                    entry,
                                                                    updatedEntry,
                                                                  );
                                                            }
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: const Text(
                                                            'Save',
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else if (value == 'delete') {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                        'Delete Journal Entry',
                                                      ),
                                                      content: const Text(
                                                        'Are you sure you want to delete this entry?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Provider.of<
                                                                  JournalEntriesProvider
                                                                >(
                                                                  context,
                                                                  listen: false,
                                                                )
                                                                .removeEntry(
                                                                  entry,
                                                                );
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: const Text(
                                                            'Delete',
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (entry.audioPath != null) ...[
                                    SizedBox(
                                      height: 60,
                                      child: AudioPlayerWidget(
                                        audioPath: entry.audioPath!,
                                      ),
                                    ),
                                  ],
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      entry.time,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double animationValue;

  WaveformPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (double i = 0; i < size.width; i++) {
      double y =
          size.height / 2 +
          20 * sin((i / size.width * 4 * pi) + (animationValue * 2 * pi));
      if (i == 0) {
        path.moveTo(i, y);
      } else {
        path.lineTo(i, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
