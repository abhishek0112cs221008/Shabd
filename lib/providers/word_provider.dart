import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/word_model.dart';

class WordProvider with ChangeNotifier {
  List<Word> _words = [];
  Word? _currentWord;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  List<Word> get words => _words;
  Word? get currentWord => _currentWord;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  Future<void> loadWords() async {
    try {
      final String response = await rootBundle.loadString('assets/words.json');
      final List<dynamic> data = json.decode(response);
      _words = data.map((json) => Word.fromJson(json)).toList();
      _selectWordForDate(_selectedDate);
    } catch (e) {
      print("Error loading words: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Word? getWordForDate(DateTime date) {
    // Normalizing date to ignore time
    final normalizedDate = DateTime(date.year, date.month, date.day);

    try {
      return _words.firstWhere((word) {
        final wordDate = DateTime(
          word.date.year,
          word.date.month,
          word.date.day,
        );
        return wordDate.year == normalizedDate.year &&
            wordDate.month == normalizedDate.month &&
            wordDate.day == normalizedDate.day;
      });
    } catch (e) {
      return null;
    }
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _currentWord = getWordForDate(date);
    if (_currentWord == null &&
        _words.isNotEmpty &&
        date.difference(DateTime.now()).inDays <= 0) {
      // Optional: Fallback logic or keep it null
      // _currentWord = _words.first;
    }
    notifyListeners();
  }

  void _selectWordForDate(DateTime date) {
    _currentWord = getWordForDate(date);
    if (_currentWord == null && _words.isNotEmpty) {
      _currentWord = _words.first; // Fallback to first word or handle empty
    }
  }

  List<DateTime> getLast7Days() {
    return List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: index));
    });
  }
}
