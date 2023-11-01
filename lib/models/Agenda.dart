import 'package:lahhagenda/database/sqlitedatabase.dart';

class Agenda {
  int? id;
  String nome;
  DateTime diahora;
  String procedimento;

  Agenda(
      {this.id,
      required this.nome,
      required this.diahora,
      required this.procedimento});

  Future<int> save() async {
    final db = await SQLiteDatabase().database;
    if (id == null) {
      id = await db?.insert('agenda', toMap());
    } else {
      await db?.update('agenda', toMap(), where: 'id = ?', whereArgs: [id]);
    }
    return id!;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'procedimento': procedimento,
      'diahora': diahora.toIso8601String(), // Converte para ISO 8601
    };
  }
}
