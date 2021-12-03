import 'package:flutter/material.dart';
import 'package:kioku/component/molecule/book.dart';
import 'package:kioku/component/molecule/book_page.dart';
import 'package:kioku/model/book_page.dart';
import 'package:kioku/provider/book.dart';
import 'package:kioku/provider/book_page.dart';
import 'package:provider/provider.dart';

class BookPageView extends StatelessWidget {
  static const slideshowRoute = '/book_slideshow';

  final int id;

  const BookPageView(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context);
    final provider = context.watch<BookProvider>();
    final book = provider.get(id);
    final List<BookPage> pages =
        context.select<BookPageProvider, List<BookPage>>(
            (BookPageProvider p) => p.getAllByBookId(id));

    final List<Widget> widgets = [
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SizedBox(
            height: deviceData.size.width,
            child: BookWidget.withRoute(book, slideshowRoute),
          ),
        ),
      ),
      ...(pages.map((BookPage page) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                height: deviceData.size.width,
                child: BookPageWidget.withRoute(page, slideshowRoute),
              ),
            ),
          )))
    ];

    return ListView(
      padding: const EdgeInsets.all(8),
      children: widgets,
    );
  }
}
