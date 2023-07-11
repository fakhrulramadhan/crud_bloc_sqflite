import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//note_state sudah menjadi bagian di note_cubit
import '../cubit/note_cubit.dart'; //yang dibutuhin note cubitnya aja
// import '../cubit/note_state.dart';
import '../models/note/note.dart';
import 'note_edit.dart';

class NoteListView extends StatelessWidget {
  const NoteListView({super.key});

  @override
  Widget build(BuildContext context) {
    //panggil fungsi awal dicubit dengan blocprovider.value
    //pakai value karena mau kasih nilai awalan ketika app berjalan
    //valuenya diisi loadnotes
    //pakai .. karena banyak data note
    return BlocProvider.value(
      value: BlocProvider.of<NoteCubit>(context)..LoadNotes(),
      child: const NoteDataView(),
    );
  }
}

class NoteDataView extends StatelessWidget {
  const NoteDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crud Sqflite Bloc"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: const Text("Hapus Semua Data"),
                        content: const Text("Yakin ingin hapus semua data?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Batal",
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              //panggil fungsi hapus di notes cubit
                              //context read<nama_bloc / cubit>
                              context.read<NoteCubit>().deleteNotesAll();
                              //setelah dihapus muncul pesan data sukses dihapus
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(const SnackBar(
                                  content: Text(
                                    "Semua data catatan berhasil dihapus",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ));

                              //agar popupnya nutup ketika selesai hapus
                              //navback
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "OK",
                              style: TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                          )
                        ],
                      ));
            },
            icon: const Icon(
              Icons.delete,
              size: 24.0,
            ),
          ),
        ],
      ),
      body: const DataNotesView(), //view utk memuat semua notes
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          //diarahin ke note edit view
          //id nya kosong karena mau tambah data baru
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NoteEditView(
                      note: null,
                    )),
          );
        },
      ),
    );
  }
}

class DataNotesView extends StatelessWidget {
  const DataNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    //butuh inisiasi state utk memantau kondisional UI
    //salah disininya ternyata, bukan context read
    //utk memantau UI dengan state pakai copntext.watch
    final state = context.watch<NoteCubit>().state;

    //widget akan dijalankan berdasarkan kondisi state UI
    if (state is NoteInitial) {
      return Container();
    } else if (state is NotesLoading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    } else if (state is NotesLoaded) {
      //jika tidak ada nites
      if (state.notes!.isEmpty) {
        return const Center(
          child: Text("Belum ada catatan saat ini"),
        );
      } else {
        return _ListNotes(state.notes);
      }
    } else {
      return const Center(
        child: Text("Error memuat catatan"),
      );
    }
  }
}

class _ListNotes extends StatelessWidget {
  const _ListNotes(this.notes, {Key? key}) : super(key: key);

  final List<Note>? notes;

  @override
  Widget build(BuildContext context) {
    return ListView(
      //meload banyak data notes
      children: [
        for (final note in notes!) ...[
          Padding(
            padding: const EdgeInsets.all(5),
            child: ListTile(
              tileColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: Text(note.title), //memuuat judul catatan
              subtitle: Text(note.content),
              //dibungkus wrap agar bisa memuat lebih dari 1 widget
              trailing: Wrap(
                runSpacing: 10,
                spacing: 10,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NoteEditView(
                                  note: note,
                                )),
                      );
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 24.0,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      //meanmpilkan pesan dialog hapus
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Hapus Catatan"),
                            content: const Text("Hapus Catatan Ini?"),
                            //actions utk tombolnya
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Batal")),
                              TextButton(
                                onPressed: () {
                                  //hapus berdasarkan id
                                  context
                                      .read<NoteCubit>()
                                      .deleteNotesById(note.id);

                                  //menampilkan sukses dihapus
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(const SnackBar(
                                      content: Text("Catatan Berhasil Dihapus"),
                                    ));

                                  Navigator.pop(context); //popupnya nutup
                                },
                                child: const Text("OK"),
                              )
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.delete,
                      size: 24.0,
                    ),
                  ),
                ],
              ),
            ),
          )
        ]
      ],
    );
  }
}
