import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_mongo/components/user_avatar.dart';

class ToDoTile extends StatelessWidget {
  final String taskName;
  final String situacao;
  final String owner;
  final String userId;
  final void Function()? onChanged;
  final void Function()? onDelete;
  final void Function()? onEdit;

  const ToDoTile({
    super.key,
    required this.taskName,
    required this.situacao,
    required this.owner,
    required this.userId,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    Icon getIcon(String situacao) {
      switch (situacao) {
        case 'concluido':
          return const Icon(Icons.check_circle_outline, color: Colors.green);
        case 'emAndamento':
          return const Icon(Icons.check_circle_outline, color: Colors.orange);
        case 'naoConcluido':
          return const Icon(Icons.remove_circle_outline_outlined, color: Colors.red);
        default:
          return const Icon(Icons.remove_circle_outline_outlined, color: Colors.red);
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),

      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                onEdit!();
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (context) {
                onDelete!();
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16), 
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: IconButton(
                  onPressed: onChanged,
                  icon: getIcon(situacao),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskName,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600, 
                        color: situacao == 'concluido'
                            ? Theme.of(context,).colorScheme.onPrimary.withValues(alpha: 0.7)
                            : Theme.of(context).colorScheme.onPrimary,
                        decoration: situacao == 'concluido'
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        UserAvatar(userId: userId, radius: 12.0,),
                        const SizedBox(width: 4),
                        Text(
                          owner.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/* Card(
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
                            trailing: IconButton(
                            onPressed: (){mongoService!.deleteTask(tarefa['_id']);}, icon: Icon(Icons.delete_outline)),
                          ),
                        ); */