import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and open box
  await Hive.initFlutter();
  await Hive.openBox<String>('notes');

  // Load saved notes from secure storage
  final store = FlutterSecureStorage();
  final box = Hive.box<String>('notes');
  final saved = await store.read(key: 'notes');
  if (saved != null && box.isEmpty) {
    for (var note in saved.split('||')) {
      if (note.isNotEmpty) box.add(note);
    }
  }

  runApp(const MyApp());
}

// Add 'const' and key to follow Flutter best practices
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext ctx) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotePage(),
    );
  }
}

// Add 'const' and key
class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController controller = TextEditingController();
  final FlutterSecureStorage store = FlutterSecureStorage();
  late Box<String> notesBox;

  @override
  void initState() {
    super.initState();
    notesBox = Hive.box<String>('notes');
  }

  // Save all notes to secure storage
  Future<void> saveNotes() async {
    final allNotes = notesBox.values.join('||');
    await store.write(key: 'notes', value: allNotes);
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),
      body: ValueListenableBuilder(
        valueListenable: notesBox.listenable(),
        builder: (_, Box<String> box, __) {
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (_, i) {
              final key = box.keyAt(i);
              final note = box.get(key);
              return ListTile(
                title: Text(note ?? ""),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    box.delete(key);
                    await saveNotes();
                  },
                ),
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
                decoration: const InputDecoration(hintText: "Type note"),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  notesBox.add(controller.text);
                  controller.clear();
                  await saveNotes();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
