import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';

class JournalEntriesProvider with ChangeNotifier {
  final List<JournalEntry> _entries = [];
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  JournalEntriesProvider() {
    _loadEntries();
  }

  List<JournalEntry> get entries => List.unmodifiable(_entries);

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entryList = prefs.getStringList('journal_entries') ?? [];

    _entries.clear();
    _entries.addAll(
      entryList.map((e) => JournalEntry.fromMap(jsonDecode(e))),
    );

    _isLoading = false;
    notifyListeners();
  }

  void addEntry(JournalEntry entry) async {
    _entries.add(entry);
    await _saveToPrefs();
    notifyListeners();
  }

  void updateEntry(JournalEntry oldEntry, JournalEntry newEntry) async {
    final index = _entries.indexOf(oldEntry);
    if (index != -1) {
      _entries[index] = newEntry;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  /// Call this after modifying an entry directly (e.g., rename, deleteAudio)
  Future<void> notifyAndSave() async {
    await _saveToPrefs();
    notifyListeners();
  }

  void removeEntry(JournalEntry entry) async {
    _entries.remove(entry);
    await _saveToPrefs();
    notifyListeners();
  }

  List<JournalEntry> getEntriesForDate(DateTime date) {
    return _entries.where((e) =>
        e.date.year == date.year &&
        e.date.month == date.month &&
        e.date.day == date.day).toList();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final entryList =
        _entries.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('journal_entries', entryList);
  }
}
