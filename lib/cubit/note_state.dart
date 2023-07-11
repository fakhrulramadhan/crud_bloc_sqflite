part of 'note_cubit.dart';

abstract class NoteState extends Equatable {
  const NoteState();

  //komen ini agar props dari state lain bisa dapat lempar nilai
  // @override
  // List<Object> get props => [];
}

//classnya jangan diisi apa apa, kalau tidak ada nilai yang dilempar
class NoteInitial extends NoteState {
  const NoteInitial();

  //untuk melempar nilai
  @override
  List<Object?> get props => [];
}

class NotesLoading extends NoteState {
  const NotesLoading();

  //datanya belum tentu ada
  @override
  List<Object?> get props => [];
}

class NotesLoaded extends NoteState {
  const NotesLoaded({this.notes});

  //pakai tanda ? karena notenya blm tentu ada
  //butuh nilai notes dari model note karena akan memuat data catatan
  final List<Note>? notes;

  //pakai copywith utk memasukkan nilai
  NotesLoaded copyWith({List<Note>? notes}) {
    return NotesLoaded(
        //notes nya diisi oleh notes, kalau enggak ada ambil dari
        //data this.notes
        notes: notes ?? this.notes);
  }

  //utk lempar nilai
  @override
  List<Object?> get props => [notes];
}

class NotesFailure extends NoteState {
  const NotesFailure();

  @override
  List<Object?> get props => [];
}

//buat state success
class NotesSuccess extends NoteState {
  const NotesSuccess();

  @override
  List<Object?> get props => [];
}
