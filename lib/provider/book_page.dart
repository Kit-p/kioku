import 'package:collection/collection.dart';
import 'package:kioku/model/book.dart';
import 'package:kioku/model/book_page.dart';
import 'package:kioku/provider/book.dart';
import 'package:kioku/provider/data.dart';
import 'package:kioku/service/database.dart';

class BookPageProvider extends DataProvider {
  final BookProvider bookProvider;

  BookPageProvider(this.bookProvider)
      : super(
            tableName: 'Page',
            model: BookPageModel(
                bookTableName: bookProvider.tableName,
                bookTableIdCol: bookProvider.model.cols[BookModel.id]!));

  List<BookPage> _pages = [];

  List<BookPage> get pages => [..._pages];

  @override
  Future<bool> fetchAll() async {
    super.fetchAll();

    final db = await DBHelper.instance.db;
    final maps = await db.query(tableName);
    _pages = maps.map((json) => BookPage.fromJson(json)).toList();
    notifyListeners();
    return true;
  }

  Future<BookPage?> insert(BookPage page) async {
    final db = await DBHelper.instance.db;
    final data = page.toJson();
    final pageNumber = data[BookPageModel.pageNumber] as int?;
    if (pageNumber == null || pageNumber < 1) {
      final bookId = data[BookPageModel.bookId] as int;
      final numPages = _pages.where((page) => page.bookId == bookId).length;
      data[BookPageModel.pageNumber] = numPages + 1;
    }
    final id = await db.insert(tableName, data);
    final insertedPage = await fetch(id);
    if (insertedPage == null) return null;
    _pages.add(insertedPage);
    notifyListeners();
    return insertedPage;
  }

  Future<BookPage?> fetch(int? id, {int? bookId, int? pageNumber}) async {
    final db = await DBHelper.instance.db;
    late final List<Map<String, Object?>> maps;
    if (id != null) {
      maps = await db
          .query(tableName, where: '${BookPageModel.id} = ?', whereArgs: [id]);
    } else {
      if (bookId == null || pageNumber == null) {
        throw ArgumentError(
            'Must provide id, or both bookId and pageNumber to fetch',
            'id, bookId, pageNumber');
      }
      maps = await db.query(tableName,
          where:
              '${BookPageModel.bookId} = ? AND ${BookPageModel.pageNumber} = ?',
          whereArgs: [bookId, pageNumber]);
    }
    if (maps.isNotEmpty) {
      return BookPage.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<BookPage?> update(BookPage pageToUpdate) async {
    final db = await DBHelper.instance.db;
    final data = pageToUpdate.toJson();
    final id = data[BookPageModel.id] as int?;
    if (id == null) {
      throw ArgumentError('id property cannot be null', 'pageToUpdate');
    }
    data.remove(BookPageModel.id);
    data[BookPageModel.lastModifiedTime] =
        DateTime.now().millisecondsSinceEpoch;
    final count = await db.update(tableName, data,
        where: '${BookPageModel.id} = ?', whereArgs: [id]);
    if (count != 1) throw Exception('Cannot update page with id $id');
    final updatedPage = await fetch(id);
    if (updatedPage == null) return null;
    final index = _pages.indexWhere((page) => page.id == id);
    if (index < 0) {
      _pages.add(updatedPage);
    } else {
      _pages[index] = updatedPage;
    }

    notifyListeners();
    return updatedPage;
  }

  BookPage get(int? id, {int? bookId, int? pageNumber}) {
    late final BookPage page;
    if (id != null) {
      page = _pages.singleWhere((page) => page.id == id);
    } else {
      if (bookId == null || pageNumber == null) {
        throw ArgumentError(
            'Must provide id, or both bookId and pageNumber to get',
            'id, bookId, pageNumber');
      }
      page = _pages.singleWhere(
          (page) => page.bookId == bookId && page.pageNumber == pageNumber);
    }
    return page;
  }

  List<BookPage> getAllByBookId(int bookId) {
    return _pages
        .where((page) => page.bookId == bookId)
        .toList()
        .sortedBy<num>((page) => page.pageNumber);
  }
}
