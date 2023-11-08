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
  final int itemsPerPage = 5;
  String? selectedProcedimento;

  final List<String> procedimentos = [
    'Design',
    'Design + Henna',
    'Micropigmentação',
    'Epilação',
    'Cílios',
  ];

  List<Agenda> agenda = [];

  @override
  void initState() {
    super.initState();
    updateAgenda();
  }

  Future<void> updateAgenda() async {
    agenda = await widget.sqLiteDatabase.getAllAgenda();
    setState(() {}); // Atualiza o estado para reconstruir a UI
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
              color:
                  Color.fromARGB(255, 250, 226, 235), // Cor de fundo desejada
            ),
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
              if (agenda.isEmpty)
                Center(
                  child: Text('Nenhum agendamento disponível.'),
                )
              else
                for (var a in agenda)
                  if (selectedProcedimento == null ||
                      a.procedimento == selectedProcedimento)
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color.fromARGB(255, 247, 225, 232),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 65, 61, 61).withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () async {
                                await a.markAsConcluded();
                                await a.deleteAgenda();
                                setState(() {
                                  agenda.remove(a);
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                color: Colors.green,
                                child: Text('Concluir',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              onTap: () async {
                                await a.markAsCancelled();
                                await a.deleteAgenda();
                                setState(() {
                                  agenda.remove(a);
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                color: Colors.red,
                                child: Text('Cancelar',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
