import 'package:dart_meteor/dart_meteor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/components/my_drawer.dart';
import 'package:todo_mongo/components/my_textfield.dart';
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
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    mongoService = Provider.of<MongoService>(context, listen: false);
  }

  void editOrAdd(bool isEdit, Task? task, BuildContext context) {
    Navigator.pushNamed(
      context,
      '/createOrEditPage',
      arguments: {'isEdit': isEdit, 'task': task},
    );
  }

  void showError(MeteorError e, BuildContext context) {
    String message = 'Ocorreu um erro inesperado.';

    final errorCode = e.error?.toLowerCase() ?? '';
    if (errorCode.contains('not-authorized')) {
      message = 'Você não tem permissão para alterar ou apagar esta tarefa.';
    } else if (e.reason != null && e.reason!.isNotEmpty) {
      message = e.reason!;
    } else {
      message = e.message.toString();
    }

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void onDelete(String taskId, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm delete task ?'),
        actions: [
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          MaterialButton(
            color: Theme.of(context).colorScheme.inversePrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onPressed: () async {
              try {
                await mongoService!.deleteTask(taskId);
              } on MeteorError catch (e) {
                if (!context.mounted) return;
                showError(e, context);
                Navigator.pop(context);
                return;
              }
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Confirm',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
  void onChanged(String text){
    print('|||||||| \n');
    print(controller.text);
     mongoService!.setSearch(controller.text); 
  }
  @override
  Widget build(BuildContext context) {
    final bool hideCompleted = mongoService!.filter.hideCompleted;

    return SafeArea(
      child: Scaffold(
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
                  onTap: () {mongoService!.toggleCompleted();},
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
                MyTextfield(controller: controller, hintText: 'Search', obscureText: false, onChanged: onChanged,),
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

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: dados.length,
                              itemBuilder: (context, index) {
                                final task = dados[index];
                                return ToDoTile(
                                  taskName: task.title,
                                  situacao: task.situacao,
                                  owner: task.ownerUsername,
                                  onChanged: () async {
                                    try {
                                      await mongoService!.updateSituacao(
                                        task.id,
                                        task.situacao,
                                      );
                                    } on MeteorError catch (e) {
                                      if (!context.mounted) return;
                                      showError(e, context);
                                      return;
                                    }
                                  },
                                  onDelete: () => onDelete(task.id, context),
                                  onEdit: () => editOrAdd(true, task, context),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed:  () => mongoService!.previousPage(), 
                                  icon: const Icon(Icons.chevron_left),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    'Página ${mongoService!.filter.pagina}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onPrimary
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => mongoService!.nextPage(),
                                  icon: const Icon(Icons.chevron_right),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
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
      ),
    );
  }
}
