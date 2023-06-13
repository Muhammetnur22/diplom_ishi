part of 'book_bloc.dart';

@immutable
abstract class BookState {}

class BookInitial extends BookState {}

class LoadingState extends BookState {}

class LoadedState extends BookState {
  final List<PdfImg>? pages;

  LoadedState({this.pages});
}

class LoadedFailure extends BookState {}
