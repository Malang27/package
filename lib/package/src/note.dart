class Note {
  int? id;
  String title;
  String body;
  String date;

  Note({
    this.id,
    required this.title,
    required this.body,
    required this.date,
  });

  // Convert Note to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'date': date,
    };
  }

  // Create Note from Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      date: map['date'],
    );
  }

  // Clone note with new values
  Note copy({
    int? id,
    String? title,
    String? body,
    String? date,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
    );
  }
}