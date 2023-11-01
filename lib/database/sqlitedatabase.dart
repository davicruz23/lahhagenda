import 'package:sqflite/sqflite.dart';
import 'package:lahhagenda/models/Agenda.dart';
import 'package:path/path.dart';

class SQLiteDatabase {
  Database? _database;
  final String databaseName = 'agenda.db';

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, databaseName);

    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
          CREATE TABLE agenda (
            id INTEGER PRIMARY KEY,
            nome TEXT,
            diahora DATETIME,
            procedimento TEXT
          )
        ''');
    });

    return _database!;
  }

  Future<List<Agenda>> getAllAgenda() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('agenda');
    return List.generate(maps.length, (index) {
      return Agenda(
          id: maps[index]['id'],
          nome: maps[index]['nome'],
          diahora: maps[index]['diahora'],
          procedimento: maps[index]['procedimento']);
    });
  }
}
