import 'package:flutter/material.dart';
import 'package:lahhagenda/database/sqlitedatabase.dart';
import 'package:intl/intl.dart';

class Historico extends StatefulWidget {
  final SQLiteDatabase sqLiteDatabase;

  const Historico({Key? key, required this.sqLiteDatabase}) : super(key: key);

  @override
  _HistoricoState createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  List<Map<String, dynamic>> historicoData = [];

  @override
  void initState() {
    super.initState();
    _carregarHistoricoAtendimentos();
  }

  Future<void> _carregarHistoricoAtendimentos() async {
    final db = await widget.sqLiteDatabase.database;
    final historico = await db?.query('historico_atendimentos');
    setState(() {
      historicoData = historico!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Histórico de Atendimentos',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
        backgroundColor: Color.fromARGB(255, 221, 177, 192),
      ),
      body: Container(
        color: Color.fromARGB(255, 250, 226, 235), // Cor de fundo desejada
        child: historicoData.isEmpty
            ? Center(
                child: Text('Nenhum atendimento no histórico.'),
              )
            : ListView.builder(
                itemCount: historicoData.length,
                itemBuilder: (context, index) {
                  final atendimento = historicoData[index];
                  final dataHora = DateFormat('dd/MM/yyyy HH:mm').format(
                    DateTime.parse(atendimento['diahora']),
                  );

                  return Card(
                    color: const Color.fromARGB(255, 247, 225, 232),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 3,
                    child: ListTile(
                      title: Text('Cliente: ${atendimento['nome']}'),
                      subtitle:
                          Text('Procedimento: ${atendimento['procedimento']}'),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Data/Hora: $dataHora'),
                          Text('Status: ${atendimento['status']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
