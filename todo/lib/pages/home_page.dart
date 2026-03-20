import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo/data/database.dart';
import 'package:todo/pages/config/colors.dart';
import 'package:todo/util/dialog_box.dart';
import 'package:todo/util/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _tasks = Hive.box('Tasks');
  ToDoDatabase db = ToDoDatabase();

  @override
  void initState() {
    if (_tasks.get('TODOLIST') == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    super.initState();
  }

  final newTaskTextController = TextEditingController();

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = value;
    });
    db.updateDataBase();
  }

  void onDelete(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();
  }

  void onAddTask() {
    setState(() {
      if (newTaskTextController.text.isNotEmpty) {
        db.toDoList.add([newTaskTextController.text, false]);
      }
      newTaskTextController.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: newTaskTextController,
          onAddTask: onAddTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

   void onEditTask(int index) {
    setState(() {
      if (newTaskTextController.text.isNotEmpty) {
        db.toDoList[index][0] = newTaskTextController.text;
      }
      newTaskTextController.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }
  
  void editTask(int index) {
    newTaskTextController.text = db.toDoList[index][0];

    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: newTaskTextController,
          onAddTask: () => onEditTask(index),
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void onUpdatePosition(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex--;
      }
      final item = db.toDoList.removeAt(oldIndex);
      db.toDoList.insert(newIndex, item);
    });
    db.updateDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SysColors.backgroundColor,

      appBar: AppBar(
        title: Center(child: Text('Todo App')),
        backgroundColor: SysColors.primaryColor,
        elevation: 1,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: SysColors.primaryColor,
        child: Icon(Icons.add),
      ),
      body: ReorderableListView(
        proxyDecorator: (Widget child, int index, Animation<double> animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Material(
                elevation: 0,
                color: Colors.transparent,
                child: child,
              );
            },
            child: child,
          );
        },
        children: [
          for (final tile in db.toDoList)
            ToDoTile(
              key: ValueKey(tile),
              taskName: tile[0],
              value: tile[1],
              onChanged: (value) =>
                  checkBoxChanged(value, db.toDoList.indexOf(tile)),
              onDelete: (context) => onDelete(db.toDoList.indexOf(tile)),
              onEdit:   (context) => editTask(db.toDoList.indexOf(tile)),
            ),
        ],
        onReorder: (oldIndex, newIndex) => onUpdatePosition(oldIndex, newIndex),
      ),
    );
  }
}
