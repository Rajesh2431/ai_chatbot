class JournalEntry {
  final DateTime date;
  String name;
  String note;
  String? mood;
  String? audioPath;
  final String time;
  int? audioDuration; // duration in milliseconds

  JournalEntry({
    required this.date,
    required this.name,
    required this.note,
    this.mood,
    this.audioPath,
    required this.time,
    this.audioDuration,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'name': name,
      'note': note,
      'mood': mood,
      'audioPath': audioPath,
      'time': time,
      'audioDuration': audioDuration,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      date: DateTime.parse(map['date']),
      name: map['name'] ?? '',
      note: map['note'] ?? '',
      mood: map['mood'],
      audioPath: map['audioPath'],
      time: map['time'],
      audioDuration: map['audioDuration'],
    );
  }

  void renameName(String newName) {
    name = newName;
  }

  void renameNote(String newNote) {
    note = newNote;
  }

  void deleteAudio() {
    audioPath = null;
  }
}
