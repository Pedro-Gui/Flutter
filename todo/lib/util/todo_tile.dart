import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo/pages/config/colors.dart';

class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool value;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? onDelete;
  final Function(BuildContext)? onEdit;

  const ToDoTile({
    super.key,
    required this.taskName,
    required this.value,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),

      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
             SlidableAction(
              onPressed: (context) {
                onEdit!(context);
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (context) {
                onDelete!(context);
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
          padding: const EdgeInsets.all(20),
        
          decoration: BoxDecoration(
            color: SysColors.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
        
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
                fillColor: WidgetStateColor.resolveWith((
                  Set<WidgetState> states,
                ) {
                  if (value) {
                    return SysColors.primaryColor;
                  }
                  return SysColors.backgroundColor;
                }),
              ),
              Text(
                taskName,
                style: TextStyle(decoration: value ? TextDecoration.lineThrough :  TextDecoration.none),),
            ],
          ),
        ),
      ),
    );
  }
}
