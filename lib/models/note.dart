import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime created;

  Note({
    required this.title,
    required this.content,
    required this.created,
  });

  // Convert Note → String (for secure storage)
  @override
  String toString() {
    return "$title##$content##${created.toIso8601String()}";
  }

  // Convert String → Note (for secure storage restore)
  factory Note.fromString(String str) {
    final parts = str.split("##");
    return Note(
      title: parts[0],
      content: parts[1],
      created: DateTime.parse(parts[2]),
    );
  }
}
