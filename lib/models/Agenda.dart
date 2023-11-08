import 'package:lahhagenda/database/sqlitedatabase.dart';

class Agenda {
  int? id;
  String nome;
  DateTime diahora;
  String procedimento;
  String? status;

  Agenda(
      {this.id,
      required this.nome,
      required this.diahora,
      required this.procedimento,
      this.status});

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
      'status': status,
    };
  }

  Future<void> deleteAgenda() async {
    final db = await SQLiteDatabase()
        .database; // Obtenha a instância do banco de dados
    if (id != null) {
      await db?.delete('agenda', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> markAsConcluded() async {
    final db = await SQLiteDatabase().database;
    if (id != null) {
      // Atualize o status para "concluído"
      await db?.update(
        'agenda',
        {'status': 'concluído'},
        where: 'id = ?',
        whereArgs: [id],
      );

      // Recupere os detalhes do agendamento atual
      final currentAgendamento =
          await db?.query('agenda', where: 'id = ?', whereArgs: [id]);

      // Insira o agendamento no histórico de atendimentos
      if (currentAgendamento != null && currentAgendamento.isNotEmpty) {
        await db?.insert('historico_atendimentos', currentAgendamento[0]);
      }

      // Em seguida, remova o agendamento da tabela 'agenda'
      await db?.delete('agenda', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> markAsCancelled() async {
    final db = await SQLiteDatabase().database;
    if (id != null) {
      // Atualize o status para "cancelado"
      await db?.update(
        'agenda',
        {'status': 'cancelado'},
        where: 'id = ?',
        whereArgs: [id],
      );

      // Recupere os detalhes do agendamento atual
      final currentAgendamento =
          await db?.query('agenda', where: 'id = ?', whereArgs: [id]);

      // Insira o agendamento no histórico de atendimentos
      if (currentAgendamento != null && currentAgendamento.isNotEmpty) {
        await db?.insert('historico_atendimentos', currentAgendamento[0]);
      }
    }
  }

  Future<bool> isHorarioConflitante() async {
    final db = await SQLiteDatabase().database;
    final List<Map<String, dynamic>>? result = await db?.query(
      'agenda',
      where: 'diahora = ?',
      whereArgs: [diahora.toIso8601String()],
    );
    return result != null && result.isNotEmpty;
  }
}
