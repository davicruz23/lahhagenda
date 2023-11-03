import 'package:flutter/material.dart';
import 'package:lahhagenda/database/sqlitedatabase.dart';
import 'package:intl/intl.dart';
import 'package:lahhagenda/models/Agenda.dart';
import 'package:sqflite/sqflite.dart';

class NovoAgendamento extends StatefulWidget {
  final SQLiteDatabase sqliteDatabase;

  const NovoAgendamento({super.key, required this.sqliteDatabase});

  @override
  _AgendarState createState() => _AgendarState();
}

class _AgendarState extends State<NovoAgendamento> {
  int? id;
  String? nome;
  DateTime? diahora;
  String? procedimento;

  final double fontSize = 20.0;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        diahora = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        diahora = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<bool> _verificarHorarioOcupado(DateTime horario) async {
    final db = await widget.sqliteDatabase.database;
    final horarioStr = horario.toUtc().toIso8601String();
    final count = Sqflite.firstIntValue(await db!.rawQuery(
      'SELECT COUNT(*) FROM agenda WHERE diahora = ?',
      [horarioStr],
    ));
    print('Número de registros encontrados: $count');
    return count! > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Novo Agendamento',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: const Color.fromARGB(255, 221, 177, 192),
      ),
      body: Container(
        color: Color.fromARGB(255, 250, 226, 235),
        /*decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/lahhfundo2.jpeg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color.fromARGB(255, 255, 251, 251).withOpacity(0.5),
              BlendMode.lighten,
            ),
          ),
        ),*/
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: ListView(
            children: [
              _buildField(
                'Cliente',
                TextField(
                  decoration: InputDecoration(
                    labelStyle: TextStyle(fontSize: fontSize),
                  ),
                  onChanged: (value) {
                    setState(() {
                      nome = value;
                    });
                  },
                ),
              ),
              _buildField(
                'Procedimento',
                DropdownButton<String>(
                  hint: Text('Selecione o procedimento'),
                  value: procedimento,
                  items: [
                    'Design',
                    'Design + Henna',
                    'Micropigmentação',
                    'Epilação',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      procedimento = value;
                    });
                  },
                ),
              ),
              _buildField(
                'Data',
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: Text('Selecionar Data'),
                    ),
                    SizedBox(width: 16.0),
                    Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ],
                ),
              ),
              _buildField(
                'Hora',
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: Text('Selecionar Hora'),
                    ),
                    SizedBox(width: 16.0),
                    Text(
                      selectedTime.format(context),
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nome != null && diahora != null && procedimento != null) {
                    if (await _verificarHorarioOcupado(diahora!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Este horário já está ocupado. Escolha outro horário.'),
                        ),
                      );
                    } else {
                      // Prossiga com a inserção no banco de dados
                      Agenda novaagenda = Agenda(
                        nome: nome!,
                        diahora: diahora!,
                        procedimento: procedimento!,
                      );
                      try {
                        final db = await widget.sqliteDatabase.database;
                        await db?.insert(
                          'agenda',
                          novaagenda.toMap(),
                        );
                        nome = null;
                        diahora = null;
                        procedimento = null;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cliente adicionado.'),
                          ),
                        );
                        await Future.delayed(const Duration(seconds: 1));
                        Navigator.pop(context);
                      } catch (e) {
                        print('Falha ao adicionar cliente: $e');
                      }
                    }
                  } else {
                    // Campos não preenchidos, mostre um SnackBar de erro
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Todos os campos precisam ser preenchidos.'),
                      ),
                    );
                  }
                },
                child: Text('Agendar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: fontSize),
        ),
        child,
        const SizedBox(height: 16.0),
      ],
    );
  }
}
