import 'package:ebook_app/home.dart';
import 'package:flutter/material.dart';

void main() => runApp(const EBookApp());

class EBookApp extends StatelessWidget {
  const EBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'EBook app',
      home: BookGridView(),
    );
  }
}
