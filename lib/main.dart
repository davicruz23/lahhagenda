import 'package:flutter/material.dart';
import 'package:lahhagenda/ListarAgendamentos.dart';
import 'package:lahhagenda/NovoAgendamento.dart';
import 'package:lahhagenda/database/sqlitedatabase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lahh Designer',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 148, 87, 87)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Lahh Designer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _navigateToAgenda() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NovoAgendamento(
          sqliteDatabase: SQLiteDatabase(),
        ),
      ),
    );
  }

  void _navigateToListaAgendamentos() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ListarAgendamentos(
          sqLiteDatabase: SQLiteDatabase(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(
            255, 221, 177, 192), // Substitua "Colors.red" pela cor desejada
        title: Text(widget.title),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/lahhfundo2.jpeg"), // Substitua pelo caminho da sua imagem
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color.fromARGB(255, 0, 0, 0)
                  .withOpacity(0.5), // Ajuste a opacidade aqui
              BlendMode.lighten, // Você pode experimentar com diferentes modos
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToAgenda,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 255, 237, 237)), // Defina a cor de fundo desejada
                ),
                child: const Text(
                  'Agendar Procedimento',
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToListaAgendamentos,
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 255, 237, 237))),
                child: const Text(
                  'Listar Agendamentos',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
