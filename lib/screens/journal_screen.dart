import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';

class JournalEntry {
  final DateTime date;
  final String note;
  final File? audio;
  final String time;

  JournalEntry({required this.date, required this.note, this.audio, required this.time});
}

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final Map<String, List<JournalEntry>> _entries = {};
  final TextEditingController _controller = TextEditingController();
  File? _selectedAudio;

  void _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedAudio = File(result.files.single.path!);
      });
    }
  }

  void _recordAudio() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Recording feature not implemented yet.")),
    );
  }

  void _saveEntry() {
    if (_controller.text.trim().isEmpty && _selectedAudio == null) return;
    final entry = JournalEntry(
      date: _selectedDay,
      note: _controller.text.trim().isEmpty ? 'Voice Note' : _controller.text.trim(),
      audio: _selectedAudio,
      time: DateFormat('HH:mm').format(DateTime.now()),
    );
    final key = DateFormat('yyyy-MM-dd').format(_selectedDay);
    setState(() {
      _entries.putIfAbsent(key, () => []).add(entry);
      _controller.clear();
      _selectedAudio = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entryKey = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final dayEntries = _entries[entryKey] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('My Journal'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.deepOrange,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.orangeAccent),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.orange),
                  weekendStyle: TextStyle(color: Colors.orangeAccent),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final key = DateFormat('yyyy-MM-dd').format(date);
                    if (_entries.containsKey(key)) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts...',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Color(0xFF2C2C2C),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickAudio,
                    icon: const Icon(Icons.mic),
                    label: const Text('Add Audio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _recordAudio,
                    icon: const Icon(Icons.fiber_manual_record),
                    label: const Text('Record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: dayEntries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.headphones, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.note,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Text(entry.time, style: const TextStyle(color: Colors.white38)),
                        const SizedBox(width: 8),
                        const Icon(Icons.more_vert, color: Colors.white38),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
