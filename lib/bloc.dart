// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flip_widget/flip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ebook_app/home.dart';
import 'package:stream_transform/stream_transform.dart';


enum AppStatus { loading, error, success, idle }

class AppBloc extends Cubit<AppState> {
  AppBloc() : super(AppState());

  // Future<void> init(){
  Future<void>? getPageImage(int index) async {
    try {
      final isEmpty = state.pages?.isEmpty ?? true;

      final allList =
          state.pages?.where((item) => item?.isVisible == true).toList();

      final mayFetch = ((allList?.length ?? 1) % 5 == 0);
      clog('May fetch --> $mayFetch');
      if (!isEmpty && mayFetch == false) return;

      emit(state.copyWith(status: AppStatus.loading));
      PDFDocument doc = await PDFDocument.fromURL('https://firebasestorage.googleapis.com/v0/b/music-app-4e74a.appspot.com/o/alem.pdf?alt=media&token=0e288de8-cd32-41c1-a09e-6307cf3e4692');

      List<PdfImg?> pages = [];
      final page = state.pages?.length ?? 5 ~/ 5;
      int page0 = 5;
      page0 = page * page0;
      int current = (state.pages?.length ?? 0) + 1;
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
      // }

      pages = pages.reversed.toList();
      page0 = (state.currentPage ?? pages.length) + 1;
      int page1 = state.page + 1;

      emit(
        state.copyWith(
          pages: pages,
          status: AppStatus.success,
          currentPage: page0,
          page: page1,
        ),
      );
    } catch (ex) {
      clog(ex);
      emit(state.copyWith(status: AppStatus.error));
      rethrow;
    }
  }

  void turnToNext(PdfImg? page) {
    if (page != null) {
      page.isVisible = false;
      final prevList = List.of(state.pages ?? <PdfImg>[])
        ..add(page)
        ..reversed
        ..toList();
      clog(prevList.length);
      emit(
        state.copyWith(
          pages: prevList,
        ),
      );
    }
  }

  void turnToPrev() {
    // if (page != null) {
    // final prev = s;
    final current = state.prevs?.last;

    current?.flipKey =
        GlobalKey<FlipWidgetState>(debugLabel: UniqueKey().toString());

    final list2 = <PdfImg?>[
      ...state.pages ?? <PdfImg>[],
      ...<PdfImg>[current!]
    ];

    final list =
        state.prevs?.where((el) => el?.img != current.img).toList() ?? [];

    // clog(curList);
    emit(
      state.copyWith(
        prevs: list,
        pages: list2,
      ),
    );
    // }
  }

  void disposed() {
    emit(AppState.empty());
  }
}

class AppState {
  final List<PdfImg?>? pages;
  final List<PdfImg?>? prevs;
  final int? currentPage;
  final int page;
  final AppStatus status;

  AppState({
    this.pages,
    this.status = AppStatus.idle,
    this.prevs,
    this.currentPage,
    this.page = 1,
  });

  AppState.empty()
      : pages = [],
        prevs = [],
        currentPage = 1,
        page = 1,
        status = AppStatus.idle;

  AppState copyWith({
    List<PdfImg?>? pages,
    List<PdfImg?>? prevs,
    int? currentPage,
    int? page,
    AppStatus? status,
  }) {
    return AppState(
      pages: pages ?? this.pages,
      prevs: prevs ?? this.prevs,
      currentPage: currentPage ?? this.currentPage,
      page: page ?? this.page,
      status: status ?? this.status,
    );
  }
}
