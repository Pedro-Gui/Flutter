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
  final _tasks = Hive.box( 'Tasks');
  ToDoDatabase db = ToDoDatabase();

  @override
  void initState() {
    if(_tasks.get('TODOLIST') == null){
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

  void addNewTask() {
    setState(() {
      if(newTaskTextController.text.isNotEmpty){ db.toDoList.add([newTaskTextController.text, false]);}
      newTaskTextController.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  void createNewTask() {
    showDialog(context: context, builder: (context){
      return DialogBox(
        controller: newTaskTextController,
        onAddTask: addNewTask,
        onCancel: () => Navigator.of(context).pop(),
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
        body: ListView.builder(
          itemCount: db.toDoList.length, 
          itemBuilder: (context, index) {
          return ToDoTile(
            taskName: db.toDoList[index][0], 
            value: db.toDoList[index][1], 
            onChanged: (value) => checkBoxChanged(value, index),
            onDelete: (context) => onDelete(index),
          );
        }),
      );
  }
}