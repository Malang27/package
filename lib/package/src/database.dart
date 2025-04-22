import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'note.dart';

class NoteDatabase {
  static final NoteDatabase instance = NoteDatabase._init();
  static Database? _database;

  NoteDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // CRUD Operations
  
  // Create: Add a new note
  Future<int> addNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }
  
  // Read: Get all notes
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }
  
  // Read: Get a specific note by id
  Future<Note?> getNote(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }
  
  // Update: Update an existing note
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
  
  // Alternative Update: Update an old note with a new note
  Future<int> updateNoteAlt(Note oldNote, Note newNote) async {
    final db = await database;
    return await db.update(
      'notes',
      newNote.toMap(),
      where: 'id = ?',
      whereArgs: [oldNote.id],
    );
  }
  
  // Delete: Delete a note
  Future<int> deleteNote(Note note) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
  
  // Delete: Delete all notes
  Future<int> deleteAllNotes() async {
    final db = await database;
    return await db.delete('notes');
  }
  
  // Close the database
  Future close() async {
    final db = await database;
    db.close();
  }
}