import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'models/note.dart';
import 'widgets/note_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());

  await Hive.openBox<Note>('notes');

  // Restore notes from secure storage (first run only)
  final store = const FlutterSecureStorage();
  final box = Hive.box<Note>('notes');
  final saved = await store.read(key: 'notes');

  if (saved != null && box.isEmpty) {
    for (var noteStr in saved.split('||')) {
      if (noteStr.isNotEmpty) {
        box.add(Note.fromString(noteStr));
      }
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotePage(),
    );
  }
}

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController controller = TextEditingController();
  final FlutterSecureStorage store = const FlutterSecureStorage();
  late Box<Note> notesBox;

  @override
  void initState() {
    super.initState();
    notesBox = Hive.box<Note>('notes');
  }

  // Save notes to secure storage
  Future<void> saveNotes() async {
    final allNotes = notesBox.values.map((n) => n.toString()).join('||');
    await store.write(key: 'notes', value: allNotes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),
      body: ValueListenableBuilder(
        valueListenable: notesBox.listenable(),
        builder: (_, Box<Note> box, __) {
          if (box.isEmpty) {
            return const Center(child: Text("No notes yet. Add one below!"));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (_, i) {
              final key = box.keyAt(i);
              final note = box.get(key)!;
              return NoteCard(
                note: note,
                onDelete: () async {
                  box.delete(key);
                  await saveNotes();
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Type a note",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  notesBox.add(
                    Note(
                      title: controller.text,
                      content: controller.text,
                      created: DateTime.now(),
                    ),
                  );
                  controller.clear();
                  await saveNotes();
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}
