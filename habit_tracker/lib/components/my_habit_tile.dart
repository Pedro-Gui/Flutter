import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habit_tracker/models/habit.dart';

class MyHabitTile extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final void Function(bool?)? onChanged;
  final void Function(BuildContext) onEditHabit;
  final void Function(BuildContext) onDeleteHabit;

  const MyHabitTile({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onChanged,
    required this.onEditHabit,
    required this.onDeleteHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),

      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: onEditHabit,
              backgroundColor: Colors.blue,
              icon: Icons.edit,
              borderRadius: BorderRadius.circular(10),
            ),
            SlidableAction(
              onPressed: onDeleteHabit,
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),

        child: GestureDetector(
          onTap: () {onChanged!(!isCompleted);},

          child: Container(
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),

            child: ListTile(
              title: Text(
                habit.name,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),

              leading: Checkbox(
                activeColor: Colors.green,
                checkColor: Theme.of(context).colorScheme.inversePrimary,
                value: isCompleted,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
