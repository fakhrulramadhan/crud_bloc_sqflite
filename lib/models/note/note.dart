import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';
part 'note.g.dart';

@freezed
class Note with _$Note {
  factory Note({
    int? id,
    @Default("") String title, //kalau wajib ada harus pakai default(kosong)
    @Default("") String content,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
