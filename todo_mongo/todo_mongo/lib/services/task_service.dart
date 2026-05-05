import 'package:flutter/material.dart';
import 'package:dart_meteor/dart_meteor.dart';
import 'package:todo_mongo/services/filter_model.dart';
import 'package:todo_mongo/services/task_model.dart';

class TaskService extends ChangeNotifier {
  final MeteorClient _meteor;
  SubscriptionHandler? _tasksSubscription;
  final TaskFilter _filter = TaskFilter();
  
  int _totalTasks = 0;
  int _totalPages = 1;
  final int _itemsPerPage = 6;

  TaskService(this._meteor) {
    if (_meteor.userIdCurrentValue() != null) {
      updateSubscribe();
    }
  }

  TaskFilter get filter => _filter;
  int get totalPages => _totalPages;

  Stream<List<Task>> get todoCollection {
    return _meteor.collection('TODO').map((mapaDaColecao) {
      final docs = mapaDaColecao.values;
      return docs.map((doc) => Task.fromMap(doc as Map<String, dynamic>)).toList();
    });
  }

  Future<void> _fetchTotalPages() async {
    try {
      final total = await _meteor.call(
        'tasks.countTotal',
        args: [_filter.hideCompleted, _filter.search],
      );
      _totalTasks = (total as num).toInt();
      _totalPages = (_totalTasks / _itemsPerPage).ceil();
      if (_totalPages == 0) _totalPages = 1;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSubscribe() async {
    try {
      _tasksSubscription?.stop();
      _tasksSubscription = _meteor.subscribe('tasks', args: _filter.toArgs());
      await _fetchTotalPages();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void clearSubscription() {
    _tasksSubscription?.stop();
    _tasksSubscription = null;
  }

  Future<void> addTask(Task task) async {
    try {
      await _meteor.call('tasks.insert', args: [task.toMapEdit()]);
      await _fetchTotalPages();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _meteor.call(
        'tasks.edit', 
        args: [{'_id': task.id, 'doc': task.toMapEdit()}]
        );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSituacao(String id, String situacao) async {
    late String novaSituacao;
    switch (situacao) {
      case 'concluido':
        novaSituacao = 'naoConcluido';
      case 'emAndamento':
        novaSituacao = 'concluido';
      case 'naoConcluido':
        novaSituacao = 'emAndamento';
      default:
        novaSituacao = 'naoConcluido';
    }
    try {
      await _meteor.call(
        'tasks.toggleSituacao', 
        args: [{'_id': id, 'situacao': novaSituacao}]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _meteor.call('tasks.delete', args: [{'_id': id}]);
      await _fetchTotalPages();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleCompleted() async {
    _filter.hideCompleted = !_filter.hideCompleted;
    _filter.pagina = 1;
    await updateSubscribe();
  }

  Future<void> toggleSortByDate() async {
    _filter.sortDescending = !_filter.sortDescending;
    _filter.pagina = 1;
    await updateSubscribe();
  }

  void nextPage() {
    if(_totalPages == 1){ return;}

    if (_filter.pagina < 1 || _filter.pagina >= _totalPages) {
      _filter.pagina = 1;
      updateSubscribe();
    } else {
      _filter.pagina++;
      updateSubscribe();
    }
  }

  void previousPage() {
    if(_totalPages == 1){ return;}
    
    if (_filter.pagina <= 1) {
      _filter.pagina = _totalPages; 
    } 
    else {
      _filter.pagina--;
    }
    updateSubscribe();
  }

  void setSearch(String texto) {
    _filter.search = texto.isEmpty ? null : texto;
    updateSubscribe();
  }
}