import 'package:flutter/material.dart';
import 'package:lahhagenda/database/sqlitedatabase.dart';
import 'package:lahhagenda/models/Agenda.dart';
import 'package:intl/intl.dart';

class ListarAgendamentos extends StatefulWidget {
  final SQLiteDatabase sqLiteDatabase;

  const ListarAgendamentos({super.key, required this.sqLiteDatabase});

  @override
  _ListarAgendamentosState createState() => _ListarAgendamentosState();
}

class _ListarAgendamentosState extends State<ListarAgendamentos> {
  int currentPage = 0;
  final int itemsPerPage = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 221, 177, 192),
        title: Text(
          'Lista de Agendamentos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/lahhfundo2.jpeg"), // Substitua pelo caminho da sua imagem
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.white
                .withOpacity(0.5), // Ajuste a opacidade conforme desejado
          ),
          FutureBuilder<List<Agenda>>(
            future: widget.sqLiteDatabase.getAllAgenda(),
            builder: (context, snapshot) {
              try {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          'Erro ao carregar agendamentos: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Nenhum agendamento encontrado'));
                } else {
                  List<Agenda> agenda = snapshot.data!;
                  if (currentPage < 0) currentPage = 0;
                  final start = currentPage * itemsPerPage;
                  final end = (currentPage + 1) * itemsPerPage;
                  final visibleAgenda = agenda.sublist(
                      start, end > agenda.length ? agenda.length : end);

                  return Column(
                    children: [
                      for (var a in visibleAgenda)
                        Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ListTile(
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
                            ],
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
                            child: const Text('Anterior'),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              final maxPage =
                                  (agenda.length / itemsPerPage).ceil();
                              if (currentPage < maxPage - 1) {
                                setState(() {
                                  currentPage++;
                                });
                              }
                            },
                            child: const Text('Próximo'),
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
    );
  }
}
