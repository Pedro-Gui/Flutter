import 'package:dart_meteor/dart_meteor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/components/my_drawer.dart';
import 'package:todo_mongo/components/my_textfield.dart';
import 'package:todo_mongo/components/todo_tile.dart';
import 'package:todo_mongo/services/auth_service.dart';
import 'package:todo_mongo/services/task_model.dart';
import 'package:todo_mongo/services/task_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TaskService? taskService;
  AuthService? authService;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    taskService = Provider.of<TaskService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    taskService!.updateSubscribe();
  
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
                await taskService!.deleteTask(taskId);
              } on MeteorError catch (e) {
                if (!context.mounted) return;
                showError(e, context);
                Navigator.pop(context);
                return;
              }
              if (!context.mounted) return;
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

  void onChanged(String text) {
    taskService!.setSearch(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    
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
      ),
      drawer: const MyDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MyTextfield(
                        controller: controller,
                        hintText: 'Search',
                        obscureText: false,
                        onChanged: onChanged,
                        showClearButton: true,
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: () {
                            taskService!.toggleCompleted();
                          },
                          child: Text(
                            taskService!.filter.hideCompleted
                                ? 'Show Completed'
                                : 'Hide Completed',
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            taskService!.toggleSortByDate();
                          },
                          child: Text(
                            taskService!.filter.sortDescending
                                ? 'Order: Oldest'
                                : 'Order: Latest',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: StreamBuilder<List<Task>>(
                    stream: taskService!.todoCollection,
                    builder: (context, snapshot) {
                      if (authService!.currentUserId == null) {
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
                                  userId: task.userId,
                                  owner: task.ownerUsername,
                                  onChanged: () async {
                                    try {
                                      await taskService!.updateSituacao(
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
                                  onPressed: () => taskService!.previousPage(),
                                  icon: const Icon(Icons.chevron_left),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    'Page ${taskService!.filter.pagina}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => taskService!.nextPage(),
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
