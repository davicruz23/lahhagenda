import 'package:flutter/material.dart';
import 'package:lahhagenda/database/sqlitedatabase.dart';
import 'package:lahhagenda/models/Agenda.dart';
import 'package:intl/intl.dart';

class ListarAgendamentos extends StatefulWidget {
  final SQLiteDatabase sqLiteDatabase;

  const ListarAgendamentos({Key? key, required this.sqLiteDatabase})
      : super(key: key);

  @override
  _ListarAgendamentosState createState() => _ListarAgendamentosState();
}

class _ListarAgendamentosState extends State<ListarAgendamentos> {
  int currentPage = 0;
  final int itemsPerPage = 6;
  String? selectedProcedimento;

  final List<String> procedimentos = [
    'Design',
    'Design + Henna',
    'Micropigmentação',
    'Inginal',
  ];

  Future<void> moveAgendamentosParaHistorico() async {
    final db = await widget.sqLiteDatabase.database;
    final currentTime = DateTime.now();
    final twentyFourHoursAgo = currentTime.subtract(Duration(hours: 24));

    // Consulta para selecionar os agendamentos com mais de 24 horas
    final agendamentosParaMover = await db?.query(
      'agenda',
      where: 'diahora < ?',
      whereArgs: [twentyFourHoursAgo.toUtc().toIso8601String()],
    );

    for (final agendamento in agendamentosParaMover!) {
      // Atualize o status para "cancelado" antes de mover para o histórico
      await db?.update(
        'agenda',
        {'status': 'cancelado'},
        where: 'id = ?',
        whereArgs: [agendamento['id']],
      );
      // Insira o agendamento no histórico de atendimentos
      await db?.insert('historico_atendimentos', agendamento);
      // Exclua o agendamento da tabela agenda
      await db
          ?.delete('agenda', where: 'id = ?', whereArgs: [agendamento['id']]);
    }
    // Atualize a interface do usuário para refletir as mudanças
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 221, 177, 192),
        title: Text(
          'Lista de Agendamentos',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/lahhfundo2.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.5),
          ),
          Column(
            children: [
              DropdownButton<String>(
                hint: Text('Selecione o procedimento'),
                value: selectedProcedimento,
                items: procedimentos.map((String procedimento) {
                  return DropdownMenuItem<String>(
                    value: procedimento,
                    child: Text(procedimento),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedProcedimento = newValue;
                  });
                },
              ),
              FutureBuilder<List<Agenda>>(
                future: widget.sqLiteDatabase.getAllAgenda(),
                builder: (context, snapshot) {
                  try {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erro ao carregar agendamentos: ${snapshot.error}',
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text('Nenhum agendamento encontrado'),
                      );
                    } else {
                      List<Agenda> agenda = snapshot.data!;
                      if (currentPage < 0) currentPage = 0;
                      final start = currentPage * itemsPerPage;
                      final end = (currentPage + 1) * itemsPerPage;

                      List<Agenda> filteredAgenda = agenda
                          .where((agendamento) =>
                              selectedProcedimento == null ||
                              agendamento.procedimento == selectedProcedimento)
                          .toList();

                      final visibleAgenda = filteredAgenda.sublist(
                        start,
                        end > filteredAgenda.length
                            ? filteredAgenda.length
                            : end,
                      );

                      return Column(
                        children: [
                          for (var a in visibleAgenda)
                            Card(
                              margin: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              elevation: 5,
                              child: Dismissible(
                                key: Key(a.id.toString()),
                                background: Container(
                                  color: Color.fromARGB(255, 235, 20, 4),
                                  child:
                                      Icon(Icons.delete, color: Colors.white),
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 20.0),
                                ),
                                onDismissed: (direction) {
                                  setState(() {
                                    // Remove o agendamento da lista
                                    filteredAgenda.remove(a);
                                  });
                                  // Chama o método para excluir o agendamento do banco
                                  a.deleteAgenda();
                                },
                                child: ListTile(
                                  title: Text(
                                    a.nome,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${a.procedimento} - ${DateFormat('dd/MM/yyyy HH:mm').format(a.diahora)}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (currentPage > 0) {
                                    setState(() {
                                      currentPage--;
                                    });
                                  }
                                },
                                child: Text('Anterior'),
                              ),
                              SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () {
                                  final maxPage =
                                      (filteredAgenda.length / itemsPerPage)
                                          .ceil();
                                  if (currentPage < maxPage - 1) {
                                    setState(() {
                                      currentPage++;
                                    });
                                  }
                                },
                                child: Text('Próximo'),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  } catch (error) {
                    return Center(child: Text('Erro inesperado: $error'));
                  }
                },
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: moveAgendamentosParaHistorico,
        tooltip: 'Mover para o Histórico',
        child: Icon(Icons.archive),
      ),
    );
  }
}
