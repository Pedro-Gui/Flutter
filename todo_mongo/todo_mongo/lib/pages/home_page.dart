import 'package:dart_meteor/dart_meteor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_mongo/components/my_drawer.dart';
import 'package:todo_mongo/components/my_textfield.dart';
import 'package:todo_mongo/components/todo_tile.dart';
import 'package:todo_mongo/models/task_model.dart';
import 'package:todo_mongo/models/user_model.dart';
import 'package:todo_mongo/services/auth/auth_controller.dart';
import 'package:todo_mongo/services/task/task_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _editOrAdd(bool isEdit, Task? task) {
    Navigator.pushNamed(
      context,
      '/createOrEditPage',
      arguments: {'isEdit': isEdit, 'task': task},
    );
  }

  void _showError(MeteorError e) {
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

  void _onDelete(String taskId) {
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
                await ref.read(taskControllerProvider.notifier).deleteTask(taskId);
              } on MeteorError catch (e) {
                if (!context.mounted) return;
                _showError(e);
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
    ref.read(taskControllerProvider.notifier).setSearch(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskControllerProvider);

    final userAsync = ref.watch(authControllerProvider);
    
    final tasksAsync = ref.watch(tasksStreamProvider);

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
                          onTap: () =>ref.read(taskControllerProvider.notifier).toggleCompleted(),
                          child: Text(taskState.filter.hideCompleted ? 'Show Completed' : 'Hide Completed',)
                        ),
                        PopupMenuItem(
                          onTap: () => ref.read(taskControllerProvider.notifier).toggleSortByDate(),
                          child: Text(
                            taskState.filter.sortDescending ? 'Order: Oldest' : 'Order: Latest',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: _buildTaskList(userAsync, tasksAsync),
                ),
              ],
            ),
          ),
        ),
      ),
    
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _editOrAdd(false, null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  Widget _buildTaskList(AsyncValue<User?> userAsync, AsyncValue<List<Task>> tasksAsync) {
    if (userAsync.value == null) {
      return const Center(child: Text('Faça login para ver suas tarefas.'));
    }

    return switch (tasksAsync) {
      AsyncData(:final value) => _buildData(value),
      AsyncError(:final error) => Center(child: Text('Erro: $error')),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _buildData(List<Task> dados) {
    if (dados.isEmpty) {
      return const Center(child: Text('Nenhuma tarefa encontrada.'));
    }

    final taskState = ref.read(taskControllerProvider);

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
                    await ref.read(taskControllerProvider.notifier).updateSituacao(task.id, task.situacao);
                  } on MeteorError catch (e) {
                    if (mounted) _showError(e);
                  }
                },
                onDelete: () => _onDelete(task.id),
                onEdit: () => _editOrAdd(true, task),
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
                onPressed: () => ref.read(taskControllerProvider.notifier).previousPage(),
                icon: const Icon(Icons.chevron_left),
                color: Theme.of(context).colorScheme.primary,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Page ${taskState.filter.pagina}',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => ref.read(taskControllerProvider.notifier).nextPage(),
                icon: const Icon(Icons.chevron_right),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
