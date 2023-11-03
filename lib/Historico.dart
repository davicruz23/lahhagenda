import 'package:flutter/material.dart';
import 'package:lahhagenda/database/sqlitedatabase.dart';

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
      body: historicoData.isEmpty
          ? Center(
              child: Text('Nenhum atendimento no histórico.'),
            )
          : ListView.builder(
              itemCount: historicoData.length,
              itemBuilder: (context, index) {
                final atendimento = historicoData[index];
                return ListTile(
                  title: Text('Cliente: ${atendimento['nome']}'),
                  subtitle:
                      Text('Procedimento: ${atendimento['procedimento']}'),
                  trailing: Text('Data/Hora: ${atendimento['diahora']}'),
                );
              },
            ),
    );
  }
}
