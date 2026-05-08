import 'package:dart_meteor/dart_meteor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_mongo/models/task_model.dart';
import '../meteor_provider.dart';

part 'task_repository.g.dart';

class TaskRepository {
  final MeteorClient _meteor;

  const TaskRepository(this._meteor);

  Stream<List<Task>> get todoCollection {
    return _meteor.collection('TODO').map((mapaDaColecao) {
      return mapaDaColecao.values
          .map((doc) => Task.fromMap(doc as Map<String, dynamic>))
          .toList();
    });
  }

  SubscriptionHandler subscribe(List<dynamic> args) {
    return _meteor.subscribe('tasks', args: args);
  }

  Future<int> fetchTotalPages(bool hideCompleted, String? search, int itemsPerPage) async {
    try {
      final total = await _meteor.call('tasks.countTotal', args: [hideCompleted, search]);
      final totalTasks = (total as num).toInt();
      final int pages = (totalTasks / itemsPerPage).ceil();
      return pages == 0 ? 1 : pages;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addTask(Task task) async {
    await _meteor.call('tasks.insert', args: [task.toMapEdit()]);
  }

  Future<void> updateTask(Task task) async {
    await _meteor.call('tasks.edit', args: [{'_id': task.id, 'doc': task.toMapEdit()}]);
  }

  Future<void> updateSituacao(String id, String situacao) async {
    final String novaSituacao;
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

    await _meteor.call('tasks.toggleSituacao', args: [{'_id': id, 'situacao': novaSituacao}]);
  }

  Future<void> deleteTask(String id) async {
    await _meteor.call('tasks.delete', args: [{'_id': id}]);
  }
}

@Riverpod(keepAlive: true)
TaskRepository taskRepository(Ref ref) {
  return TaskRepository(ref.watch(meteorClientProvider));
}