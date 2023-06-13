import 'dart:developer';
import 'dart:math' as math;

import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:ebook_app/bloc/book_bloc.dart';
import 'package:ebook_app/constants.dart';
import 'package:flip_widget/flip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// import 'hor_turn.dart' as horT;

class BookGridView extends StatefulWidget {
  const BookGridView({super.key});

  @override
  State<BookGridView> createState() => _BookGridViewState();
}

class _BookGridViewState extends State<BookGridView> {
  final books = [
    {
      'img': 'assets/images/ene.png',
      'book': AppConstants.alemPDf,
      'name': "Enä tagzym – mukaddeslige tagzym"
    },
    {
      'img': 'assets/images/alem.jpeg',
      'book': AppConstants.alemPDf,
      'name': "Älem içre at gezer"
    },
    {
      'img': 'assets/images/dowlet.jpeg',
      'book': AppConstants.dowletGushy,
      'name': "\"Döwlet guşy\" romany"
    },
    {
      'img': 'assets/images/at.jpeg',
      'book': AppConstants.dowletGushy,
      'name': "Atda wepa-da bar, sapa-da"
    },
  ];

  final Key _key = const Key('unique_key');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Kitaplaryň sanawy',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
              ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: books.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            // mainAxisExtent: ,
            childAspectRatio: 1 / 1.8,
          ),
          itemBuilder: (context, index) {
            final img = books[index]['img'];
            final path = books[index]['book'];
            final title = books[index]['name'];
            return InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return TestScreen(
                      path: path ?? '',
                      title: title ?? '',
                    );
                  },
                ));
              },
              child: Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black12)),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Image.asset(img ?? ''),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Expanded(
                      child: Text(
                        title ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key, required this.path, required this.title});

  final String path;
  final String title;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

const double _MinNumber = 0.008;
double _clampMin(double v) {
  if (v < _MinNumber && v > -_MinNumber) {
    if (v >= 0) {
      v = _MinNumber;
    } else {
      v = -_MinNumber;
    }
  }
  return v;
}

class PdfImg {
  final PDFPage? img;
  GlobalKey<FlipWidgetState> flipKey;
  bool isVisible;

  PdfImg({
    this.img,
    required this.flipKey,
    this.isVisible = true,
  });
}

class _TestScreenState extends State<TestScreen> {
  final UniqueKey _key = UniqueKey();

  Offset _oldPosition = Offset.zero;

  late BookBloc bloc;
  // List<PdfImg> imgList = [];
  // List<PdfImg> prevs = [];
  // bool isLoading = false;
  // bool isSuccess = false;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<BookBloc>(context);
    // if (bloc.state.pages == null) {
    bloc.add(FetchInitialEvent(widget.path));
    // }
  }

  @override
  void dispose() {
    super.dispose();
    bloc.pages1.clear();
    // bloc.disposed();

    // clog(bloc.state.pages?.length);?
    // bloc.dis

    clog('DISPOSE');

    // try {
    //   _deleteCacheDir();
    // } catch (ex) {
    //   clog(ex);
    // }
  }

  // Future<void> _deleteCacheDir() async {
  //   final cacheDir = await getTemporaryDirectory();
  //   if (cacheDir.existsSync()) {
  //     cacheDir.deleteSync(recursive: true);
  //   }
  //   final appDir = await getApplicationSupportDirectory();
  //   if (appDir.existsSync()) {
  //     appDir.deleteSync(recursive: true);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    Size size = Size(width, height);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.title,
        ),
      ),
      body: BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          if (state is LoadingState || state is BookInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is LoadedFailure) {
            return _ErrorPage(() {
              bloc.add(FetchInitialEvent(widget.path));
            });
          }

          final imgList = (state as LoadedState).pages;
          // final current =
          return Stack(
            key: _key,
            children: List.generate(imgList?.length ?? 0, (index) {
              final img = imgList![index];
              final fKey = GlobalKey<FlipWidgetState>();

              return GestureDetector(
                // key: ,
                onHorizontalDragStart: (details) {
                  _oldPosition = details.globalPosition;
                  fKey.currentState?.startFlip();
                },
                onHorizontalDragUpdate: (details) async {
                  Offset off = details.globalPosition - _oldPosition;
                  double tilt = 1 / _clampMin((-off.dy + 20) / 100);
                  double percent = math.max(0, -off.dx / size.width * 1.4);
                  percent = percent - percent / 2 * (1 - 1 / tilt);
                  fKey.currentState?.flip(percent, tilt);
                  if (percent > .45) {
                    //  if(state.pages.isEmpty)
                    bloc.add(TurnToNext(img));
                    percent = 0;
                    bloc.add(FetchEvent(widget.path));
                  }
                },
                onHorizontalDragEnd: (details) {
                  fKey.currentState?.stopFlip();
                },
                onHorizontalDragCancel: () {
                  fKey.currentState?.stopFlip();
                },
                child: Stack(
                  children: [
                    Visibility(
                      visible: img.isVisible,
                      child: FlipWidget(
                        key: fKey,
                        child: img.img,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: ElevatedButton(
                        onPressed: () {
                          bloc.add(TurnToPrev(img));
                        },
                        child: const Icon(Icons.arrow_back_ios),
                      ),
                    ),
                    // Positioned(
                    //   bottom: 5,
                    //   right: 15,
                    //   child: Container(
                    //     width: 30,
                    //     height: 30,
                    //     alignment: Alignment.center,
                    //     decoration: const BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       color: Colors.blue,
                    //     ),
                    //     child: Text(
                    //       "${state.currentPage ?? 1}",
                    //       style: Theme.of(context)
                    //           .textTheme
                    //           .bodyLarge
                    //           ?.copyWith(color: Colors.white),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }

  // Widget _buildWidget(int position, Color color) {
  //   return Container(
  //     color: color,
  //     constraints: const BoxConstraints.expand(),
  //     child: Stack(
  //       alignment: Alignment.topCenter,
  //       children: [
  //         Align(
  //           alignment: Alignment.center,
  //           child: Text(
  //             "0x${position.toRadixString(16).toUpperCase()}",
  //             style: const TextStyle(
  //               color: Color(0xFF2e282a),
  //               fontSize: 40.0,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage(this.onRefresh);
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: Colors.black,
      onRefresh: () async {
        onRefresh.call();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset('assets/error.png'),
              ),
              const SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Center(
                  child: FittedBox(
                    child: Text(
                      'Internet näsazlygy, gaýtadan synanyşyň!',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: 26),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void clog<T>(T v) {
  log('- - - - - - - $v - - - - - - - - ');
}
