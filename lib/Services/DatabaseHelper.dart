import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final databaseName = 'lifeHacksDatabase.db';
  static final databaseVersion = 1;

  static final categoryTableName = 'categoryTable';
  static final categoryColumnId = 'categoryId';
  static final categoryColumnName = 'categoryName';
  static final categoryImageUrl = 'imageUrl';
  static final categoryLength = 'categoryLength';
  static final categoryInitialHack = 'initialHack';

  static final lifeHacksTableName = 'lifeHacksTable';
  static final categoryId = 'categoryId';
  static final lifeHacksColumnId = 'lifeHacksId';
  static final lifeHacksColumn = 'lifeHack';
  static final isFav = 'isFav';

  static late Database database;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get getDatabase async {
    database = await _initDatabase();
    return database;
  }

  static _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, databaseName);
    return openDatabase(path,
        version: databaseVersion,
        onCreate: _onCreate,
        onConfigure: _onConfigure);
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future _onCreate(Database database, int version) async {
    await database.execute('''CREATE TABLE $categoryTableName
   (
   $categoryColumnId INTEGER,
   $categoryColumnName TEXT NOT NULL,
   $categoryImageUrl TEXT NOT NULL,
   $categoryLength TEXT NOT NULL,
   $categoryInitialHack TEXT NOT NULL
   )
   ''');
    await database.execute('''CREATE TABLE $lifeHacksTableName(
   $lifeHacksColumnId INTEGER,
   $lifeHacksColumn TEXT NOT NULL,
   $isFav TEXT NOT NULL,
   $categoryId INTEGER,
   "FOREIGN KEY ($categoryId) REFERENCES $categoryTableName ($categoryColumnId) ON DELETE NO ACTION ON UPDATE NO ACTION") ''');
  }

  insertIntoCategory({required Map<String, dynamic> categoryTableRow}) async {
    Database db = await instance.getDatabase;
    await db.insert('categoryTable', categoryTableRow);
  }

  insertIntoLifeHacks(
      {required Map<String, dynamic> categoryDetailTableRow}) async {
    Database db = await instance.getDatabase;
    await db.insert('lifeHacksTable', categoryDetailTableRow);
  }

  Future queryCategoryTable(String tableName) async {
    return await database.query(tableName);
  }

  Future queryLifeHacksTable(String tableName) async {
    return await database.query(tableName);
  }

  Future queryCategory({required int catId}) async {
    return await database
        .rawQuery('SELECT * FROM $lifeHacksTableName WHERE $categoryId=$catId');
  }

  Future update(
      {required int lifeHacksId,
      required String isFav,
      required int catId}) async {
    return await database.update(lifeHacksTableName, {"isFav": isFav},
        where: "$lifeHacksColumnId = ? AND $categoryId=?",
        whereArgs: [lifeHacksId, catId]);
  }

  Future singleLifeHack({required int lifeHacksId, required int catId}) async {
    return await database.rawQuery(
        'SELECT * FROM $lifeHacksTableName WHERE $lifeHacksColumnId=$lifeHacksId AND $categoryId=$catId');
  }

  Future favQuery() async {
    return await database
        .query('lifeHacksTable', where: "isFav LIKE ?", whereArgs: ['true']);
  }

  Future bookMarkCopy({required int hackId, required int catId}) async {
    return await database.query('lifeHacksTable',
        where: "isFav LIKE ? AND $lifeHacksColumnId=? AND $categoryId=?",
        whereArgs: ['true', hackId, catId]);
  }
}
