import 'package:hive_flutter/hive_flutter.dart';

class ToDoDatabase {
 
 List toDoList = [];

 final _tasks = Hive.box( 'Tasks');

  void createInitialData() {
    toDoList = [
      ['Task 1', false],
      ['Task 2', false],
      ['Task 3', false],
      ['Task 4', false],
    ];
  }

  void loadData() {
    toDoList = _tasks.get('TODOLIST');
  }

  void updateDataBase() {
    _tasks.put('TODOLIST', toDoList);
  }
}