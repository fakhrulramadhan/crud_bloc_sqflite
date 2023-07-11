import 'package:crud_sqflite/view/note_list.dart';
import 'package:flutter/material.dart';
import './db/database_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/note_cubit.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change'); //utk memantau event yg berjalan
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print("${bloc.runtimeType} $transition");
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print("${bloc.runtimeType} $stackTrace");
  }
}

void main() {
  Bloc.observer = SimpleBlocObserver(); //memantau bloc saat ini
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //karena pakai db lokal, jadi parentnya itu repository dan
    //childnya bloc provider
    return RepositoryProvider(
      create: (context) => DatabaseProvider.instance,
      child: BlocProvider(
        create: (context) =>
            NoteCubit(databaseProvider: DatabaseProvider.instance),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Crud sqflite Bloc",
          theme: ThemeData(primarySwatch: Colors.deepPurple),
          home: const NoteListView(), //halaman awalnya notelistview
        ),
      ),
    );
  }
}
