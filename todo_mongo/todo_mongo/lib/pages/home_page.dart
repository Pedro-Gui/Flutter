import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/services/mongo_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController taskController = TextEditingController();
  MongoService? mongoService;

  void editOrAdd(bool isedit, dynamic task, BuildContext context){
    if(isedit){
      taskController.text = task['title'];
    }else{
      taskController.clear();
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isedit ? 'Edit task' : 'New task'),
        content: TextField(controller: taskController),
        actions: [
          MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onPressed: () {
              taskController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          MaterialButton(
            color: Theme.of(context).colorScheme.inversePrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onPressed: () {
              final taskText = taskController.text.trim();

              if (taskText.isEmpty) return;

              if (isedit) {
                mongoService!.updateTask(task['_id'], taskText);
              } else {
                mongoService!.addTask(taskText);
              }

              taskController.clear();
              Navigator.pop(context);
            },
            child: Text(isedit?'Update':'Create', style: TextStyle(color: Theme.of(context).colorScheme.primary),),
          ),
        ],
      ),
    );
  }
  Icon getIcon(String situacao){
    switch (situacao) {
      case 'concluido':
        return Icon(Icons.check_circle_outline, color: Colors.green);
      case 'emAndamento':
        return Icon(Icons.check_circle_outline, color: Colors.orange);
      case 'naoConcluido':
        return Icon(Icons.remove_circle_outline_outlined, color: Colors.red);
      default:
        return Icon(Icons.remove_circle_outline_outlined, color: Colors.red);
    }
  }
  @override
  Widget build(BuildContext context) {
    mongoService = Provider.of<MongoService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TODO',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              mongoService!.signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                'MY TASKS',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  letterSpacing: 1.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: StreamBuilder<Map<String, dynamic>>(
                  stream: mongoService!.todoCollection,
                  builder: (context, snapshot) {
                    if (mongoService!.currentUserId == null) {
                      return const Center(
                        child: Text('Faça login para ver suas tarefas.'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var dados = snapshot.data!;
                    var listaDeTarefas = dados.values.toList();

                    if (listaDeTarefas.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma tarefa encontrada no banco.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: listaDeTarefas.length,
                      itemBuilder: (context, index) {
                        var tarefa = listaDeTarefas[index];
                        return Card(
                          child: ListTile(
                            leading: IconButton(
                              onPressed: (){mongoService!.updateSituacao(tarefa['_id'], tarefa['situacao']);},
                              icon: getIcon(tarefa['situacao']),
                              color: Colors.green,
                            ),
                            title: GestureDetector(
                              onTap: () {
                                editOrAdd(true, tarefa, context);
                              },
                              child: Text(
                                tarefa['title'] ?? 'Tarefa sem título definido',
                              ),
                            ),
                            subtitle: Text('Owner: ${tarefa['ownerUsername']}'),
                            trailing: IconButton(onPressed: (){mongoService!.deleteTask(tarefa['_id']);}, icon: Icon(Icons.delete_outline)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          editOrAdd(false,'',context);
        },
        child: Icon(Icons.add)),
    );
  }
}
