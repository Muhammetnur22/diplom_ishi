import 'dart:developer';

import 'package:flip_widget/flip_widget.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:math' as math;

// import 'hor_turn.dart' as horT;

class BookGridView extends StatefulWidget {
  const BookGridView({super.key});

  @override
  State<BookGridView> createState() => _BookGridViewState();
}

class _BookGridViewState extends State<BookGridView> {
  final books = [
    {
      'img': 'assets/images/alem.jpeg',
      'book': 'assets/book/alem.pdf',
    },
    {
      'img': 'assets/images/dowlet.jpeg',
      'book': 'assets/book/alem.pdf',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Book list',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
              ),
        ),
        centerTitle: false,
      ),
      body: GridView.builder(
        itemCount: books.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1 / 1.8,
        ),
        itemBuilder: (context, index) {
          final img = books[index]['img'];
          final path = books[index]['book'];
          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return TestScreen(
                    path: path ?? '',
                  );
                },
              ));
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: Image.asset(img ?? '')),
                  const SizedBox(
                    height: 14,
                  ),
                  Expanded(
                    child: Text(
                      index == 1 ? 'Dowlet gusy romany' : 'Alem icre at gezer',
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
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key, required this.path});

  final String path;

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
  final PdfPageImage? img;
  final GlobalKey<FlipWidgetState> flipKey;

  PdfImg({this.img, required this.flipKey});
}

class _TestScreenState extends State<TestScreen> {
  // final GlobalKey<FlipWidgetState> _flipKey = GlobalKey();

  Offset _oldPosition = Offset.zero;
  List<PdfImg> imgList = [];
  bool isLoading = false;
  bool isSuccess = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getPageImage(context, widget.path);
  }

  changeLoading() {
    isLoading = !isLoading;
    setState(() {});
  }

  Future<void>? getPageImage(BuildContext context, String path) async {
    try {
      changeLoading();
      List<PdfImg> imgs = [];

      final document = await PdfDocument.openAsset(path);
      final pages = document.pagesCount;
      for (var i = 1; i <= pages; i++) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: page.width,
          height: page.height,
          format: PdfPageImageFormat.jpeg,
        );
        await page.close();
        if (pageImage != null) {
          final img =
              PdfImg(flipKey: GlobalKey<FlipWidgetState>(), img: pageImage);
          imgs = List.of(imgs)..add(img);
        }
      }
      imgList = imgs.reversed.toList();
      isSuccess = true;
      changeLoading();

      // setState(() {});

      // return imgs;
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('---- Error appeared $ex --- ')));
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    Size size = Size(width, height);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book reader'),
      ),
      body: () {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (isSuccess) {
          return Stack(
            children: [
              ...imgList.map(
                (img) => GestureDetector(
                  onHorizontalDragStart: (details) {
                    _oldPosition = details.globalPosition;
                    img.flipKey.currentState?.startFlip();
                  },
                  onHorizontalDragUpdate: (details) {
                    Offset off = details.globalPosition - _oldPosition;
                    double tilt = 1 / _clampMin((-off.dy + 20) / 100);
                    double percent = math.max(0, -off.dx / size.width * 1.4);
                    percent = percent - percent / 2 * (1 - 1 / tilt);
                    img.flipKey.currentState?.flip(percent, tilt);
                    if (percent > .45) {
                      // clog('Success to TURn');
                      if (imgList.length >= 3) {
                        // prev = List.from(prev)..add(img);
                        imgList.removeWhere((e) => e == img);
                      }
                      percent = 0;
                      setState(() {});
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    img.flipKey.currentState?.stopFlip();
                  },
                  onHorizontalDragCancel: () {
                    img.flipKey.currentState?.stopFlip();
                  },
                  child: Stack(
                    children: [
                      FlipWidget(
                        key: img.flipKey,
                        child: Image(
                          image: MemoryImage(img.img!.bytes),
                          height: MediaQuery.of(context).size.height,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Icon(Icons.arrow_back_ios),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 15,
                        child: Container(
                            color: Colors.red,
                            child: Text('${imgList.indexOf(img) + 1}')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      }(),
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

void clog<T>(T v) {
  log('- - - - - - - $v - - - - - - - - ');
}
