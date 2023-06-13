import 'package:ebook_app/bloc/book_bloc.dart';
import 'package:ebook_app/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(
      BlocProvider(
        create: (context) => BookBloc(),
        child: const EBookApp(),
      ),
    );

class EBookApp extends StatelessWidget {
  const EBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'EBook app',
      debugShowCheckedModeBanner: false,
      home: BookGridView(),
    );
  }
}
