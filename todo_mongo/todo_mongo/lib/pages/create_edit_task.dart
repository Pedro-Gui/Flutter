import 'package:dart_meteor/dart_meteor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_mongo/components/my_button.dart';
import 'package:todo_mongo/components/my_switch.dart';
import 'package:todo_mongo/components/my_textfield.dart';
import 'package:todo_mongo/services/mongo_service.dart';
import 'package:todo_mongo/services/task_model.dart';

class CreateEditTask extends StatefulWidget {
  final bool isEdit;
  final Task? task;
  const CreateEditTask({super.key, required this.isEdit, this.task});

  @override
  State<CreateEditTask> createState() => _CreateEditTaskState();
}

class _CreateEditTaskState extends State<CreateEditTask> {
  late bool private;
  late String situacaoSelecionada;
  final TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    private = widget.isEdit ? widget.task!.privado : false;
    situacaoSelecionada = widget.isEdit
        ? widget.task!.situacao
        : 'naoConcluido';
    titleController.text = widget.isEdit ? widget.task!.title : '';
  }

  void onPrivateChanged(bool value) {
    setState(() {
      private = value;
    });
  }

  List<DropdownMenuItem<String>> getDropdownItems() {
    return [
      const DropdownMenuItem(
        value: 'naoConcluido',
        child: Row(
          children: [
            Icon(Icons.remove_circle_outline_outlined, color: Colors.red),
            SizedBox(width: 10),
            Text('Não Concluído'),
          ],
        ),
      ),
      const DropdownMenuItem(
        value: 'emAndamento',
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.orange),
            SizedBox(width: 10),
            Text('Em Andamento'),
          ],
        ),
      ),
      const DropdownMenuItem(
        value: 'concluido',
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 10),
            Text('Concluído'),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final MongoService mongoService = Provider.of<MongoService>(
      context,
      listen: false,
    );
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

    void editOrAdd(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm ${widget.isEdit ? 'edit task' : 'new task'} ?'),
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
              onPressed: () async{
                final taskText = titleController.text.trim();
                if (taskText.isEmpty) return;

                final Task tarefaParaSalvar = Task(
                  id: widget.isEdit ? widget.task!.id : '',
                  title: taskText,
                  situacao: situacaoSelecionada,
                  privado: private,
                  userId: widget.isEdit ? widget.task!.userId : '',
                  ownerUsername: mongoService.currentUsername ?? 'Desconhecido',
                  createdAt: widget.isEdit ? widget.task!.createdAt : null,
                );
                if (widget.isEdit) {
                  try {
                    await mongoService.updateTask(tarefaParaSalvar);
                  } on MeteorError catch (e) {
                    if (!context.mounted) return;
                    showError(e, context);
                    Navigator.pop(context);
                    return;
                  }
                } else {
                  try {
                    await mongoService.addTask(tarefaParaSalvar);
                  } on MeteorError catch (e) {
                    if (!context.mounted) return;
                    showError(e, context);
                    Navigator.pop(context);
                    return;
                  }
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

    void onDelete(BuildContext context) {
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
                  await mongoService.deleteTask(widget.task!.id);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Edit task' : 'New task',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        actions: [
          widget.isEdit
              ? IconButton(
                  onPressed: () => onDelete(context),
                  icon: const Icon(Icons.delete),
                )
              : Container(),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Image.asset('lib/images/synergia.png', height: 200, width: 200),
                const SizedBox(height: 25),

                MyTextfield(
                  controller: titleController,
                  hintText: 'Title',
                  obscureText: false,
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MySwitch(
                        private: private,
                        onChanged: onPrivateChanged,
                        label: private ? 'Private' : 'Public',
                      ),

                      SizedBox(
                        width: 250,
                        child: DropdownButtonFormField<String>(
                          initialValue: situacaoSelecionada,
                          decoration: InputDecoration(
                            labelText: 'Situation',
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.inversePrimary,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[600]!),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            fillColor: Theme.of(context).colorScheme.secondary,
                            filled: true,
                          ),

                          items: getDropdownItems(),

                          onChanged: (String? novoValor) {
                            if (novoValor != null) {
                              setState(() {
                                situacaoSelecionada = novoValor;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                MyButton(
                  onTap: () => editOrAdd(context),
                  text: widget.isEdit ? 'Edit' : 'Create',
                ),

                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Cancel ${widget.isEdit ? 'edit' : ' creation'}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
