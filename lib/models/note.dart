class Note {
  int? id;
  String title;
  String description;
  String date;
  int priority; // 1: สำคัญมาก, 2: ปกติ

  Note({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
  });

  // แปลงข้อมูลจาก Object เป็น Map เพื่อบันทึกลง SQLite
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['description'] = description;
    map['date'] = date;
    map['priority'] = priority;
    return map;
  }

  // แปลงข้อมูลจาก Map (SQLite) กลับมาเป็น Object
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      priority: map['priority'],
    );
  }
}