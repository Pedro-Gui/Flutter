import 'package:dart_meteor/dart_meteor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo_mongo/models/filter_model.dart';
import 'package:todo_mongo/models/task_model.dart';
import 'task_repository.dart';

part 'task_controller.g.dart';

class TaskState {
  final TaskFilter filter;
  final int totalPages;

  const TaskState({required this.filter, required this.totalPages});
}

@Riverpod(keepAlive: true)
class TaskController extends _$TaskController {
  SubscriptionHandler? _tasksSubscription;
  static const int _itemsPerPage = 6;

  @override
  TaskState build() {

    ref.onDispose(() {
      _tasksSubscription?.stop();
    });

    const initialFilter = TaskFilter();
    Future.microtask(() => _updateSubscribe(initialFilter));

    return const TaskState(filter: initialFilter, totalPages: 1);
  }


  Future<void> _updateSubscribe(TaskFilter newFilter) async {
    final repo = ref.read(taskRepositoryProvider);
    
    _tasksSubscription?.stop();
    _tasksSubscription = repo.subscribe(newFilter.toArgs());

    try {
      final pages = await repo.fetchTotalPages(
        newFilter.hideCompleted, 
        newFilter.search, 
        _itemsPerPage
      );
      state = TaskState(filter: newFilter, totalPages: pages);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addTask(Task task) async {
    await ref.read(taskRepositoryProvider).addTask(task);
    await _updateSubscribe(state.filter);
  }

  Future<void> updateTask(Task task) async {
    await ref.read(taskRepositoryProvider).updateTask(task);
  }

  Future<void> updateSituacao(String id, String situacao) async {
    await ref.read(taskRepositoryProvider).updateSituacao(id, situacao);
  }

  Future<void> deleteTask(String id) async {
    await ref.read(taskRepositoryProvider).deleteTask(id);
    await _updateSubscribe(state.filter);
  }

  Future<void> toggleCompleted() async {
    final newFilter = state.filter.copyWith(
      hideCompleted: !state.filter.hideCompleted,
      pagina: 1,
    );
    await _updateSubscribe(newFilter);
  }

  Future<void> toggleSortByDate() async {
    final newFilter = state.filter.copyWith(
      sortDescending: !state.filter.sortDescending,
      pagina: 1,
    );
    await _updateSubscribe(newFilter);
  }

  void nextPage() {
    if (state.totalPages == 1) return;

    int next = state.filter.pagina + 1;
    if (next > state.totalPages) next = 1;

    final newFilter = state.filter.copyWith(pagina: next);
    _updateSubscribe(newFilter);
  }

  void previousPage() {
    if (state.totalPages == 1) return;

    int prev = state.filter.pagina - 1;
    if (prev < 1) prev = state.totalPages;

    final newFilter = state.filter.copyWith(pagina: prev);
    _updateSubscribe(newFilter);
  }

  void setSearch(String texto) {
    final newSearch = texto.isEmpty ? null : texto;

    final newFilter = state.filter.copyWith(
      pagina: 1,
      search: newSearch,
    );
    
    _updateSubscribe(newFilter);
  }
}

@riverpod
Stream<List<Task>> tasksStream(Ref ref) {
  return ref.watch(taskRepositoryProvider).todoCollection;
}