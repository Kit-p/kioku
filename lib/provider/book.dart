import 'package:kioku/model/book.dart';
import 'package:kioku/provider/data.dart';
import 'package:kioku/service/database.dart';

class BookProvider extends DataProvider {
  BookProvider() : super(tableName: 'Book', model: BookModel());

  List<Book> _books = [];

  List<Book> get books => [..._books];

  @override
  Future<bool> fetchAll() async {
    super.fetchAll();

    final db = await DBHelper.instance.db;
    final maps = await db.query(tableName);
    // _books = [
    //   Book(title: 'Alpha', color: Colors.blue),
    //   Book(title: 'Beta', color: Colors.yellow),
    // ];
    _books = maps.map((json) => Book.fromJson(json)).toList();
    notifyListeners();
    return true;
  }

  Future<Book?> insert(Book book) async {
    final db = await DBHelper.instance.db;
    final data = book.toJson();
    final id = await db.insert(tableName, data);
    final insertedBook = await fetch(id);
    if (insertedBook == null) return null;
    _books.add(insertedBook);
    notifyListeners();
    return insertedBook;
  }

  Future<Book?> fetch(int id) async {
    final db = await DBHelper.instance.db;
    final maps = await db
        .query(tableName, where: '${BookModel.id} = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Book.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<Book?> update(Book bookToUpdate) async {
    final db = await DBHelper.instance.db;
    final data = bookToUpdate.toJson();
    final id = data[BookModel.id] as int?;
    if (id == null) {
      throw ArgumentError('id property cannot be null', 'bookToUpdate');
    }
    data.remove(BookModel.id);
    final count = await db
        .update(tableName, data, where: '${BookModel.id} = ?', whereArgs: [id]);
    if (count != 1) throw Exception('Cannot update book with id $id');
    final updatedBook = await fetch(id);
    if (updatedBook == null) return null;
    var index = _books.indexWhere((book) => book.id == id);
    if (index < 0) {
      _books.add(updatedBook);
    } else {
      _books[index] = updatedBook;
    }
    notifyListeners();
    return updatedBook;
  }

  Book get(int id) {
    return books.singleWhere((book) => book.id == id);
  }
}
