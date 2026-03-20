import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo/pages/home_page.dart';

void main() async{
  await Hive.initFlutter();
  
  // ignore: unused_local_variable
  var box = await Hive.openBox('Tasks');
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:HomePage()
    );
  }
}

//TODO: 1. Filtro de tarefas (completa, incompleta, todas)
//      2. Ordenação de tarefas (alfabética, por data de criação, por data de conclusão)
//      3. Adicionar data de criação e data de conclusão para cada tarefa
//      4. Adicionar categorias para as tarefas (trabalho, pessoal, estudo, etc)
//      5. Adicionar prioridade para as tarefas (alta, média, baixa)