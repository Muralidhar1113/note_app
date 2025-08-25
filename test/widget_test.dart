import 'package:flutter_test/flutter_test.dart';
import 'package:my_note_app/models/note.dart';

void main() {
  test('Create Note object', () {
    final note = Note(
      title: 'Sample Title',
      content: 'This is a test note content',
      created: DateTime.now(), // ✅ Added this
    );

    expect(note.title, 'Sample Title');
    expect(note.content, 'This is a test note content');
    expect(note.created, isA<DateTime>()); // ✅ Optional check
  });
}
