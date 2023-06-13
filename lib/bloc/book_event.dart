part of 'book_bloc.dart';

@immutable
abstract class BookEvent {}

class FetchInitialEvent extends BookEvent {
  final String path;

  FetchInitialEvent(this.path);
}

class FetchEvent extends BookEvent {
  final String path;

  FetchEvent(this.path);
}

class TurnToNext extends BookEvent {
  final PdfImg page;

  TurnToNext(this.page);
}

class TurnToPrev extends BookEvent {
  final PdfImg page;

  TurnToPrev(this.page);
}
