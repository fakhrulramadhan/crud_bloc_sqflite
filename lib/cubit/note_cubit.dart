import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/note/note.dart';
import '../db/database_provider.dart';

part 'note_state.dart';

//database provider dipasang di initial (noteInitial)
//spy ketika pertama kali running, langsung terload databasenya
//notecubit butuh parameter databaserovider
class NoteCubit extends Cubit<NoteState> {
  NoteCubit({required DatabaseProvider databaseProvider})
      : _databaseProvider = databaseProvider,
        super(const NoteInitial());

  //instansiasi Database Provider, pakai _ karena privat bisa diakses di file ini
  //aja
  final DatabaseProvider _databaseProvider;

  //fungsi load (get) data
  Future<void> LoadNotes() async {
    //kasih emit state (kondisi UI) loading dulu
    //atur loadingnya di view
    emit(const NotesLoading());
    try {
      //get (dapatin) data notes
      final notes = await _databaseProvider.getNotes();

      //masukkin final notes ke state notesloaded (UI sedang memuat data)
      emit(NotesLoaded(notes: notes));
      //ketika ada error (pengecualian)
    } on Exception {
      emit(const NotesFailure());
    }
  }

  //hapus note berdasarkan id
  Future<void> deleteNotesById(id) async {
    emit(const NotesLoading());

    //loading dulu 2 detik baru hapus
    await Future.delayed(const Duration(seconds: 2));

    //biasakan pakai try-catch kalau mau berurusan sama db / api
    try {
      await _databaseProvider.deleteNotesById(id);
      //setelah datanya dihapus, load notesnya lagi
      LoadNotes();
    } on Exception {
      //jalankan state failure
      emit(const NotesFailure());
    }
  }

  //hapus semua notes
  Future<void> deleteNotesAll() async {
    emit(const NotesLoading());

    await Future.delayed(const Duration(seconds: 2));

    try {
      await _databaseProvider.deleteNotesAll();
      //LoadNotes(); //karena datanya dihapus semua, jadi enggak manggil load data

      //panggil state notesloaded, karena datanya sudah dihapus semua
      //kasih nilai ke notes list kosong saja
      emit(const NotesLoaded(notes: []));
    } on Exception {
      emit(const NotesFailure());
    }
  }

  //untuk edit arau simpan notes, butuh Note model parameter id, title, dan content
  //id digunakan sebagai parameter utk edit
  Future<void> saveNotes(int? id, String title, String content) async {
    //ini load data note yang mau diedit
    //utk menampung data Note
    Note editNote = Note(id: id, title: title, content: content);

    emit(const NotesLoading());

    //loadingnya jadi dua detik
    await Future.delayed(const Duration(seconds: 2));

    //kalau idnya == "" berarti idnya tidak null (kosong)
    try {
      if (id == null) {
        //saveNotes membutuhkan tipe data model Note
        await _databaseProvider.saveNotes(editNote);
      } else {
        await _databaseProvider.updateNotes(editNote);
      }

      //kalau sudah kesimpan / ke edit, panggil emit success
      emit(const NotesSuccess());

      //LoadNotes();
    } on Exception {
      //panggi; state failure
      emit(const NotesFailure());
    }
  }
}
