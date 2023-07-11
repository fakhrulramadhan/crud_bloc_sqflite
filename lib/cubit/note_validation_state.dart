part of 'note_validation_cubit.dart';

abstract class NoteValidationState extends Equatable {
  const NoteValidationState();

  //komen ini agar props dari state lain bisa dapat lempar nilai
  // @override
  // List<Object> get props => [];
}

//state ketika sitkon nya lagi validasi note
class NoteValidating extends NoteValidationState {
  const NoteValidating({
    this.titleMessage,
    this.contentMessage,
  });

  final String? titleMessage;
  final String? contentMessage;

  NoteValidating copyWith({
    String? titleMessage,
    String? contentMessage,
  }) {
    return NoteValidating(
      titleMessage: titleMessage ?? this.titleMessage,
      contentMessage: contentMessage ?? this.contentMessage,
    );
  }

  @override
  List<Object?> get props => [titleMessage, contentMessage];
}

//state (nilai) ketika berhasil tervalidasi
class NoteValidated extends NoteValidationState {
  const NoteValidated();

  @override
  List<Object> get props => [];
}
