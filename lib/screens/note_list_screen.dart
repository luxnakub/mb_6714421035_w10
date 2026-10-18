import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/note.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  late Future<List<Note>> _noteListFuture;

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  void _updateNoteList() {
    setState(() {
      _noteListFuture = DatabaseHelper.instance.getNoteList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Note App (W10)'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Note>>(
        future: _noteListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'ยังไม่มีบันทึกข้อความ\nกดปุ่ม + ด้านล่างเพื่อเพิ่มโน้ตเลย!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final noteList = snapshot.data!;

          return ListView.builder(
            itemCount: noteList.length,
            itemBuilder: (context, index) {
              final note = noteList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: note.priority == 1 ? Colors.redAccent : Colors.blue,
                    child: Text(
                      note.priority.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    note.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${note.description}\nวันที่: ${note.date}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () async {
                      if (note.id != null) {
                        await DatabaseHelper.instance.deleteNote(note.id!);
                        _updateNoteList();
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ตรงนี้เดี๋ยวเราทำหน้าจอเพิ่ม/แก้ไขโน้ต (NoteDetailScreen) เชื่อมต่อในสเต็ปถัดไปครับ
          _showAddNoteDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ฟังก์ชันตัวอย่างแบบ Quick Dialog สำหรับทดสอบเพิ่มข้อมูลลง SQLite
  void _showAddNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    int priority = 2;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('เพิ่มโน้ตใหม่'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'หัวข้อโน้ต'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'รายละเอียด'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final newNote = Note(
                    title: titleController.text,
                    description: descController.text,
                    date: DateTime.now().toString().substring(0, 10),
                    priority: priority,
                  );
                  await DatabaseHelper.instance.insertNote(newNote);
                  Navigator.pop(context);
                  _updateNoteList();
                }
              },
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }
}