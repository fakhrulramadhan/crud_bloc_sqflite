import 'package:crud_sqflite/models/note/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._init();
  static Database? _db;

  DatabaseProvider._init();

  //pengecekan apakah dbnya ada
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _useDatabase('notes.db');
    return _db!;
  }

  Future<Database> _useDatabase(String filePath) async {
    final dbPath = await getDatabasesPath();
    // Descomentar as duas linhas abaixo para apagar a base de dados toda vez
    // que o app iniciar

    // String path = join(dbPath, 'notes.db');
    // await deleteDatabase(path);

    // Retorna o banco de dados aberto
    return await openDatabase(
      join(dbPath, 'notes.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE notes (id INTEGER PRIMARY KEY, title TEXT, content TEXT)');
      },
      version: 2,
    );
  }

  //dapat data semua catatan
  Future<List<Note>> getNotes() async {
    final db = await instance.db;
    final result = await db.rawQuery('SELECT * FROM notes ORDER BY id');
    // print(result);
    return result.map((json) => Note.fromJson(json)).toList();
  }

  //fungsi save Data, masukkan model sebagai parameter ()
  Future<Note> saveNotes(Note note) async {
    //inisiasi db dulu
    final db = await instance.db;

    //nama tabelnya harus sama dengan di awal
    //value tanda tanya diisi oleh model note.title & content
    final id = await db.rawInsert(
        "INSERT INTO notes (title, content) VALUES (?,?)",
        [note.title, note.content]);

    //di freezed enggak ada copy (seperti model biasa)
    //adanya copywith
    return note.copyWith(id: id);
  }

  Future<Note> updateNotes(Note note) async {
    final db = await instance.db;

    //set utk ubah nilai

    //UPDATE nama_table SET nama_field..
    //pakai note title sama content dulu krn 2 itu yang mau dirubah
    //note.id belakangan karena where idnya ditaruh di belakang
    await db.rawUpdate("UPDATE notes SET title = ?, content = ? WHERE id = ?",
        [note.title, note.content, note.id]);

    return note;
  }

  //hapus satuan, note id sebagai parameter,
  //tipe data yang di <> harys sama dengan di paramterer
  Future<int> deleteNotesById(int noteid) async {
    final db = await instance.db;

    final queryDelete =
        await db.rawDelete("DELETE FROM notes where id = ?", [noteid]);

    return queryDelete;
  }

  Future<int> deleteNotesAll() async {
    final db = await instance.db;

    final result = await db.rawDelete("DELETE FROM notes");

    return result;
  }

  //close db kalau aplikasi sudah tidak digunakan
  Future close() async {
    final db = await instance.db;

    db.close();
  }
}
