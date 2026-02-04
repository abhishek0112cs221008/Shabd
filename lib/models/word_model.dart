class Word {
  final String word;
  final String partOfSpeech;
  final String definition;
  final String hindiMeaning;
  final DateTime date;

  Word({
    required this.word,
    required this.partOfSpeech,
    required this.definition,
    required this.hindiMeaning,
    required this.date,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'],
      partOfSpeech: json['part_of_speech'],
      definition: json['definition'],
      hindiMeaning: json['hindi_meaning'],
      date: DateTime.parse(json['date']),
    );
  }
}
