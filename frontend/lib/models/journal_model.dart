class JournalEntry {
  final int? id;
  final String title;
  final String content;
  final String date;
  final String mood;
  final bool isArchived;

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.mood = "Happy",
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'content': content,
      'date': date,
      'mood': mood,
      'isArchived': isArchived ? 1 : 0,
    };

    // Only include id if it's not null (needed for updates)
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: map['date'],
      mood: map['mood'] ?? 'Happy',
      isArchived: map['isArchived'] == 1,
    );
  }

  JournalEntry copyWith({
    int? id,
    String? title,
    String? content,
    String? date,
    String? mood,
    bool? isArchived,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
