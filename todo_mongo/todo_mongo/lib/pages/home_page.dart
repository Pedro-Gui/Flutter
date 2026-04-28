import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/components/my_drawer.dart';
import 'package:todo_mongo/components/todo_tile.dart';
import 'package:todo_mongo/services/mongo_service.dart';
import 'package:todo_mongo/services/task_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MongoService? mongoService;

  void editOrAdd(bool isEdit, Task? task, BuildContext context) {
    Navigator.pushNamed(
          context,
          '/createOrEditPage',
          arguments: {'isEdit': isEdit, 'task': task},
        );
  }

  @override
  Widget build(BuildContext context) {
    mongoService = Provider.of<MongoService>(context, listen: false);
    bool hideCompleted = mongoService!.hideCompleted;

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
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  mongoService!.toggleCompleted();
                  setState(() {
                    hideCompleted = !hideCompleted;
                  });
                },
                child: Text(
                  hideCompleted ? 'Show Completed' : 'Hide Completed',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
              
            ],
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<Task>>(
                  stream: mongoService!.todoCollection,
                  builder: (context, snapshot) {
                    if (mongoService!.currentUserId == null) {
                      return const Center(
                        child: Text('Faça login para ver suas tarefas.'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma tarefa encontrada.'),
                      );
                    }

                    final List<Task> dados = snapshot.data!;

                    if (dados.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma tarefa encontrada no banco.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: dados.length,
                      itemBuilder: (context, index) {
                        final task = dados[index];
                        return ToDoTile(
                          taskName: task.title,
                          situacao: task.situacao,
                          owner: task.ownerUsername,
                          onChanged: () => mongoService!.updateSituacao(
                            task.id,
                            task.situacao,
                          ),
                          onDelete: () => mongoService!.deleteTask(task.id),
                          onEdit: () => editOrAdd(true, task, context),
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
          editOrAdd(false, null, context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
