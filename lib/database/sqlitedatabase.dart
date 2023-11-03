import 'package:sqflite/sqflite.dart';
import 'package:lahhagenda/models/Agenda.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

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
            procedimento TEXT,
            status TEXT
          )
        ''');
      await db.execute('''
          CREATE TABLE historico_atendimentos (
            id INTEGER PRIMARY KEY,
            nome TEXT,
            diahora DATETIME,
            procedimento TEXT,
            agenda_id INTEGER,
            status TEXT,
            FOREIGN KEY (agenda_id) REFERENCES agenda(id)
          )
        ''');
    });

    return _database!;
  }

  Agenda _mapToAgenda(Map<String, dynamic> row) {
    return Agenda(
      id: row['id'],
      nome: row['nome'],
      diahora: DateFormat('yyyy-MM-dd HH:mm:ss').parse(row['diahora']),
      procedimento: row['procedimento'],
      status: row['status'],
    );
  }

  Future<List<Agenda>> getAllAgenda() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('agenda');
    return List.generate(maps.length, (index) {
      final DateTime diahora = DateTime.parse(maps[index]['diahora']);
      return Agenda(
        id: maps[index]['id'],
        nome: maps[index]['nome'],
        diahora: diahora,
        procedimento: maps[index]['procedimento'],
        status: maps[index]['status'],
      );
    });
  }

  Future<List<Agenda>> getAllHistorico() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db!.query('historico_atendimentos');
    return List.generate(maps.length, (index) {
      final DateTime diahora = DateTime.parse(maps[index]['diahora']);
      return Agenda(
        id: maps[index]['id'],
        nome: maps[index]['nome'],
        diahora: diahora,
        procedimento: maps[index]['procedimento'],
        status: maps[index]['status'],
      );
    });
  }
}
