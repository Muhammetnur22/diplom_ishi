import 'dart:async';

import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:ebook_app/home.dart';
import 'package:flip_widget/flip_widget.dart';
import 'package:flutter/material.dart';
import 'package:stream_transform/stream_transform.dart';

part 'book_event.dart';
part 'book_state.dart';

const _fetchListDuration = Duration(milliseconds: 500);
const _fetchDuration = Duration(milliseconds: 500);
EventTransformer<T> fetchDroppable<T>(Duration duration) {
  return (events, mapper) {
    return droppable<T>().call(events.throttle(duration), mapper);
  };
}

const _duration = Duration(milliseconds: 500);
EventTransformer<Event> debounceEffect<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class BookBloc extends Bloc<BookEvent, BookState> {
  BookBloc() : super(BookInitial()) {
    on<FetchInitialEvent>(_initial);
    on<FetchEvent>(_fetch, transformer: fetchDroppable(_fetchDuration));
    on<TurnToNext>(_next, transformer: fetchDroppable(_fetchDuration));
    on<TurnToPrev>(_prevs, transformer: fetchDroppable(_fetchDuration));
  }

  List<PdfImg> pages1 = <PdfImg>[];

  FutureOr<void> _initial(
      FetchInitialEvent event, Emitter<BookState> emit) async {
    emit(LoadingState());
    try {
      PDFDocument doc = await PDFDocument.fromURL(event.path);
      clog('Initial fetching');
      for (var i = 1; i <= 5; i++) {
        final page = await doc.get(page: i);
        if (page != null) {
          final img = PdfImg(flipKey: GlobalKey<FlipWidgetState>(), img: page);
          pages1 = List.of(pages1)..add(img);
        }
      }
      pages1 = pages1.reversed.toList();
      emit(LoadedState(pages: pages1));
    } catch (e) {
      emit(LoadedFailure());
      clog(e);
    }
  }
  // List<PdfImg> _pages = <PdfImg>[];

  FutureOr<void> _fetch(FetchEvent event, Emitter<BookState> emit) async {
    try {
      clog('......Fetch Start....');

      final isEmpty = pages1.isEmpty;

      final allList = pages1.where((item) => item.isVisible == false).toList();

      final mayFetch = ((allList.length) % 5 == 0);
      clog('May fetch --> $mayFetch');
      if (!isEmpty && mayFetch == false) return;
      clog('...is fetching....');
      emit(LoadingState());

      clog('state list lenght -> ${pages1.length}');
      PDFDocument doc = await PDFDocument.fromURL(event.path);
      List<PdfImg> pages = [];
      final page = (pages1.isEmpty ? 5 : pages1.length + 5) ~/ 5;
      int page0 = 5;
      page0 = page * page0;
      int current = (pages1.length) + 1;
      clog('All page -> $page0');
      clog('page -> $page');
      clog('Current -> $current');

      for (var i = current; i <= page0; i++) {
        final page = await doc.get(page: i);
        if (page != null) {
          final img = PdfImg(flipKey: GlobalKey<FlipWidgetState>(), img: page);
          pages = List.of(pages)..add(img);
        }
      }
      pages1 = List.of(pages1)..addAll(pages.reversed.toList());
      emit(
        LoadedState(
          pages: pages1,
        ),
      );
    } catch (e) {
      clog(e);
      emit(LoadedFailure());
    }
  }

  FutureOr<void> _next(TurnToNext event, Emitter<BookState> emit) async {
    try {
      clog('Turn Next');

      // final pages = (state is LoadedState)
      //     ? (state as LoadedState).pages ?? []
      //     : <PdfImg>[];
      for (var item in pages1) {
        if (item.img?.imgPath == event.page.img?.imgPath) {
          item.isVisible = false;
        }
      }
      clog('Turn next list -> ${pages1.length}');
      emit(LoadedState(pages: pages1));
    } catch (e) {
      clog(e);
    }
  }

  FutureOr<void> _prevs(TurnToPrev event, Emitter<BookState> emit) async {
    try {
      clog('Turn Next');

      for (var item in pages1) {
        if (item.img?.imgPath == event.page.img?.imgPath) {
          // item.isVisible = true;
          final index = pages1.indexOf(item) + 1;
          pages1[index].isVisible = true;

          clog('INDEX ==> $index');
        }
      }

      emit(LoadedState(pages: pages1));
    } catch (e) {
      clog(e);
    }
  }
}
