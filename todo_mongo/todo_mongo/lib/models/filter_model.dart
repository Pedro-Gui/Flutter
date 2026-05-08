import 'package:flutter/foundation.dart';

@immutable
class TaskFilter {
  final bool hideCompleted;
  final bool sortDescending;
  final int pagina;
  final String? search;

  const TaskFilter({
    this.hideCompleted = false,
    this.sortDescending = true,
    this.pagina = 1,
    this.search,
  });

  TaskFilter copyWith({
    bool? hideCompleted,
    bool? sortDescending,
    int? pagina,
    String? search,
  }) {
    return TaskFilter(
      hideCompleted: hideCompleted ?? this.hideCompleted,
      sortDescending: sortDescending ?? this.sortDescending,
      pagina: pagina ?? this.pagina,
      search: search == null && this.search != null ? this.search : search, 
    );
  }

  List<dynamic> toArgs() {
    return [hideCompleted, search, pagina, sortDescending];
  }
}