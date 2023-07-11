import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'note_validation_state.dart';

class NoteValidationCubit extends Cubit<NoteValidationState> {
  NoteValidationCubit() : super(const NoteValidating());

  //buat fungsi untuk validasi note
  //title
  void validForm(String title, String content) {
    String cubitTitleMsg = "";
    String cubitContentMsg = "";
    bool formInvalid;

    //invalidnya false berarti datanya masih valid
    formInvalid = false;

    if (title == "") {
      //ubah forminvalid ke true
      formInvalid = true;
      cubitTitleMsg = "Title Wajib diisi";
    } else {
      //pesan errornya kosong kalau diisi formnya
      cubitTitleMsg = "";
    }

    if (content == "") {
      formInvalid = true;
      cubitContentMsg = "Content Wajib diisi";
    } else {
      cubitContentMsg = "";
    }

    //kalau formnya invalid true, maka jalankan state
    //note validating utk memunculkan validasi error
    if (formInvalid == true) {
      //messagenya diisi oleh cubitmessagenya masing2
      emit(NoteValidating(
          contentMessage: cubitContentMsg, titleMessage: cubitTitleMsg));
    } else {
      //kalau formnya valid (invalid = false) jalankan state
      //note validated (pakai emit(nama_state))
      //note validated kalau datanya berhasil tersimpan
      emit(const NoteValidated());
    }
  }
}
