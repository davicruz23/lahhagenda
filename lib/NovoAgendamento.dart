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

  Future<bool> _verificarHorarioOcupado(DateTime horaSelecionada) async {
    final db = await widget.sqliteDatabase.database;

    final horaInicioStr = DateFormat('HH:mm').format(horaSelecionada);

    // Calcule a hora final, adicionando 59 minutos
    final horaFim = horaSelecionada.add(Duration(minutes: 59));
    final horaFimStr = DateFormat('HH:mm').format(horaFim);

    final count = Sqflite.firstIntValue(await db!.rawQuery(
      'SELECT COUNT(*) FROM agenda WHERE time(diahora) >= ? AND time(diahora) <= ?',
      [horaInicioStr, horaFimStr],
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
                    'Cílios',
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
                  final currentContext =
                      context; // Capture o contexto atual aqui

                  if (diahora != null) {
                    if (await _verificarHorarioOcupado(diahora!)) {
                      ScaffoldMessenger.of(currentContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Este horário já está ocupado. Escolha outro horário.',
                          ),
                        ),
                      );
                    } else {
                      try {
                        final db = await widget.sqliteDatabase.database;
                        final count = Sqflite.firstIntValue(await db!.rawQuery(
                          'SELECT COUNT(*) FROM agenda WHERE diahora = ?',
                          [diahora!.toUtc().toIso8601String()],
                        ));
                        if (count != null && count > 0) {
                          ScaffoldMessenger.of(currentContext).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Este horário já está ocupado. Escolha outro horário.',
                              ),
                            ),
                          );
                        } else {
                          Agenda novaagenda = Agenda(
                            nome: nome!,
                            diahora: diahora!,
                            procedimento: procedimento!,
                          );
                          await db.insert(
                            'agenda',
                            novaagenda.toMap(),
                          );
                          diahora = null;

                          ScaffoldMessenger.of(currentContext).showSnackBar(
                            const SnackBar(
                              content: Text('Cliente adicionado.'),
                            ),
                          );
                          await Future.delayed(const Duration(seconds: 1));
                          Navigator.pop(
                              currentContext); // Use o contexto capturado aqui
                        }
                      } catch (e) {
                        print('Falha ao adicionar cliente: $e');
                      }
                    }
                  } else {
                    // Campos não preenchidos, mostre um SnackBar de erro
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Todos os campos precisam ser preenchidos.'),
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 255, 255, 255)), // Defina a cor de fundo desejada
                  minimumSize: MaterialStateProperty.all<Size>(
                      Size(150, 50)), // Tamanho mínimo do botão
                ),
                child: const Text(
                  'Agendar',
                ),
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
