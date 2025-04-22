import 'package:flutter/material.dart';
// Utiliser l'import relatif au projet au lieu d'un import de package
import 'package/note.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NotesScreen(),
    );
  }
}

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NoteDatabase db = NoteDatabase.instance;
  List<Note> notes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);
    notes = await db.getAllNotes();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Secure Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: () async {
              await db.deleteAllNotes();
              refreshNotes();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? Center(child: Text('No Notes'))
              : ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      title: Text(note.title),
                      subtitle: Text(
                        note.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(note.date.split('T')[0]),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => _buildNoteDialog(note),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => _buildNoteDialog(null),
        ),
      ),
    );
  }

  Widget _buildNoteDialog(Note? note) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final bodyController = TextEditingController(text: note?.body ?? '');

    return AlertDialog(
      title: Text(note == null ? 'Add Note' : 'Edit Note'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          SizedBox(height: 8),
          TextField(
            controller: bodyController,
            decoration: InputDecoration(labelText: 'Content'),
            maxLines: 5,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(note == null ? 'Add' : 'Update'),
          onPressed: () async {
            Navigator.pop(context);
            
            if (note == null) {
              // Create new note
              final newNote = Note(
                title: titleController.text,
                body: bodyController.text,
                date: DateTime.now().toIso8601String(),
              );
              await db.addNote(newNote);
            } else {
              // Update existing note
              final updatedNote = note.copy(
                title: titleController.text,
                body: bodyController.text,
              );
              await db.updateNote(updatedNote);
            }
            
            refreshNotes();
          },
        ),
        if (note != null)
          TextButton(
            child: Text('Delete'),
            onPressed: () async {
              Navigator.pop(context);
              await db.deleteNote(note);
              refreshNotes();
            },
          ),
      ],
    );
  }
}