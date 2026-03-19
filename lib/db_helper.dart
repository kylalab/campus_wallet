import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // db_helper.dart 파일의 DBHelper 클래스 내부에 추가
  Future<List<Map<String, dynamic>>> getExpenses() async {
    Database db = await database;
    // 최신순(id DESC)으로 정렬하여 가져오기
    return await db.query('expenses', orderBy: 'id DESC');
  }

  // db_helper.dart의 DBHelper 클래스 내부에 추가
  Future<int> deleteExpense(int id) async {
    Database db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // db_helper.dart 내부에 추가
Future<List<Map<String, dynamic>>> getCategorySummary() async {
  Database db = await database;
  // 카테고리별로 그룹화하여 금액의 합계를 계산
  return await db.rawQuery('''
    SELECT category, SUM(amount) as total 
    FROM expenses 
    GROUP BY category
  ''');
}

  Future<Database> _initDB() async {
    // 기기 내 DB 파일이 저장될 경로 가져오기
    String path = join(await getDatabasesPath(), 'campus_wallet.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 테이블 생성 쿼리 (지출 내역 저장용)
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount INTEGER,
            category TEXT,
            date TEXT,
            memo TEXT
          )
        ''');
      },
    );
  }

  // 데이터 삽입 기능 (예시)
  Future<int> insertExpense(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('expenses', row);
  }
}
