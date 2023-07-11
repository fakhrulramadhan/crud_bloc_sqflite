import 'package:crud_sqflite/view/note_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crud_sqflite/models/note/note.dart';
import 'package:crud_sqflite/cubit/note_cubit.dart';
import 'package:crud_sqflite/cubit/note_validation_cubit.dart';

class NoteEditView extends StatelessWidget {
  const NoteEditView({super.key, this.note});

  final Note? note;

  //kalau butuh bloc nya lebih dari 1 di UI pakainya multiblocprovider
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        //notecubit, membawa parameter catatan yang diedit
        BlocProvider.value(
          value: BlocProvider.of<NoteCubit>(context),
        ),
        BlocProvider(
          create: (context) => NoteValidationCubit(),
        ),
      ],
      child: NoteEditFormView(note: note),
    );
  }
}

class NoteEditFormView extends StatelessWidget {
  NoteEditFormView({super.key, this.note});

  final Note? note;

  final _formKey = GlobalKey<FormState>(); //pasang formkey
  final TextEditingController _titleTextC = TextEditingController();
  final TextEditingController _contentTextC = TextEditingController();
  //buat focus kalau lagi mode edit
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    //jika note yang dari listview utk diedit kosong,
    //maka textcontrollernya kosond (dalam mode tambah)
    if (note == null) {
      //dalam mode tambah form
      _titleTextC.text == "";
      _contentTextC.text == "";
    } else {
      //dalam mode edit
      _titleTextC.text = note!.title;
      _contentTextC.text = note!.content;
    }

    //scaffold utk UI
    return Scaffold(
        appBar: AppBar(
          title: const Text("Form Catatan"),
          actions: const [],
        ),
        //render UI pakai bloclistener di bodynya
        body: BlocListener<NoteCubit, NoteState>(
          listener: (context, state) {
            // TODO: implement listener

            //render UI berdasarkan state
            if (state is NoteInitial) {
              Container(); //enggak usah pakai return lg (sdh di scaffoled)
            } else if (state is NotesLoading) {
              // Center(
              //   child: CircularProgressIndicator(),
              // );
              showDialog(
                  context: context,
                  builder: (context) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  },
                  barrierDismissible: false);
            } else if (state is NotesSuccess) {
              //kembali ke halaman sebelumnya
              Navigator.pop(context);

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                  content: Text("Berhasil Menambahkan / ubah Catatan"),
                ));

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NoteListView()),
              );

              //panggil fungsi cubit utk load data
              context.read<NoteCubit>().LoadNotes();
            } else if (state is NotesLoaded) {
              //state ketika datanya sudah termuat
              Navigator.pop(context);
            } else if (state is NotesFailure) {
              //state ketika gagal tambah / ubah data
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                  content: Text("Gagal menambahkan data"),
                ));
            }
          },
          child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //pakai blocbuilder, karena setiap textfield wajib dipantau
                    BlocBuilder<NoteValidationCubit, NoteValidationState>(
                      builder: (context, state) {
                        return TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Title",
                          ),
                          controller: _titleTextC,
                          focusNode: _titleFocusNode,
                          //ketika enter lanjut kebawah
                          textInputAction: TextInputAction.next,
                          //ketika sudah diisi, focusnode langsung ke content
                          onEditingComplete: _contentFocusNode.requestFocus,
                          onChanged: (text) {
                            context.read<NoteValidationCubit>().validForm(
                                _titleTextC.text, _contentTextC.text);
                          },
                          onFieldSubmitted: (String value) {},
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          //validasi pesan errornya muncul disini
                          validator: (value) {
                            if (state is NoteValidating) {
                              if (state.titleMessage == "") {
                                return null; //kalau enggak diisi, g ada nilai
                              } else {
                                return state.titleMessage;
                              }
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    BlocBuilder<NoteValidationCubit, NoteValidationState>(
                      builder: (context, state) {
                        return TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Content"),
                          controller: _contentTextC,
                          focusNode: _contentFocusNode,
                          textInputAction: TextInputAction.next,
                          onChanged: (text) {
                            //panggil fungsi validassi
                            context.read<NoteValidationCubit>().validForm(
                                _titleTextC.text, _contentTextC.text);
                          },
                          //menyimpan text title dan content ketika disubmit
                          onFieldSubmitted: (String value) {
                            if (_formKey.currentState!.validate()) {
                              //focusnya dihilangin dulu
                              FocusScope.of(context).unfocus();
                              context.read<NoteCubit>().saveNotes(note?.id,
                                  _titleTextC.text, _contentTextC.text);
                            }
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (state is NoteValidating) {
                              if (state.contentMessage == "") {
                                return null;
                              } else {
                                //ambil nilai statenya
                                return state.contentMessage;
                              }
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      child: SizedBox(
                        width: double.infinity,
                        child: BlocBuilder<NoteValidationCubit,
                            NoteValidationState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state is NoteValidated
                                  ? () {
                                      //kalau datanya terisi semua bakalan nyimpan
                                      //sudah bisa panggil bloc / cubit lain
                                      //currentstate nya wajib ada
                                      if (_formKey.currentState!.validate()) {
                                        //focusnya dimatiin
                                        FocusScope.of(context).unfocus();
                                        //panggil fungsi simpan data
                                        context.read<NoteCubit>().saveNotes(
                                            note?.id,
                                            _titleTextC.text,
                                            _contentTextC.text);

                                        //Navigator.pop(context);
                                      }
                                    }
                                  : null,
                              child: const Text(
                                "Simpan",
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              )),
        ));
  }
}
